import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { SafePipe } from '../pipes/safe.pipe';

@Component({
  selector: 'app-student-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, SafePipe],
  templateUrl: './student-dashboard.component.html',
  styleUrl: './student-dashboard.component.css'
})
export class StudentDashboardComponent implements OnInit {

  activeTab: 'dashboard'|'my-courses'|'all-courses'|'routine'|'attendance'|'meetings'|'chat'|'notices'|'profile' = 'dashboard';
  theme: 'dark'|'light' = 'light';

  userEmail=''; userName=''; userDept=''; userSemester=''; userPhone='';

  mySubjects: any[] = [];
  allSubjects: any[] = [];
  routines: any[] = [];
  loading = true;
  error = '';

  routineDays  = ['Saturday','Sunday','Monday','Tuesday','Wednesday','Thursday'];
  routineSlots = ['08:30-10:00','10:00-11:30','11:00-12:30','14:00-15:30'];

  // ── Attendance ──
  myAttendanceSummary: any[] = [];
  myAttendanceDetail: any[] = [];
  attDetailSubjectId: number = 0;
  attLoading = false;

  // ── Meetings ──
  activeMeetings: any[] = [];
  meetingLoading = false;
  activeMeetingRoom: string = '';
  joinedMeetingId: number = 0;

  // ── Chat ──
  chatContacts: any[] = [];
  chatMessages: any[] = [];
  chatSelectedContact: any = null;
  chatMyId: number = 0;
  chatNewMessage = '';
  chatPolling: any = null;

  // ── Notices ──
  notices: any[] = []; noticeLoading=false;

  private baseUrl = 'http://localhost:8080/api';

  constructor(private http: HttpClient, private cdr: ChangeDetectorRef, private router: Router) {}

  ngOnInit(): void {
    this.userEmail    = localStorage.getItem('userEmail')    || '';
    this.userName     = localStorage.getItem('userName')     || '';
    this.userDept     = localStorage.getItem('userDept')     || '';
    this.userSemester = localStorage.getItem('userSemester') || '';
    this.userPhone    = localStorage.getItem('userPhone')    || '';
    this.loadTheme();
    this.loadAll();
  }

  loadTheme(): void { const s=localStorage.getItem('studentTheme'); this.theme=s==='dark'?'dark':'light'; this.applyTheme(); }
  toggleTheme(): void { this.theme=this.theme==='dark'?'light':'dark'; this.applyTheme(); }
  applyTheme(): void { document.documentElement.setAttribute('data-theme',this.theme); document.body.setAttribute('data-theme',this.theme); localStorage.setItem('studentTheme',this.theme); }

  loadAll(): void {
    this.loading=true; this.error='';
    this.http.get<any[]>(`${this.baseUrl}/management/my-subjects?email=${this.userEmail}`).subscribe({
      next:d=>{this.mySubjects=Array.isArray(d)?d:[];this.loading=false;this.cdr.detectChanges();},
      error:()=>{this.error='Could not load your courses.';this.loading=false;this.cdr.detectChanges();}
    });
    this.http.get<any[]>(`${this.baseUrl}/management/subjects`).subscribe({next:d=>{this.allSubjects=d;this.cdr.detectChanges();},error:()=>{}});
    this.http.get<any[]>(`${this.baseUrl}/routine`).subscribe({next:d=>{this.routines=d;this.cdr.detectChanges();},error:()=>{}});
  }

  setTab(tab: typeof this.activeTab): void {
    this.activeTab=tab; this.loadAll();
    if(tab==='attendance') this.loadMyAttendanceSummary();
    if(tab==='meetings') this.loadActiveMeetings();
    if(tab==='chat') this.initChat();
    if(tab==='notices') this.loadNotices();
    if(tab!=='chat') this.stopChatPolling();
  }

  logout(): void { this.stopChatPolling(); localStorage.clear(); this.router.navigate(['/login']); }

  // ── Notices ──
  loadNotices(): void {
    this.noticeLoading=true;
    this.http.get<any[]>(`${this.baseUrl}/notices`).subscribe({
      next:d=>{this.notices=d;this.noticeLoading=false;this.cdr.detectChanges();},
      error:()=>{this.noticeLoading=false;this.cdr.detectChanges();}
    });
  }

  // ── Chat ──
  initChat(): void {
    this.http.get<any>(`${this.baseUrl}/chat/me?email=${this.userEmail}`).subscribe({
      next:d=>{this.chatMyId=d.id;this.loadChatContacts();},error:()=>{}
    });
  }
  loadChatContacts(): void {
    this.http.get<any[]>(`${this.baseUrl}/chat/contacts?email=${this.userEmail}`).subscribe({
      next:d=>{this.chatContacts=d;this.cdr.detectChanges();},error:()=>{}
    });
  }
  selectChatContact(c:any): void {
    this.chatSelectedContact=c;c.unread=0;this.loadChatMessages();
    this.http.put(`${this.baseUrl}/chat/read?userId=${this.chatMyId}&otherId=${c.id}`,{}).subscribe();
    this.startChatPolling();
  }
  loadChatMessages(): void {
    if(!this.chatSelectedContact) return;
    this.http.get<any[]>(`${this.baseUrl}/chat/messages?userId=${this.chatMyId}&otherId=${this.chatSelectedContact.id}`).subscribe({
      next:d=>{this.chatMessages=d;this.cdr.detectChanges();setTimeout(()=>this.scrollChatBottom(),50);},error:()=>{}
    });
  }
  sendChatMessage(): void {
    if(!this.chatNewMessage.trim()||!this.chatSelectedContact) return;
    this.http.post(`${this.baseUrl}/chat/send`,{senderId:this.chatMyId,receiverId:this.chatSelectedContact.id,message:this.chatNewMessage.trim(),messageType:'CHAT'}).subscribe({
      next:()=>{this.chatNewMessage='';this.loadChatMessages();this.loadChatContacts();},error:()=>{}
    });
  }
  startChatPolling(): void { this.stopChatPolling(); this.chatPolling=setInterval(()=>this.loadChatMessages(),3000); }
  stopChatPolling(): void { if(this.chatPolling){clearInterval(this.chatPolling);this.chatPolling=null;} }
  scrollChatBottom(): void { const el=document.querySelector('.chat-messages'); if(el) el.scrollTop=el.scrollHeight; }
  isMine(msg:any):boolean { return msg.sender?.id===this.chatMyId; }

  getInitial(s:any):string { return (s?.name||s?.email||'?')[0].toUpperCase(); }
  getSubjectInitial(name:string):string { return name?name[0].toUpperCase():'?'; }
  isEnrolled(subjectId:number):boolean { return this.mySubjects.some(s=>s.id===subjectId); }
  getSubjectColor(name:string):string {
    const colors=['#1e3a8a','#064e3b','#4c1d95','#78350f','#831843','#115e59','#3730a3','#0f766e','#7c2d12','#1e40af'];
    let hash=0;for(let i=0;i<name.length;i++) hash=name.charCodeAt(i)+((hash<<5)-hash);return colors[Math.abs(hash)%colors.length];
  }
  getRoutineCell(day:string,slot:string):any { return this.routines.find(r=>r.dayOfWeek===day&&r.timeSlot===slot)||null; }
  get totalCourses():number { return this.mySubjects.length; }
  get coursesWithTeacher():number { return this.mySubjects.filter(s=>s.teacher).length; }

  // ── Attendance ──
  loadMyAttendanceSummary(): void {
    const me = this.findMyself();
    if(!me) return;
    this.attLoading=true;
    this.http.get<any[]>(`${this.baseUrl}/attendance/summary/student/${me.id}`).subscribe({
      next:data=>{this.myAttendanceSummary=data;this.attLoading=false;this.cdr.detectChanges();},
      error:()=>{this.attLoading=false;this.cdr.detectChanges();}
    });
  }

  loadAttendanceDetail(subjectId:number): void {
    this.attDetailSubjectId=subjectId;
    const me=this.findMyself();
    if(!me) return;
    this.http.get<any[]>(`${this.baseUrl}/attendance/subject/${subjectId}/student/${me.id}`).subscribe({
      next:data=>{this.myAttendanceDetail=data;this.cdr.detectChanges();},error:()=>{}
    });
  }

  private findMyself(): any {
    for(const sub of this.mySubjects) {
      const me = (sub.students||[]).find((s:any)=>s.email===this.userEmail);
      if(me) return me;
    }
    return null;
  }

  // ── Meetings ──
  loadActiveMeetings(): void {
    const ids = this.mySubjects.map(s=>s.id).join(',');
    if(!ids){this.activeMeetings=[];return;}
    this.meetingLoading=true;
    this.http.get<any[]>(`${this.baseUrl}/meetings/student?subjectIds=${ids}`).subscribe({
      next:d=>{this.activeMeetings=d;this.meetingLoading=false;this.cdr.detectChanges();},
      error:()=>{this.meetingLoading=false;this.cdr.detectChanges();}
    });
  }
  joinMeeting(m:any):void { this.activeMeetingRoom=m.roomCode;this.joinedMeetingId=m.id; }
  leaveMeeting():void { this.activeMeetingRoom='';this.joinedMeetingId=0; }
  getJitsiUrl(room:string):string { return 'https://meet.jit.si/'+room; }
}
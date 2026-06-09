import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { ManagementService } from '../services/management.service';
import { SafePipe } from '../pipes/safe.pipe';

@Component({
  selector: 'app-teacher-view',
  standalone: true,
  imports: [CommonModule, FormsModule, SafePipe],
  templateUrl: './teacher-view.component.html',
  styleUrl: './teacher-view.component.css'
})
export class TeacherViewComponent implements OnInit {

  activeTab: 'dashboard'|'my-subjects'|'students'|'routine'|'attendance'|'meetings'|'chat'|'notices'|'profile' = 'dashboard';
  theme: 'dark'|'light' = 'light';

  teacherName=''; teacherEmail=''; teacherDept=''; teacherPhone='';

  mySubjects: any[] = [];
  routines: any[] = [];
  isLoading = true;
  errorMessage = '';

  routineDays  = ['Saturday','Sunday','Monday','Tuesday','Wednesday','Thursday'];
  routineSlots = ['08:30-10:00','10:00-11:30','11:00-12:30','14:00-15:30'];

  // ── Attendance ──
  attSubjectId: number = 0;
  attDate: string = new Date().toISOString().split('T')[0];
  attRecords: any[] = [];
  attLoading = false;
  attMessage = '';
  attError = false;
  attSummary: any[] = [];
  attBulkData: {studentId:number; studentName:string; status:string}[] = [];

  // ── Meetings ──
  meetings: any[] = [];
  meetingTitle = '';
  meetingSubjectId: number = 0;
  meetingLoading = false;
  meetingMessage = '';
  meetingError = false;
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

  constructor(private managementService:ManagementService, private http:HttpClient, private cdr:ChangeDetectorRef, private router:Router) {}

  ngOnInit(): void {
    const email=localStorage.getItem('userEmail');
    if(!email){this.router.navigate(['/login']);return;}
    this.teacherEmail=email;
    this.teacherName =localStorage.getItem('userName') ||'';
    this.teacherDept =localStorage.getItem('userDept') ||'';
    this.teacherPhone=localStorage.getItem('userPhone')||'';
    this.loadTheme();
    this.loadAll();
  }

  loadTheme(): void { const s=localStorage.getItem('teacherTheme'); this.theme=s==='dark'?'dark':'light'; this.applyTheme(); }
  toggleTheme(): void { this.theme=this.theme==='dark'?'light':'dark'; this.applyTheme(); }
  applyTheme(): void { document.documentElement.setAttribute('data-theme',this.theme); document.body.setAttribute('data-theme',this.theme); localStorage.setItem('teacherTheme',this.theme); }

  loadAll(): void {
    this.isLoading=true; this.errorMessage='';
    this.managementService.getMyTeachingSubjects(this.teacherEmail).subscribe({
      next:data=>{this.mySubjects=data;this.isLoading=false;this.cdr.detectChanges();},
      error:()=>{this.errorMessage='Could not load your subjects.';this.isLoading=false;this.cdr.detectChanges();}
    });
    this.http.get<any[]>(`${this.baseUrl}/routine`).subscribe({next:d=>{this.routines=d;this.cdr.detectChanges();},error:()=>{}});
  }

  setTab(tab: typeof this.activeTab): void {
    this.activeTab=tab; this.loadAll();
    if(tab==='attendance' && this.attSubjectId){ this.loadAttendanceForDate(); this.loadAttendanceSummary(); }
    if(tab==='meetings') this.loadMeetings();
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
    this.http.get<any>(`${this.baseUrl}/chat/me?email=${this.teacherEmail}`).subscribe({
      next:d=>{this.chatMyId=d.id;this.loadChatContacts();},error:()=>{}
    });
  }
  loadChatContacts(): void {
    this.http.get<any[]>(`${this.baseUrl}/chat/contacts?email=${this.teacherEmail}`).subscribe({
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

  getInitial(s?:any):string { if(s) return (s.name||s.email||'?')[0].toUpperCase(); return (this.teacherName||this.teacherEmail||'?')[0].toUpperCase(); }
  getSubjectColor(name:string):string {
    const colors=['#1e3a8a','#064e3b','#4c1d95','#78350f','#831843','#115e59','#3730a3','#0f766e','#7c2d12','#1e40af'];
    let hash=0;for(let i=0;i<name.length;i++) hash=name.charCodeAt(i)+((hash<<5)-hash);return colors[Math.abs(hash)%colors.length];
  }
  getRoutineCell(day:string,slot:string):any { return this.routines.find(r=>r.dayOfWeek===day&&r.timeSlot===slot)||null; }

  get totalUniqueStudents():number {
    const ids=new Set<number>(); for(const sub of this.mySubjects) for(const stu of sub.students||[]) ids.add(stu.id); return ids.size;
  }
  get allUniqueStudents():any[] {
    const map=new Map<number,any>(); for(const sub of this.mySubjects) for(const stu of sub.students||[]) map.set(stu.id,stu); return Array.from(map.values());
  }

  // ── Attendance ──
  loadAttendanceForDate(): void {
    if(!this.attSubjectId) return;
    this.attLoading=true;
    this.http.get<any[]>(`${this.baseUrl}/attendance/subject/${this.attSubjectId}?date=${this.attDate}`).subscribe({
      next:data=>{ this.attRecords=data; this.buildBulkData(); this.attLoading=false; this.cdr.detectChanges(); },
      error:()=>{ this.attLoading=false; this.cdr.detectChanges(); }
    });
  }
  buildBulkData(): void {
    const sub=this.mySubjects.find(s=>s.id==this.attSubjectId);
    if(!sub){this.attBulkData=[];return;}
    this.attBulkData=(sub.students||[]).map((stu:any)=>{
      const existing=this.attRecords.find(r=>r.student?.id===stu.id);
      return{studentId:stu.id,studentName:stu.name||stu.email,status:existing?existing.status:'PRESENT'};
    });
  }
  submitBulkAttendance(): void {
    if(!this.attSubjectId||!this.attBulkData.length) return;
    this.attLoading=true; this.attMessage='';
    const payload={subjectId:this.attSubjectId,date:this.attDate,markedById:null,records:this.attBulkData.map(d=>({studentId:d.studentId,status:d.status}))};
    this.http.post(`${this.baseUrl}/attendance/mark-bulk`,payload).subscribe({
      next:()=>{this.attMessage='Attendance saved!';this.attError=false;this.attLoading=false;this.loadAttendanceSummary();this.cdr.detectChanges();},
      error:()=>{this.attMessage='Failed to save.';this.attError=true;this.attLoading=false;this.cdr.detectChanges();}
    });
  }
  loadAttendanceSummary(): void {
    if(!this.attSubjectId) return;
    this.http.get<any[]>(`${this.baseUrl}/attendance/summary/subject/${this.attSubjectId}`).subscribe({
      next:data=>{this.attSummary=data;this.cdr.detectChanges();},error:()=>{}
    });
  }
  onAttSubjectChange(): void {
    this.attRecords=[]; this.attBulkData=[]; this.attSummary=[]; this.attMessage='';
    if(this.attSubjectId){ this.loadAttendanceForDate(); this.loadAttendanceSummary(); }
  }

  // ── Meetings ──
  loadMeetings(): void {
    this.meetingLoading=true;
    this.http.get<any[]>(`${this.baseUrl}/meetings/teacher?email=${this.teacherEmail}`).subscribe({
      next:d=>{this.meetings=d;this.meetingLoading=false;this.cdr.detectChanges();},
      error:()=>{this.meetingLoading=false;this.cdr.detectChanges();}
    });
  }
  createMeeting(): void {
    if(!this.meetingTitle.trim()||!this.meetingSubjectId){this.meetingMessage='Title and subject required.';this.meetingError=true;return;}
    this.meetingLoading=true;this.meetingMessage='';
    this.http.post<any>(`${this.baseUrl}/meetings`,{title:this.meetingTitle.trim(),subjectId:this.meetingSubjectId,creatorEmail:this.teacherEmail}).subscribe({
      next:()=>{this.meetingMessage='Meeting created!';this.meetingError=false;this.meetingTitle='';this.meetingSubjectId=0;this.meetingLoading=false;this.loadMeetings();this.cdr.detectChanges();},
      error:()=>{this.meetingMessage='Failed.';this.meetingError=true;this.meetingLoading=false;this.cdr.detectChanges();}
    });
  }
  joinMeeting(m:any):void { this.activeMeetingRoom=m.roomCode;this.joinedMeetingId=m.id; }
  leaveMeeting():void { this.activeMeetingRoom='';this.joinedMeetingId=0; }
  endMeeting(id:number):void { this.http.put(`${this.baseUrl}/meetings/${id}/end`,{}).subscribe({next:()=>{this.loadMeetings();if(this.joinedMeetingId===id)this.leaveMeeting();this.cdr.detectChanges();}}); }
  getJitsiUrl(room:string):string { return 'https://meet.jit.si/'+room; }
}
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Router } from '@angular/router';
import { ManagementService } from '../services/management.service';
import { SafePipe } from '../pipes/safe.pipe';

@Component({
  selector: 'app-teacher-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, SafePipe],
  templateUrl: './teacher-dashboard.component.html',
  styleUrl: './teacher-dashboard.component.css'
})
export class TeacherDashboardComponent implements OnInit {

  activeTab: 'dashboard'|'students'|'subjects'|'teachers'|'assign'|'stats'|'routine'|'attendance'|'meetings'|'chat'|'notices' = 'dashboard';

  students: any[] = [];
  subjects: any[] = [];
  teachers: any[] = [];
  routines: any[] = [];

  routineDays  = ['Saturday','Sunday','Monday','Tuesday','Wednesday','Thursday'];
  routineSlots = ['08:30-10:00','10:00-11:30','11:00-12:30','14:00-15:30'];

  showConfirmModal = false; confirmTitle = ''; confirmMessage = '';
  confirmAction: (()=>void)|null = null;

  showAddStudentModal=false;
  newStudentName=''; newStudentEmail=''; newStudentPassword='';
  newStudentDept=''; newStudentPhone=''; newStudentSemester='';
  addStudentLoading=false; addStudentMessage=''; addStudentError=false;

  showEditStudentModal=false;
  editStudentId:number=0; editStudentName=''; editStudentEmail='';
  editStudentDept=''; editStudentPhone=''; editStudentSemester='';
  editStudentLoading=false; editStudentMessage=''; editStudentError=false;

  showAddSubjectModal=false; newSubjectName='';
  addSubjectLoading=false; addSubjectMessage=''; addSubjectError=false;

  showAddTeacherModal=false;
  newTeacherName=''; newTeacherEmail=''; newTeacherPassword=''; newTeacherDept=''; newTeacherPhone='';
  addTeacherLoading=false; addTeacherMessage=''; addTeacherError=false;

  showAssignModal=false; assignStudentId:number=0; assignSubjectId:number=0;
  assignLoading=false; assignMessage=''; assignError=false;
  selectedStudentSubjects:any[]=[]; loadingStudentSubjects=false;

  showAssignTeacherModal=false;
  assignTeacherTeacherId:number=0; assignTeacherSubjectId:number=0;
  assignTeacherLoading=false; assignTeacherMessage=''; assignTeacherError=false;

  showRoutineModal=false;
  newRoutineDay=''; newRoutineSlot='';
  newRoutineSubjectId:number=0; newRoutineTeacherId:number=0; newRoutineRoom='';
  routineLoading=false; routineMessage=''; routineError=false;

  theme: 'light'|'dark' = 'light';

  // ── Attendance ──
  attSubjectId: number = 0;
  attDate: string = new Date().toISOString().split('T')[0];
  attRecords: any[] = [];
  attLoading = false;
  attMessage = '';
  attError = false;
  attSummary: any[] = [];
  attBulkData: {studentId:number; studentName:string; status:string}[] = [];

  // ── Time-based stats ──
  timeStats: any = null;
  timeStatsLoading = false;

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
  chatLoading = false;
  chatPolling: any = null;

  // ── Notices ──
  notices: any[] = [];
  noticeTitle=''; noticeContent=''; noticePriority='NORMAL';
  noticeLoading=false; noticeMessage=''; noticeError=false;
  editingNoticeId: number = 0;

  private baseUrl = 'http://localhost:8080/api';

  constructor(
    private managementService: ManagementService,
    private http: HttpClient,
    private cdr: ChangeDetectorRef,
    private router: Router
  ) {}

  ngOnInit(): void { this.loadTheme(); this.loadData(); this.loadRoutine(); }

  loadTheme(): void { const s=localStorage.getItem('dashboardTheme'); this.theme=s==='dark'?'dark':'light'; this.applyTheme(); }
  toggleTheme(): void { this.theme=this.theme==='dark'?'light':'dark'; this.applyTheme(); }
  applyTheme(): void { document.documentElement.setAttribute('data-theme',this.theme); document.body.setAttribute('data-theme',this.theme); localStorage.setItem('dashboardTheme',this.theme); }

  logout() { localStorage.removeItem('userEmail'); localStorage.removeItem('userRole'); this.router.navigate(['/login']); }

  setTab(tab: typeof this.activeTab) {
    this.activeTab=tab; this.closeAllModals(); this.clearMessages(); this.loadData();
    if(tab==='routine') this.loadRoutine();
    if(tab==='attendance' && this.attSubjectId) { this.loadAttendanceForDate(); this.loadAttendanceSummary(); }
    if(tab==='stats') this.loadTimeStats();
    if(tab==='meetings') this.loadMeetings();
    if(tab==='chat') this.initChat();
    if(tab==='notices') this.loadNotices();
    if(tab!=='chat') this.stopChatPolling();
  }

  // ── Chat ──
  initChat(): void {
    const email=localStorage.getItem('userEmail')||'';
    this.http.get<any>(`${this.baseUrl}/chat/me?email=${email}`).subscribe({
      next:d=>{this.chatMyId=d.id;this.loadChatContacts();},error:()=>{}
    });
  }
  loadChatContacts(): void {
    const email=localStorage.getItem('userEmail')||'';
    this.http.get<any[]>(`${this.baseUrl}/chat/contacts?email=${email}`).subscribe({
      next:d=>{this.chatContacts=d;this.cdr.detectChanges();},error:()=>{}
    });
  }
  selectChatContact(c:any): void {
    this.chatSelectedContact=c;
    this.loadChatMessages();
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
    const body={senderId:this.chatMyId,receiverId:this.chatSelectedContact.id,message:this.chatNewMessage.trim(),messageType:'CHAT'};
    this.http.post(`${this.baseUrl}/chat/send`,body).subscribe({
      next:()=>{this.chatNewMessage='';this.loadChatMessages();this.loadChatContacts();},error:()=>{}
    });
  }
  startChatPolling(): void { this.stopChatPolling(); this.chatPolling=setInterval(()=>this.loadChatMessages(),3000); }
  stopChatPolling(): void { if(this.chatPolling){clearInterval(this.chatPolling);this.chatPolling=null;} }
  scrollChatBottom(): void { const el=document.querySelector('.chat-messages'); if(el) el.scrollTop=el.scrollHeight; }
  isMine(msg:any):boolean { return msg.sender?.id===this.chatMyId; }

  // ── Notices ──
  loadNotices(): void {
    this.noticeLoading=true;
    this.http.get<any[]>(`${this.baseUrl}/notices/all`).subscribe({
      next:d=>{this.notices=d;this.noticeLoading=false;this.cdr.detectChanges();},
      error:()=>{this.noticeLoading=false;this.cdr.detectChanges();}
    });
  }
  createNotice(): void {
    if(!this.noticeTitle.trim()||!this.noticeContent.trim()){this.noticeMessage='Title and content required.';this.noticeError=true;return;}
    this.noticeLoading=true;this.noticeMessage='';
    const body:any={title:this.noticeTitle.trim(),content:this.noticeContent.trim(),priority:this.noticePriority,creatorEmail:localStorage.getItem('userEmail')||''};
    if(this.editingNoticeId){
      this.http.put(`${this.baseUrl}/notices/${this.editingNoticeId}`,body).subscribe({
        next:()=>{this.noticeMessage='Notice updated!';this.noticeError=false;this.resetNoticeForm();this.noticeLoading=false;this.loadNotices();this.cdr.detectChanges();},
        error:()=>{this.noticeMessage='Failed.';this.noticeError=true;this.noticeLoading=false;this.cdr.detectChanges();}
      });
    } else {
      this.http.post(`${this.baseUrl}/notices`,body).subscribe({
        next:()=>{this.noticeMessage='Notice posted!';this.noticeError=false;this.resetNoticeForm();this.noticeLoading=false;this.loadNotices();this.cdr.detectChanges();},
        error:()=>{this.noticeMessage='Failed.';this.noticeError=true;this.noticeLoading=false;this.cdr.detectChanges();}
      });
    }
  }
  editNotice(n:any): void { this.editingNoticeId=n.id;this.noticeTitle=n.title;this.noticeContent=n.content;this.noticePriority=n.priority; }
  resetNoticeForm(): void { this.editingNoticeId=0;this.noticeTitle='';this.noticeContent='';this.noticePriority='NORMAL'; }
  toggleNoticeActive(n:any): void { this.http.put(`${this.baseUrl}/notices/${n.id}`,{active:!n.active}).subscribe({next:()=>{this.loadNotices();}}); }
  deleteNotice(id:number): void { this.openConfirm('Delete Notice','Delete this notice permanently?',()=>{this.http.delete(`${this.baseUrl}/notices/${id}`).subscribe({next:()=>{this.loadNotices();this.cdr.detectChanges();}});}); }

  loadTimeStats(): void {
    this.timeStatsLoading=true;
    this.http.get<any>(`${this.baseUrl}/attendance/stats/time-analysis`).subscribe({
      next:data=>{ this.timeStats=data; this.timeStatsLoading=false; this.cdr.detectChanges(); },
      error:()=>{ this.timeStatsLoading=false; this.cdr.detectChanges(); }
    });
  }

  clearMessages() { this.addStudentMessage=''; this.editStudentMessage=''; this.addSubjectMessage=''; this.addTeacherMessage=''; this.assignMessage=''; this.assignTeacherMessage=''; this.routineMessage=''; this.attMessage=''; }

  closeAllModals() {
    this.showAddStudentModal=false; this.showEditStudentModal=false;
    this.showAddSubjectModal=false; this.showAddTeacherModal=false;
    this.showAssignModal=false; this.showAssignTeacherModal=false;
    this.showConfirmModal=false; this.showRoutineModal=false;
    this.clearMessages();
    this.selectedStudentSubjects=[]; this.assignStudentId=0; this.assignSubjectId=0;
    this.assignTeacherTeacherId=0; this.assignTeacherSubjectId=0;
    this.newRoutineDay=''; this.newRoutineSlot=''; this.newRoutineSubjectId=0; this.newRoutineTeacherId=0; this.newRoutineRoom='';
  }

  loadData() {
    this.managementService.getStudents().subscribe({next:d=>{this.students=d;this.cdr.detectChanges();}});
    this.managementService.getSubjects().subscribe({next:d=>{this.subjects=d;this.cdr.detectChanges();}});
    this.managementService.getTeachers().subscribe({next:d=>{this.teachers=d;this.cdr.detectChanges();}});
  }

  loadRoutine() { this.http.get<any[]>(`${this.baseUrl}/routine`).subscribe({next:d=>{this.routines=d;this.cdr.detectChanges();},error:()=>{}}); }

  openConfirm(title:string,message:string,action:()=>void) { this.confirmTitle=title; this.confirmMessage=message; this.confirmAction=action; this.showConfirmModal=true; }
  onConfirmYes() { this.showConfirmModal=false; if(this.confirmAction) this.confirmAction(); this.confirmAction=null; }
  onConfirmNo() { this.showConfirmModal=false; this.confirmAction=null; }

  // ── Stats ──
  get totalEnrollments():number { return this.students.reduce((s,e)=>s+(e.subjects?.length||0),0); }
  get avgSubjectsPerStudent():string { return this.students.length?(this.totalEnrollments/this.students.length).toFixed(1):'0'; }
  get mostPopularSubject():string {
    if(!this.subjects.length||!this.students.length) return '—';
    const c:Record<number,number>={}; for(const s of this.students) for(const sub of s.subjects||[]) c[sub.id]=(c[sub.id]||0)+1;
    let maxId=-1,maxCount=0; for(const[id,count] of Object.entries(c)) if(+count>maxCount){maxCount=+count;maxId=+id;}
    return this.subjects.find(s=>s.id===maxId)?.name??'—';
  }
  get topSubjectPct():number {
    if(!this.students.length) return 0;
    const c:Record<number,number>={}; for(const s of this.students) for(const sub of s.subjects||[]) c[sub.id]=(c[sub.id]||0)+1;
    const max=Math.max(...Object.values(c),0); return max?Math.round((max/this.students.length)*100):0;
  }
  get subjectEnrollmentData():{name:string;count:number;pct:number}[] {
    if(!this.subjects.length) return [];
    const c:Record<number,number>={}; for(const s of this.students) for(const sub of s.subjects||[]) c[sub.id]=(c[sub.id]||0)+1;
    const max=Math.max(...Object.values(c),1);
    return this.subjects.map(sub=>({name:sub.name,count:c[sub.id]||0,pct:Math.round(((c[sub.id]||0)/max)*100)})).sort((a,b)=>b.count-a.count);
  }
  get studentLoadData():{name:string;count:number;pct:number}[] {
    if(!this.students.length) return [];
    const max=Math.max(...this.students.map(s=>s.subjects?.length||0),1);
    return this.students.map(s=>({name:s.name||s.email,count:s.subjects?.length||0,pct:Math.round(((s.subjects?.length||0)/max)*100)})).sort((a,b)=>b.count-a.count);
  }
  get enrollmentDistribution():{label:string;count:number}[] {
    const d:Record<string,number>={'0 subjects':0,'1–2 subjects':0,'3–4 subjects':0,'5+ subjects':0};
    for(const s of this.students){const n=s.subjects?.length||0;if(n===0)d['0 subjects']++;else if(n<=2)d['1–2 subjects']++;else if(n<=4)d['3–4 subjects']++;else d['5+ subjects']++;}
    return Object.entries(d).map(([label,count])=>({label,count}));
  }
  get departmentData():{dept:string;count:number;pct:number}[] {
    const map:Record<string,number>={}; for(const s of this.students){const d=s.department||'Unknown';map[d]=(map[d]||0)+1;}
    const total=this.students.length||1;
    return Object.entries(map).map(([dept,count])=>({dept,count,pct:Math.round(count/total*100)})).sort((a,b)=>b.count-a.count);
  }
  get subjectsWithTeacher():number { return this.subjects.filter(s=>s.teacher).length; }
  getTeacherWorkload():{name:string;count:number;pct:number}[] {
    if(!this.teachers.length) return [];
    const max=Math.max(...this.teachers.map(t=>this.getSubjectsForTeacher(t.id).length),1);
    return this.teachers.map(t=>({name:t.name||t.email,count:this.getSubjectsForTeacher(t.id).length,pct:Math.round(this.getSubjectsForTeacher(t.id).length/max*100)})).sort((a,b)=>b.count-a.count);
  }
  getPieColor(i:number):string { return ['#E05C5C','#D4A853','#7C9EF0','#5CBF8A','#B48EF0','#F0C97A'][i%6]; }
  getPieSegments():{path:string;color:string}[] {
    const dist=this.enrollmentDistribution; const total=dist.reduce((s,d)=>s+d.count,0); if(!total) return [];
    const colors=['#E05C5C','#D4A853','#7C9EF0','#5CBF8A']; const cx=60,cy=60,r=46; let startAngle=-Math.PI/2;
    return dist.map((d,i)=>{const pct=d.count/total;if(pct===0)return null;const angle=pct*2*Math.PI;const x1=cx+r*Math.cos(startAngle);const y1=cy+r*Math.sin(startAngle);const x2=cx+r*Math.cos(startAngle+angle);const y2=cy+r*Math.sin(startAngle+angle);const large=angle>Math.PI?1:0;const path=pct>=1?`M ${cx-r} ${cy} a ${r} ${r} 0 1 1 ${r*2} 0 a ${r} ${r} 0 1 1 -${r*2} 0`:`M ${cx} ${cy} L ${x1} ${y1} A ${r} ${r} 0 ${large} 1 ${x2} ${y2} Z`;startAngle+=angle;return{path,color:colors[i%colors.length]};}).filter((s):s is{path:string;color:string}=>s!==null);
  }

  // ── Helpers ──
  getInitial(s:any):string { return (s.name||s.email||'?')[0].toUpperCase(); }
  getDisplayName(s:any):string { return s.name||s.email||'Unknown'; }
  getSubjectsForTeacher(tid:number):any[] { return this.subjects.filter(s=>s.teacher?.id===tid); }
  formatStudentId(id:number):string { return 'STU-'+String(id).padStart(5,'0'); }
  getSubjectColor(name:string):string {
    const colors=['#1e3a8a','#064e3b','#4c1d95','#78350f','#831843','#115e59','#3730a3','#0f766e'];
    let hash=0;for(let i=0;i<name.length;i++) hash=name.charCodeAt(i)+((hash<<5)-hash);return colors[Math.abs(hash)%colors.length];
  }
  getRoutineCell(day:string,slot:string):any { return this.routines.find(r=>r.dayOfWeek===day&&r.timeSlot===slot)||null; }

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
    const sub=this.subjects.find(s=>s.id==this.attSubjectId);
    if(!sub){this.attBulkData=[];return;}
    const enrolled:any[]=sub.students||[];
    this.attBulkData=enrolled.map(stu=>{
      const existing=this.attRecords.find(r=>r.student?.id===stu.id);
      return{studentId:stu.id,studentName:stu.name||stu.email,status:existing?existing.status:'PRESENT'};
    });
  }
  submitBulkAttendance(): void {
    if(!this.attSubjectId||!this.attBulkData.length) return;
    this.attLoading=true; this.attMessage='';
    const payload={subjectId:this.attSubjectId,date:this.attDate,markedById:null,records:this.attBulkData.map(d=>({studentId:d.studentId,status:d.status}))};
    this.http.post(`${this.baseUrl}/attendance/mark-bulk`,payload).subscribe({
      next:()=>{ this.attMessage='Attendance saved!'; this.attError=false; this.attLoading=false; this.loadAttendanceSummary(); this.cdr.detectChanges(); },
      error:()=>{ this.attMessage='Failed to save.'; this.attError=true; this.attLoading=false; this.cdr.detectChanges(); }
    });
  }
  loadAttendanceSummary(): void {
    if(!this.attSubjectId) return;
    this.http.get<any[]>(`${this.baseUrl}/attendance/summary/subject/${this.attSubjectId}`).subscribe({
      next:data=>{ this.attSummary=data; this.cdr.detectChanges(); }, error:()=>{}
    });
  }
  onAttSubjectChange(): void {
    this.attRecords=[]; this.attBulkData=[]; this.attSummary=[]; this.attMessage='';
    if(this.attSubjectId){ this.loadAttendanceForDate(); this.loadAttendanceSummary(); }
  }

  // ── Meetings ──
  loadMeetings(): void {
    this.meetingLoading=true;
    this.http.get<any[]>(`${this.baseUrl}/meetings`).subscribe({
      next:d=>{this.meetings=d;this.meetingLoading=false;this.cdr.detectChanges();},
      error:()=>{this.meetingLoading=false;this.cdr.detectChanges();}
    });
  }
  createMeeting(): void {
    if(!this.meetingTitle.trim()||!this.meetingSubjectId){this.meetingMessage='Title and subject required.';this.meetingError=true;return;}
    this.meetingLoading=true; this.meetingMessage='';
    const body={title:this.meetingTitle.trim(),subjectId:this.meetingSubjectId,creatorEmail:localStorage.getItem('userEmail')||''};
    this.http.post<any>(`${this.baseUrl}/meetings`,body).subscribe({
      next:m=>{this.meetingMessage='Meeting created!';this.meetingError=false;this.meetingTitle='';this.meetingSubjectId=0;this.meetingLoading=false;this.loadMeetings();this.cdr.detectChanges();},
      error:()=>{this.meetingMessage='Failed to create.';this.meetingError=true;this.meetingLoading=false;this.cdr.detectChanges();}
    });
  }
  joinMeeting(m:any): void { this.activeMeetingRoom=m.roomCode; this.joinedMeetingId=m.id; }
  leaveMeeting(): void { this.activeMeetingRoom=''; this.joinedMeetingId=0; }
  endMeeting(id:number): void {
    this.http.put(`${this.baseUrl}/meetings/${id}/end`,{}).subscribe({next:()=>{this.loadMeetings();if(this.joinedMeetingId===id)this.leaveMeeting();this.cdr.detectChanges();}});
  }
  deleteMeeting(id:number): void {
    this.openConfirm('Delete Meeting','Delete this meeting?',()=>{
      this.http.delete(`${this.baseUrl}/meetings/${id}`).subscribe({next:()=>{this.loadMeetings();if(this.joinedMeetingId===id)this.leaveMeeting();this.cdr.detectChanges();}});
    });
  }
  getJitsiUrl(room:string):string { return 'https://meet.jit.si/'+room; }

  // ── Assignment & Forms ──
  onAssignStudentChange() {
    this.assignSubjectId=0;this.selectedStudentSubjects=[];if(!this.assignStudentId)return;
    this.loadingStudentSubjects=true;
    this.http.get<any[]>(`${this.baseUrl}/management/student-details/${this.assignStudentId}`).subscribe({
      next:d=>{this.selectedStudentSubjects=d;this.loadingStudentSubjects=false;this.cdr.detectChanges();},error:()=>{this.loadingStudentSubjects=false;}
    });
  }
  isAlreadyAssigned(subjectId:number):boolean { return this.selectedStudentSubjects.some(s=>s.id===subjectId); }
  get availableSubjectsForAssign():any[] { return this.subjects.filter(s=>!this.isAlreadyAssigned(s.id)); }

  openEditStudent(s:any) { this.editStudentId=s.id;this.editStudentName=s.name||'';this.editStudentEmail=s.email||'';this.editStudentDept=s.department||'';this.editStudentPhone=s.phone||'';this.editStudentSemester=s.semester||'';this.editStudentMessage='';this.editStudentError=false;this.showEditStudentModal=true; }

  addStudent() {
    if(!this.newStudentEmail||!this.newStudentPassword){this.addStudentMessage='Email and password required.';this.addStudentError=true;return;}
    this.addStudentLoading=true;
    const body:any={email:this.newStudentEmail.trim(),password:this.newStudentPassword,role:'STUDENT'};
    if(this.newStudentName.trim()) body.name=this.newStudentName.trim();
    if(this.newStudentDept.trim()) body.department=this.newStudentDept.trim();
    if(this.newStudentPhone.trim()) body.phone=this.newStudentPhone.trim();
    if(this.newStudentSemester.trim()) body.semester=this.newStudentSemester.trim();
    this.http.post(`${this.baseUrl}/auth/signup`,body).subscribe({
      next:()=>{this.addStudentMessage='Student added!';this.addStudentError=false;this.newStudentName=this.newStudentEmail=this.newStudentPassword='';this.newStudentDept=this.newStudentPhone=this.newStudentSemester='';this.addStudentLoading=false;this.loadData();this.cdr.detectChanges();setTimeout(()=>{this.closeAllModals();},1500);},
      error:err=>{this.addStudentMessage=err.error||'Failed.';this.addStudentError=true;this.addStudentLoading=false;this.cdr.detectChanges();}
    });
  }
  saveEditStudent() {
    this.editStudentLoading=true;this.editStudentMessage='';
    const body:any={};
    if(this.editStudentName.trim()) body.name=this.editStudentName.trim();
    if(this.editStudentDept.trim()) body.department=this.editStudentDept.trim();
    if(this.editStudentPhone.trim()) body.phone=this.editStudentPhone.trim();
    if(this.editStudentSemester.trim()) body.semester=this.editStudentSemester.trim();
    this.http.put(`${this.baseUrl}/management/users/${this.editStudentId}`,body).subscribe({
      next:()=>{this.editStudentMessage='Saved!';this.editStudentError=false;this.editStudentLoading=false;this.loadData();this.cdr.detectChanges();setTimeout(()=>{this.closeAllModals();},1200);},
      error:()=>{this.editStudentMessage='Failed to save.';this.editStudentError=true;this.editStudentLoading=false;this.cdr.detectChanges();}
    });
  }
  addSubject() {
    if(!this.newSubjectName.trim()){this.addSubjectMessage='Name required.';this.addSubjectError=true;return;}
    this.addSubjectLoading=true;
    this.http.post(`${this.baseUrl}/subjects`,{name:this.newSubjectName.trim()}).subscribe({
      next:()=>{this.addSubjectMessage='Subject added!';this.addSubjectError=false;this.newSubjectName='';this.addSubjectLoading=false;this.loadData();this.cdr.detectChanges();setTimeout(()=>{this.closeAllModals();},1500);},
      error:()=>{this.addSubjectMessage='Failed.';this.addSubjectError=true;this.addSubjectLoading=false;this.cdr.detectChanges();}
    });
  }
  addTeacher() {
    if(!this.newTeacherEmail||!this.newTeacherPassword){this.addTeacherMessage='Email and password required.';this.addTeacherError=true;return;}
    this.addTeacherLoading=true;
    const body:any={email:this.newTeacherEmail.trim(),password:this.newTeacherPassword,role:'TEACHER'};
    if(this.newTeacherName.trim()) body.name=this.newTeacherName.trim();
    if(this.newTeacherDept.trim()) body.department=this.newTeacherDept.trim();
    if(this.newTeacherPhone.trim()) body.phone=this.newTeacherPhone.trim();
    this.http.post(`${this.baseUrl}/auth/signup`,body).subscribe({
      next:()=>{this.addTeacherMessage='Teacher added!';this.addTeacherError=false;this.newTeacherName=this.newTeacherEmail=this.newTeacherPassword=this.newTeacherDept=this.newTeacherPhone='';this.addTeacherLoading=false;this.loadData();this.cdr.detectChanges();setTimeout(()=>{this.closeAllModals();},1500);},
      error:err=>{this.addTeacherMessage=err.error||'Failed.';this.addTeacherError=true;this.addTeacherLoading=false;this.cdr.detectChanges();}
    });
  }
  assign() {
    if(!this.assignStudentId||!this.assignSubjectId){this.assignMessage='Select both.';this.assignError=true;return;}
    if(this.isAlreadyAssigned(this.assignSubjectId)){this.assignMessage='Already assigned!';this.assignError=true;return;}
    this.assignLoading=true;
    const params=new HttpParams().set('studentId',this.assignStudentId.toString()).set('subjectId',this.assignSubjectId.toString());
    this.http.post(`${this.baseUrl}/management/assign`,{},{params}).subscribe({
      next:()=>{this.assignMessage='Assigned!';this.assignError=false;this.assignSubjectId=0;this.assignLoading=false;this.onAssignStudentChange();this.loadData();this.cdr.detectChanges();},
      error:()=>{this.assignMessage='Failed.';this.assignError=true;this.assignLoading=false;this.cdr.detectChanges();}
    });
  }
  assignTeacher() {
    if(!this.assignTeacherTeacherId||!this.assignTeacherSubjectId){this.assignTeacherMessage='Select both.';this.assignTeacherError=true;return;}
    this.assignTeacherLoading=true;
    const params=new HttpParams().set('teacherId',this.assignTeacherTeacherId.toString()).set('subjectId',this.assignTeacherSubjectId.toString());
    this.http.post(`${this.baseUrl}/management/assign-teacher`,{},{params}).subscribe({
      next:()=>{this.assignTeacherMessage='Assigned!';this.assignTeacherError=false;this.assignTeacherTeacherId=0;this.assignTeacherSubjectId=0;this.assignTeacherLoading=false;this.loadData();this.cdr.detectChanges();},
      error:()=>{this.assignTeacherMessage='Failed.';this.assignTeacherError=true;this.assignTeacherLoading=false;this.cdr.detectChanges();}
    });
  }
  addRoutine() {
    if(!this.newRoutineDay||!this.newRoutineSlot||!this.newRoutineSubjectId||!this.newRoutineTeacherId){this.routineMessage='Complete all required fields.';this.routineError=true;return;}
    this.routineLoading=true;this.routineMessage='';
    const payload={dayOfWeek:this.newRoutineDay,timeSlot:this.newRoutineSlot,subjectId:this.newRoutineSubjectId,teacherId:this.newRoutineTeacherId,roomNo:this.newRoutineRoom.trim()};
    this.http.post(`${this.baseUrl}/routine`,payload).subscribe({
      next:()=>{this.routineMessage='Routine saved!';this.routineError=false;this.routineLoading=false;this.loadRoutine();this.cdr.detectChanges();setTimeout(()=>{this.closeAllModals();},1200);},
      error:err=>{this.routineMessage=err.error?.message||err.error||'Failed.';this.routineError=true;this.routineLoading=false;this.cdr.detectChanges();}
    });
  }
  deleteRoutineCell(day:string,slot:string) {
    const cell=this.getRoutineCell(day,slot); if(!cell) return;
    this.openConfirm('Remove Slot',`Remove ${day} ${slot}?`,()=>{this.http.delete(`${this.baseUrl}/routine/${cell.id}`).subscribe({next:()=>{this.loadRoutine();this.cdr.detectChanges();}});});
  }
  removeSubjectFromStudent(studentId:number,subjectId:number,subjectName:string) { this.openConfirm('Remove Subject',`Remove "${subjectName}" from this student?`,()=>{this.http.delete(`${this.baseUrl}/management/student/${studentId}/subject/${subjectId}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});}); }
  removeSubjectFromTeacher(teacherId:number,subjectId:number,subjectName:string) { this.openConfirm('Remove Subject',`Remove "${subjectName}" from this teacher?`,()=>{this.http.delete(`${this.baseUrl}/management/teacher/${teacherId}/subject/${subjectId}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});}); }
  deleteStudent(id:number,name:string) { this.openConfirm('Delete Student',`Delete "${name}"? This cannot be undone.`,()=>{this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});}); }
  deleteSubject(id:number,name:string) { this.openConfirm('Delete Subject',`Delete "${name}"? This cannot be undone.`,()=>{this.http.delete(`${this.baseUrl}/subjects/${id}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});}); }
  deleteTeacher(id:number,name:string) { this.openConfirm('Delete Teacher',`Delete teacher "${name}"? This cannot be undone.`,()=>{this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});}); }
}
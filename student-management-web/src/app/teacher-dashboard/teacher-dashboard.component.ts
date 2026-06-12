import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Router } from '@angular/router';
import { ManagementService } from '../services/management.service';
import { SafePipe } from '../pipes/safe.pipe';
import * as d3 from 'd3';

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
    if(tab==='stats') { this.loadTimeStats(); this.loadData(); setTimeout(()=>this.renderD3Charts(),600); }
    if(tab==='meetings') this.loadMeetings();
    if(tab==='chat') this.initChat();
    if(tab==='notices') this.loadNotices();
    if(tab!=='chat') this.stopChatPolling();
    if(tab!=='stats' && this.particleAnimId) { cancelAnimationFrame(this.particleAnimId); this.particleAnimId=null; }
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
      next:data=>{ this.timeStats=data; this.timeStatsLoading=false; this.cdr.detectChanges(); setTimeout(()=>this.renderD3Charts(),300); },
      error:()=>{ this.timeStatsLoading=false; this.cdr.detectChanges(); }
    });
  }

  // ═══════════════════════════════════════════════
  // D3 VISUALIZATIONS
  // ═══════════════════════════════════════════════

  renderD3Charts(): void {
    this.renderParticles();
    this.animateCounters();
    this.renderAttendanceArea();
    this.renderSunburst();
    this.renderNetworkGraph();
    this.renderAnimatedDonut();
    this.renderTreemap();
    this.renderRadialBars();
    this.renderBubbleChart();
    this.renderChordDiagram();
    this.renderGaugeChart();
    this.renderLollipopChart();
    this.renderCirclePacking();
  }

  // ── Particle network in hero ──
  particleAnimId: any = null;
  renderParticles(): void {
    const canvas = document.getElementById('stats-particles') as HTMLCanvasElement;
    if (!canvas) return;
    if (this.particleAnimId) cancelAnimationFrame(this.particleAnimId);
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    const parent = canvas.parentElement!;
    canvas.width = parent.clientWidth;
    canvas.height = parent.clientHeight;

    const W = canvas.width, H = canvas.height;
    const N = 50;
    const pts = Array.from({ length: N }, () => ({
      x: Math.random() * W, y: Math.random() * H,
      vx: (Math.random() - 0.5) * 0.6, vy: (Math.random() - 0.5) * 0.6,
      r: Math.random() * 2 + 1
    }));
    const isLight = document.documentElement.getAttribute('data-theme') === 'light';
    const dotColor = isLight ? 'rgba(184,134,11,' : 'rgba(212,168,83,';
    const lineColor = isLight ? 'rgba(184,134,11,' : 'rgba(212,168,83,';

    const tick = () => {
      ctx.clearRect(0, 0, W, H);
      for (const p of pts) {
        p.x += p.vx; p.y += p.vy;
        if (p.x < 0 || p.x > W) p.vx *= -1;
        if (p.y < 0 || p.y > H) p.vy *= -1;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fillStyle = dotColor + '0.6)';
        ctx.fill();
      }
      for (let i = 0; i < N; i++)
        for (let j = i + 1; j < N; j++) {
          const dx = pts[i].x - pts[j].x, dy = pts[i].y - pts[j].y;
          const dist = Math.sqrt(dx * dx + dy * dy);
          if (dist < 110) {
            ctx.beginPath();
            ctx.moveTo(pts[i].x, pts[i].y);
            ctx.lineTo(pts[j].x, pts[j].y);
            ctx.strokeStyle = lineColor + (0.25 * (1 - dist / 110)) + ')';
            ctx.lineWidth = 0.8;
            ctx.stroke();
          }
        }
      this.particleAnimId = requestAnimationFrame(tick);
    };
    tick();
  }

  // ── Count-up animation for KPI numbers ──
  animateCounters(): void {
    const animate = (id: string, target: number, suffix = '') => {
      const el = document.getElementById(id);
      if (!el) return;
      const dur = 1600, start = performance.now();
      const step = (now: number) => {
        const t = Math.min((now - start) / dur, 1);
        const eased = 1 - Math.pow(1 - t, 3); // ease-out cubic
        el.textContent = Math.round(eased * target) + suffix;
        if (t < 1) requestAnimationFrame(step);
      };
      requestAnimationFrame(step);
    };
    animate('counter-students', this.students.length);
    animate('counter-subjects', this.subjects.length);
    animate('counter-teachers', this.teachers.length);
    animate('counter-enrollments', this.totalEnrollments);
    animate('counter-rate', this.timeStats?.overallRate || 0, '%');
  }

  // ── Animated gradient area chart (attendance trend) ──
  renderAttendanceArea(): void {
    const el = document.getElementById('d3-area');
    if (!el || !this.timeStats?.dailyStats) return;
    el.innerHTML = '';
    const data = this.timeStats.dailyStats.filter((d: any) => true);
    const margin = { top: 20, right: 20, bottom: 30, left: 40 };
    const w = (el.clientWidth || 800) - margin.left - margin.right;
    const h = 240 - margin.top - margin.bottom;

    const svg = d3.select(el).append('svg')
      .attr('width', w + margin.left + margin.right)
      .attr('height', h + margin.top + margin.bottom)
      .append('g').attr('transform', `translate(${margin.left},${margin.top})`);

    const x = d3.scalePoint().domain(data.map((d: any) => d.date)).range([0, w]);
    const y = d3.scaleLinear().domain([0, 100]).range([h, 0]);

    // Gradient
    const grad = svg.append('defs').append('linearGradient')
      .attr('id', 'area-grad').attr('x1', '0').attr('y1', '0').attr('x2', '0').attr('y2', '1');
    grad.append('stop').attr('offset', '0%').attr('stop-color', '#D4A853').attr('stop-opacity', 0.5);
    grad.append('stop').attr('offset', '100%').attr('stop-color', '#D4A853').attr('stop-opacity', 0.02);

    // Grid
    svg.append('g').selectAll('line').data(y.ticks(5)).join('line')
      .attr('x1', 0).attr('x2', w).attr('y1', (d: any) => y(d)).attr('y2', (d: any) => y(d))
      .attr('stroke', '#2E2E3A').attr('stroke-width', 0.5).attr('stroke-dasharray', '4 4');

    const area = d3.area<any>()
      .x((d: any) => x(d.date) || 0)
      .y0(h)
      .y1((d: any) => y(d.percentage))
      .curve(d3.curveMonotoneX);

    const line = d3.line<any>()
      .x((d: any) => x(d.date) || 0)
      .y((d: any) => y(d.percentage))
      .curve(d3.curveMonotoneX);

    // Area with fade-in
    svg.append('path').datum(data).attr('d', area)
      .attr('fill', 'url(#area-grad)').attr('opacity', 0)
      .transition().duration(1200).delay(500).attr('opacity', 1);

    // Animated line draw
    const path = svg.append('path').datum(data).attr('d', line)
      .attr('fill', 'none').attr('stroke', '#D4A853').attr('stroke-width', 2.5)
      .attr('stroke-linecap', 'round');
    const totalLen = (path.node() as SVGPathElement).getTotalLength();
    path.attr('stroke-dasharray', totalLen).attr('stroke-dashoffset', totalLen)
      .transition().duration(1800).ease(d3.easeCubicOut).attr('stroke-dashoffset', 0);

    // Dots on days with classes
    svg.selectAll('.area-dot').data(data.filter((d: any) => d.total > 0)).join('circle')
      .attr('cx', (d: any) => x(d.date) || 0).attr('cy', (d: any) => y(d.percentage))
      .attr('r', 0).attr('fill', '#0F0F13').attr('stroke', '#D4A853').attr('stroke-width', 2)
      .transition().duration(400).delay((_: any, i: number) => 1200 + i * 60).attr('r', 4);

    // X axis (every 5th label)
    svg.append('g').selectAll('text').data(data.filter((_: any, i: number) => i % 5 === 0)).join('text')
      .attr('x', (d: any) => x(d.date) || 0).attr('y', h + 20)
      .attr('text-anchor', 'middle').attr('fill', '#9A9489').attr('font-size', '9px')
      .text((d: any) => d.date.substring(5));

    // Y axis
    svg.append('g').selectAll('text').data(y.ticks(5)).join('text')
      .attr('x', -8).attr('y', (d: any) => y(d) + 3)
      .attr('text-anchor', 'end').attr('fill', '#9A9489').attr('font-size', '9px')
      .text((d: any) => d + '%');
  }

  // ── Sunburst (Department → Subject → Students) ──
  renderSunburst(): void {
    const el = document.getElementById('d3-sunburst');
    if (!el) return;
    el.innerHTML = '';
    const w = 480, h = 480, radius = Math.min(w, h) / 2 - 10;

    // Build hierarchy
    const depts: any = {};
    this.subjects.forEach(sub => {
      const deptName = sub.teacher?.department || 'Unassigned';
      if (!depts[deptName]) depts[deptName] = [];
      const children = (sub.students || []).map((s: any) => ({ name: (s.name || s.email).split(' ')[0], value: 1 }));
      depts[deptName].push({ name: sub.name, children: children.length ? children : [{ name: '—', value: 0.5 }] });
    });
    const hierarchy = { name: 'BUP', children: Object.entries(depts).map(([d, subs]) => ({ name: d, children: subs })) };

    const root = d3.hierarchy(hierarchy).sum((d: any) => d.value || 0);
    d3.partition<any>().size([2 * Math.PI, radius])(root);

    const svg = d3.select(el).append('svg').attr('width', w).attr('height', h)
      .append('g').attr('transform', `translate(${w/2},${h/2})`);

    const palette = ['#D4A853', '#7C9EF0', '#5CBF8A', '#B48EF0', '#E05C5C', '#F0C97A'];
    const colorOf = (d: any): string => {
      let node = d;
      while (node.depth > 1) node = node.parent;
      const idx = root.children?.indexOf(node) ?? 0;
      return palette[idx % palette.length];
    };

    const arc = d3.arc<any>()
      .startAngle((d: any) => d.x0).endAngle((d: any) => d.x1)
      .padAngle(0.01).padRadius(radius / 2)
      .innerRadius((d: any) => d.y0).outerRadius((d: any) => d.y1 - 2);

    const tooltip = d3.select(el).append('div')
      .style('position', 'absolute').style('pointer-events', 'none')
      .style('background', 'var(--surface-hi)').style('border', '1px solid var(--border)')
      .style('border-radius', '8px').style('padding', '8px 12px')
      .style('font-size', '12px').style('color', 'var(--cream)')
      .style('opacity', '0').style('transition', 'opacity .15s').style('z-index', '10');

    svg.selectAll('path').data(root.descendants().filter((d: any) => d.depth > 0)).join('path')
      .attr('d', arc as any)
      .attr('fill', (d: any) => colorOf(d))
      .attr('fill-opacity', (d: any) => d.depth === 1 ? 0.9 : d.depth === 2 ? 0.65 : 0.4)
      .attr('cursor', 'pointer')
      .on('mouseover', function(this: any, event: any, d: any) {
        d3.select(this).attr('fill-opacity', 1);
        tooltip.style('opacity', '1').html(`<strong>${d.data.name}</strong><br>${d.value} student${d.value !== 1 ? 's' : ''}`);
      })
      .on('mousemove', (event: any) => {
        const rect = el.getBoundingClientRect();
        tooltip.style('left', (event.clientX - rect.left + 12) + 'px').style('top', (event.clientY - rect.top - 10) + 'px');
      })
      .on('mouseout', function(this: any, _: any, d: any) {
        d3.select(this).attr('fill-opacity', d.depth === 1 ? 0.9 : d.depth === 2 ? 0.65 : 0.4);
        tooltip.style('opacity', '0');
      })
      .attr('opacity', 0)
      .transition().duration(700).delay((d: any) => d.depth * 250).attr('opacity', 1);

    // Labels for big arcs
    svg.selectAll('.sb-label').data(root.descendants().filter((d: any) => d.depth > 0 && d.depth < 3 && (d.x1 - d.x0) > 0.25)).join('text')
      .attr('transform', (d: any) => {
        const angle = (d.x0 + d.x1) / 2 * 180 / Math.PI - 90;
        const r = (d.y0 + d.y1) / 2;
        return `rotate(${angle}) translate(${r},0) rotate(${angle > 90 ? 180 : 0})`;
      })
      .attr('text-anchor', 'middle').attr('dy', '0.35em')
      .attr('fill', '#fff').attr('font-size', (d: any) => d.depth === 1 ? '12px' : '9px')
      .attr('font-weight', (d: any) => d.depth === 1 ? '700' : '500')
      .attr('pointer-events', 'none')
      .text((d: any) => d.data.name.length > 14 ? d.data.name.substring(0, 14) + '…' : d.data.name)
      .attr('opacity', 0)
      .transition().duration(600).delay((d: any) => d.depth * 250 + 400).attr('opacity', 1);

    // Center label
    svg.append('text').attr('text-anchor', 'middle').attr('dy', '-0.2em')
      .attr('fill', '#D4A853').attr('font-size', '24px').attr('font-weight', '900').text('BUP');
    svg.append('text').attr('text-anchor', 'middle').attr('dy', '1.4em')
      .attr('fill', '#9A9489').attr('font-size', '10px').text('hover to explore');
  }

  // ── 1. Force-Directed Network Graph ──
  renderNetworkGraph(): void {
    const el = document.getElementById('d3-network');
    if (!el) return;
    el.innerHTML = '';
    const w = el.clientWidth || 700, h = 420;
    const svg = d3.select(el).append('svg').attr('width', w).attr('height', h);

    // Build nodes & links
    const nodes: any[] = [];
    const links: any[] = [];
    const nodeMap = new Map<string, any>();

    this.subjects.forEach(sub => {
      const sid = 'sub-' + sub.id;
      if (!nodeMap.has(sid)) { const n = { id: sid, label: sub.name, type: 'subject', r: 22 }; nodes.push(n); nodeMap.set(sid, n); }
      if (sub.teacher) {
        const tid = 'tea-' + sub.teacher.id;
        if (!nodeMap.has(tid)) { const n = { id: tid, label: sub.teacher.name || sub.teacher.email, type: 'teacher', r: 16 }; nodes.push(n); nodeMap.set(tid, n); }
        links.push({ source: tid, target: sid });
      }
      (sub.students || []).forEach((stu: any) => {
        const stid = 'stu-' + stu.id;
        if (!nodeMap.has(stid)) { const n = { id: stid, label: stu.name || stu.email, type: 'student', r: 12 }; nodes.push(n); nodeMap.set(stid, n); }
        links.push({ source: stid, target: sid });
      });
    });

    if (!nodes.length) return;

    const colors: any = { subject: '#D4A853', teacher: '#B48EF0', student: '#5CBF8A' };
    const sim = d3.forceSimulation(nodes)
      .force('link', d3.forceLink(links).id((d: any) => d.id).distance(80))
      .force('charge', d3.forceManyBody().strength(-200))
      .force('center', d3.forceCenter(w / 2, h / 2))
      .force('collision', d3.forceCollide().radius((d: any) => d.r + 6));

    const link = svg.append('g').selectAll('line').data(links).join('line')
      .attr('stroke', '#2E2E3A').attr('stroke-width', 1.5).attr('stroke-opacity', 0.5);

    const node = svg.append('g').selectAll('g').data(nodes).join('g').call(
      d3.drag<any, any>().on('start', (e: any, d: any) => { if (!e.active) sim.alphaTarget(0.3).restart(); d.fx = d.x; d.fy = d.y; })
        .on('drag', (e: any, d: any) => { d.fx = e.x; d.fy = e.y; })
        .on('end', (e: any, d: any) => { if (!e.active) sim.alphaTarget(0); d.fx = null; d.fy = null; })
    );

    node.append('circle').attr('r', (d: any) => d.r)
      .attr('fill', (d: any) => colors[d.type]).attr('stroke', '#fff').attr('stroke-width', 2)
      .attr('opacity', 0).transition().duration(800).attr('opacity', 1);

    node.append('text').text((d: any) => d.label.length > 10 ? d.label.substring(0, 10) + '…' : d.label)
      .attr('text-anchor', 'middle').attr('dy', (d: any) => d.r + 14).attr('fill', '#9A9489').attr('font-size', '10px');

    sim.on('tick', () => {
      link.attr('x1', (d: any) => d.source.x).attr('y1', (d: any) => d.source.y)
        .attr('x2', (d: any) => d.target.x).attr('y2', (d: any) => d.target.y);
      node.attr('transform', (d: any) => `translate(${d.x},${d.y})`);
    });
  }

  // ── 2. Animated Donut Chart ──
  renderAnimatedDonut(): void {
    const el = document.getElementById('d3-donut');
    if (!el) return;
    el.innerHTML = '';
    const w = 300, h = 300, r = 120, inner = 70;
    const svg = d3.select(el).append('svg').attr('width', w).attr('height', h)
      .append('g').attr('transform', `translate(${w/2},${h/2})`);

    const data = this.enrollmentDistribution;
    if (!data.length) return;
    const colors = ['#E05C5C', '#D4A853', '#7C9EF0', '#5CBF8A'];
    const pie = d3.pie<any>().value((d: any) => d.count).sort(null).padAngle(0.03);
    const arc = d3.arc<any>().innerRadius(inner).outerRadius(r).cornerRadius(6);
    const arcHover = d3.arc<any>().innerRadius(inner - 4).outerRadius(r + 8).cornerRadius(6);

    const arcs = svg.selectAll('path').data(pie(data)).join('path')
      .attr('fill', (_: any, i: number) => colors[i % colors.length])
      .attr('stroke', 'none').attr('cursor', 'pointer')
      .on('mouseover', function(this: any) { d3.select(this).transition().duration(200).attr('d', arcHover); })
      .on('mouseout', function(this: any) { d3.select(this).transition().duration(200).attr('d', arc); });

    arcs.transition().duration(1000).attrTween('d', function(d: any) {
      const i = d3.interpolate({ startAngle: 0, endAngle: 0 }, d);
      return (t: number) => arc(i(t)) || '';
    });

    svg.append('text').attr('text-anchor', 'middle').attr('dy', '-0.2em')
      .attr('fill', '#F5F0E8').attr('font-size', '28px').attr('font-weight', '800')
      .text(this.students.length);
    svg.append('text').attr('text-anchor', 'middle').attr('dy', '1.2em')
      .attr('fill', '#9A9489').attr('font-size', '11px').text('students');
  }

  // ── 3. Treemap ──
  renderTreemap(): void {
    const el = document.getElementById('d3-treemap');
    if (!el) return;
    el.innerHTML = '';
    const w = el.clientWidth || 500, h = 320;

    const deptData = this.departmentData;
    if (!deptData.length) return;

    const root = d3.hierarchy({ children: deptData.map(d => ({ name: d.dept, value: d.count })) })
      .sum((d: any) => d.value || 0);

    d3.treemap<any>().size([w, h]).padding(4).round(true)(root);

    const svg = d3.select(el).append('svg').attr('width', w).attr('height', h);
    const colors = ['#D4A853', '#7C9EF0', '#5CBF8A', '#B48EF0', '#E05C5C', '#F0C97A'];

    const cell = svg.selectAll('g').data(root.leaves()).join('g')
      .attr('transform', (d: any) => `translate(${d.x0},${d.y0})`);

    cell.append('rect')
      .attr('width', (d: any) => d.x1 - d.x0).attr('height', (d: any) => d.y1 - d.y0)
      .attr('fill', (_: any, i: number) => colors[i % colors.length])
      .attr('rx', 6).attr('opacity', 0)
      .transition().duration(600).delay((_: any, i: number) => i * 100).attr('opacity', 0.85);

    cell.append('text').attr('x', 8).attr('y', 22)
      .attr('fill', '#fff').attr('font-size', '13px').attr('font-weight', '700')
      .text((d: any) => d.data.name);

    cell.append('text').attr('x', 8).attr('y', 40)
      .attr('fill', 'rgba(255,255,255,.7)').attr('font-size', '11px')
      .text((d: any) => d.data.value + ' students');
  }

  // ── 4. Radial Bar Chart ──
  renderRadialBars(): void {
    const el = document.getElementById('d3-radial');
    if (!el) return;
    el.innerHTML = '';
    const w = 360, h = 360, cx = w / 2, cy = h / 2;
    const data = this.subjectEnrollmentData.slice(0, 8);
    if (!data.length) return;

    const svg = d3.select(el).append('svg').attr('width', w).attr('height', h)
      .append('g').attr('transform', `translate(${cx},${cy})`);

    const maxVal = Math.max(...data.map(d => d.count), 1);
    const outerR = 150, innerR = 50;
    const colors = ['#D4A853', '#7C9EF0', '#5CBF8A', '#B48EF0', '#E05C5C', '#F0C97A', '#64B5F6', '#81C784'];
    const angleSlice = (2 * Math.PI) / data.length;

    // Background rings
    [0.25, 0.5, 0.75, 1].forEach(pct => {
      svg.append('circle').attr('r', innerR + (outerR - innerR) * pct)
        .attr('fill', 'none').attr('stroke', '#2E2E3A').attr('stroke-width', 0.5);
    });

    // Bars
    const arc = d3.arc<any>().innerRadius(innerR).cornerRadius(4);
    data.forEach((d, i) => {
      const startAngle = i * angleSlice - Math.PI / 2;
      const endAngle = startAngle + angleSlice * 0.8;
      const barR = innerR + (outerR - innerR) * (d.count / maxVal);

      svg.append('path')
        .attr('d', arc({ startAngle, endAngle, outerRadius: innerR }) || '')
        .attr('fill', colors[i % colors.length])
        .transition().duration(800).delay(i * 80)
        .attrTween('d', () => {
          const interp = d3.interpolate(innerR, barR);
          return (t: number) => arc({ startAngle, endAngle, outerRadius: interp(t) }) || '';
        });

      // Labels
      const labelAngle = (startAngle + endAngle) / 2;
      const lx = (outerR + 20) * Math.cos(labelAngle);
      const ly = (outerR + 20) * Math.sin(labelAngle);
      svg.append('text').attr('x', lx).attr('y', ly)
        .attr('text-anchor', 'middle').attr('fill', '#9A9489').attr('font-size', '10px')
        .text(d.name.length > 12 ? d.name.substring(0, 12) + '…' : d.name);
    });

    svg.append('text').attr('text-anchor', 'middle').attr('dy', '-0.2em')
      .attr('fill', '#D4A853').attr('font-size', '22px').attr('font-weight', '800')
      .text(data.length);
    svg.append('text').attr('text-anchor', 'middle').attr('dy', '1.2em')
      .attr('fill', '#9A9489').attr('font-size', '10px').text('subjects');
  }

  // ── 5. Bubble Chart ──
  renderBubbleChart(): void {
    const el = document.getElementById('d3-bubble');
    if (!el) return;
    el.innerHTML = '';
    const w = el.clientWidth || 600, h = 380;

    const stuData = this.students.map(s => ({
      name: s.name || s.email,
      dept: s.department || 'Unknown',
      count: s.subjects?.length || 0
    }));
    if (!stuData.length) return;

    const root = d3.hierarchy({ children: stuData }).sum((d: any) => (d.count || 0) + 1);
    d3.pack<any>().size([w, h]).padding(8)(root);

    const svg = d3.select(el).append('svg').attr('width', w).attr('height', h);
    const deptColors: any = {};
    const palette = ['#D4A853', '#7C9EF0', '#5CBF8A', '#B48EF0', '#E05C5C', '#F0C97A'];
    let ci = 0;
    stuData.forEach(s => { if (!deptColors[s.dept]) deptColors[s.dept] = palette[ci++ % palette.length]; });

    const node = svg.selectAll('g').data(root.leaves()).join('g')
      .attr('transform', (d: any) => `translate(${d.x},${d.y})`);

    node.append('circle')
      .attr('r', 0).attr('fill', (d: any) => deptColors[d.data.dept] || '#D4A853')
      .attr('opacity', 0.8).attr('stroke', '#fff').attr('stroke-width', 2)
      .transition().duration(800).delay((_: any, i: number) => i * 60).attr('r', (d: any) => d.r);

    node.append('text').attr('text-anchor', 'middle').attr('dy', '-0.3em')
      .attr('fill', '#fff').attr('font-size', (d: any) => Math.max(d.r / 4, 9) + 'px').attr('font-weight', '700')
      .text((d: any) => d.data.name.split(' ')[0]);

    node.append('text').attr('text-anchor', 'middle').attr('dy', '1em')
      .attr('fill', 'rgba(255,255,255,.7)').attr('font-size', '9px')
      .text((d: any) => d.data.count + ' courses');
  }

  // ── 6. Chord Diagram ──
  renderChordDiagram(): void {
    const el = document.getElementById('d3-chord');
    if (!el) return;
    el.innerHTML = '';
    const w = 400, h = 400, outerR = 170, innerR = 155;
    const svg = d3.select(el).append('svg').attr('width', w).attr('height', h)
      .append('g').attr('transform', `translate(${w/2},${h/2})`);

    // Build matrix: subjects × subjects, connected via shared students
    const subs = this.subjects.slice(0, 8);
    if (subs.length < 2) return;
    const n = subs.length;
    const matrix: number[][] = Array.from({ length: n }, () => Array(n).fill(0));

    for (const stu of this.students) {
      const enrolled = (stu.subjects || []).map((s: any) => subs.findIndex((sub: any) => sub.id === s.id)).filter((i: number) => i >= 0);
      for (let a = 0; a < enrolled.length; a++)
        for (let b = a + 1; b < enrolled.length; b++) {
          matrix[enrolled[a]][enrolled[b]] += 1;
          matrix[enrolled[b]][enrolled[a]] += 1;
        }
    }
    // Ensure diagonal has some value for display
    subs.forEach((s: any, i: number) => { matrix[i][i] = (s.students || []).length || 1; });

    const colors = ['#D4A853','#7C9EF0','#5CBF8A','#B48EF0','#E05C5C','#F0C97A','#64B5F6','#81C784'];
    const chord = d3.chord().padAngle(0.05).sortSubgroups(d3.descending)(matrix);
    const arc = d3.arc<any>().innerRadius(innerR).outerRadius(outerR);
    const ribbon = d3.ribbon<any, any>().radius(innerR);

    svg.append('g').selectAll('path').data(chord.groups).join('path')
      .attr('d', arc as any).attr('fill', (_: any, i: number) => colors[i % colors.length])
      .attr('stroke', '#1A1A22').attr('stroke-width', 1)
      .attr('opacity', 0).transition().duration(800).attr('opacity', 0.9);

    svg.append('g').selectAll('path').data(chord).join('path')
      .attr('d', ribbon as any)
      .attr('fill', (d: any) => colors[d.source.index % colors.length])
      .attr('stroke', 'none').attr('opacity', 0)
      .transition().duration(1000).delay(300).attr('opacity', 0.35);

    // Labels
    svg.append('g').selectAll('text').data(chord.groups).join('text')
      .each(function(this: any, d: any) {
        const angle = (d.startAngle + d.endAngle) / 2;
        const x = (outerR + 14) * Math.cos(angle - Math.PI / 2);
        const y = (outerR + 14) * Math.sin(angle - Math.PI / 2);
        d3.select(this).attr('x', x).attr('y', y).attr('text-anchor', angle > Math.PI ? 'end' : 'start');
      })
      .attr('fill', '#9A9489').attr('font-size', '10px')
      .text((_: any, i: number) => subs[i]?.name?.substring(0, 12) || '');
  }

  // ── 7. Gauge Chart (Attendance Rate) ──
  renderGaugeChart(): void {
    const el = document.getElementById('d3-gauge');
    if (!el) return;
    el.innerHTML = '';
    const w = 300, h = 200;
    const svg = d3.select(el).append('svg').attr('width', w).attr('height', h)
      .append('g').attr('transform', `translate(${w/2},${h - 20})`);

    const rate = this.timeStats?.overallRate || 0;
    const r = 130;
    const arcGen = d3.arc<any>().innerRadius(r - 28).outerRadius(r).cornerRadius(14);

    // Background arc
    svg.append('path')
      .attr('d', arcGen({ startAngle: -Math.PI / 2, endAngle: Math.PI / 2 }) || '')
      .attr('fill', '#242430');

    // Colored segments
    const segColors = ['#E05C5C', '#E05C5C', '#D4A853', '#D4A853', '#5CBF8A', '#5CBF8A', '#5CBF8A', '#5CBF8A'];
    const segCount = 8;
    for (let i = 0; i < segCount; i++) {
      const start = -Math.PI / 2 + (i / segCount) * Math.PI;
      const end = start + (1 / segCount) * Math.PI - 0.02;
      svg.append('path')
        .attr('d', arcGen({ startAngle: start, endAngle: end }) || '')
        .attr('fill', segColors[i]).attr('opacity', 0.15);
    }

    // Value arc
    const endAngle = -Math.PI / 2 + (rate / 100) * Math.PI;
    const valArc = svg.append('path')
      .attr('d', arcGen({ startAngle: -Math.PI / 2, endAngle: -Math.PI / 2 }) || '')
      .attr('fill', rate >= 75 ? '#5CBF8A' : rate >= 50 ? '#D4A853' : '#E05C5C');

    valArc.transition().duration(1500).attrTween('d', () => {
      const interp = d3.interpolate(-Math.PI / 2, endAngle);
      return (t: number) => arcGen({ startAngle: -Math.PI / 2, endAngle: interp(t) }) || '';
    });

    // Needle
    const needleAngle = -Math.PI / 2 + (rate / 100) * Math.PI;
    const needle = svg.append('line')
      .attr('x1', 0).attr('y1', 0)
      .attr('x2', 0).attr('y2', -(r - 35))
      .attr('stroke', '#F5F0E8').attr('stroke-width', 2.5).attr('stroke-linecap', 'round');
    needle.transition().duration(1500)
      .attrTween('transform', () => {
        const interp = d3.interpolate(-90, -90 + rate * 1.8);
        return (t: number) => `rotate(${interp(t)})`;
      });

    svg.append('circle').attr('r', 6).attr('fill', '#F5F0E8');

    // Value text
    svg.append('text').attr('y', -35).attr('text-anchor', 'middle')
      .attr('fill', rate >= 75 ? '#5CBF8A' : rate >= 50 ? '#D4A853' : '#E05C5C')
      .attr('font-size', '32px').attr('font-weight', '900')
      .text('0%').transition().duration(1500).tween('text', function() {
        const i = d3.interpolateNumber(0, rate);
        return function(t: number) { d3.select(this).text(Math.round(i(t)) + '%'); };
      });

    svg.append('text').attr('y', -12).attr('text-anchor', 'middle')
      .attr('fill', '#9A9489').attr('font-size', '11px').text('Attendance Rate');

    // Min/Max labels
    svg.append('text').attr('x', -(r + 5)).attr('y', 8)
      .attr('fill', '#E05C5C').attr('font-size', '10px').attr('font-weight', '700').text('0%');
    svg.append('text').attr('x', r - 5).attr('y', 8)
      .attr('fill', '#5CBF8A').attr('font-size', '10px').attr('font-weight', '700').text('100%');
  }

  // ── 8. Lollipop Chart (Teacher Workload) ──
  renderLollipopChart(): void {
    const el = document.getElementById('d3-lollipop');
    if (!el) return;
    el.innerHTML = '';
    const data = this.getTeacherWorkload();
    if (!data.length) return;

    const margin = { top: 10, right: 30, bottom: 30, left: 110 };
    const w = (el.clientWidth || 600) - margin.left - margin.right;
    const h = data.length * 45;
    const svg = d3.select(el).append('svg')
      .attr('width', w + margin.left + margin.right).attr('height', h + margin.top + margin.bottom)
      .append('g').attr('transform', `translate(${margin.left},${margin.top})`);

    const x = d3.scaleLinear().domain([0, Math.max(...data.map(d => d.count), 1) + 1]).range([0, w]);
    const y = d3.scaleBand().domain(data.map(d => d.name)).range([0, h]).padding(0.4);

    // Grid lines
    svg.append('g').selectAll('line').data(x.ticks(5)).join('line')
      .attr('x1', d => x(d)).attr('x2', d => x(d)).attr('y1', 0).attr('y2', h)
      .attr('stroke', '#2E2E3A').attr('stroke-width', 0.5);

    // Lines
    svg.selectAll('.lollipop-line').data(data).join('line')
      .attr('x1', 0).attr('x2', 0)
      .attr('y1', (d: any) => (y(d.name) || 0) + y.bandwidth() / 2)
      .attr('y2', (d: any) => (y(d.name) || 0) + y.bandwidth() / 2)
      .attr('stroke', '#B48EF0').attr('stroke-width', 2.5)
      .transition().duration(800).delay((_: any, i: number) => i * 100)
      .attr('x2', (d: any) => x(d.count));

    // Circles
    svg.selectAll('.lollipop-dot').data(data).join('circle')
      .attr('cx', 0)
      .attr('cy', (d: any) => (y(d.name) || 0) + y.bandwidth() / 2)
      .attr('r', 0).attr('fill', '#B48EF0').attr('stroke', '#fff').attr('stroke-width', 2)
      .transition().duration(800).delay((_: any, i: number) => i * 100)
      .attr('cx', (d: any) => x(d.count)).attr('r', 7);

    // Count labels
    svg.selectAll('.lollipop-val').data(data).join('text')
      .attr('x', (d: any) => x(d.count) + 14)
      .attr('y', (d: any) => (y(d.name) || 0) + y.bandwidth() / 2 + 4)
      .attr('fill', '#D4A853').attr('font-size', '13px').attr('font-weight', '800')
      .attr('opacity', 0).text((d: any) => d.count)
      .transition().duration(400).delay((_: any, i: number) => i * 100 + 600).attr('opacity', 1);

    // Y axis labels
    svg.append('g').selectAll('text').data(data).join('text')
      .attr('x', -8).attr('y', (d: any) => (y(d.name) || 0) + y.bandwidth() / 2 + 4)
      .attr('text-anchor', 'end').attr('fill', '#9A9489').attr('font-size', '12px')
      .text((d: any) => d.name.length > 15 ? d.name.substring(0, 15) + '…' : d.name);
  }

  // ── 9. Circle Packing (Dept → Subject → Students) ──
  renderCirclePacking(): void {
    const el = document.getElementById('d3-pack');
    if (!el) return;
    el.innerHTML = '';
    const w = el.clientWidth || 600, h = 450;

    // Build hierarchy: departments → subjects → students
    const depts: any = {};
    this.subjects.forEach(sub => {
      const deptName = sub.teacher?.department || 'Unassigned';
      if (!depts[deptName]) depts[deptName] = [];
      const children = (sub.students || []).map((s: any) => ({ name: s.name || s.email, value: 1 }));
      depts[deptName].push({ name: sub.name, children: children.length ? children : [{ name: 'empty', value: 1 }] });
    });

    const hierarchyData = {
      name: 'BUP',
      children: Object.entries(depts).map(([dept, subs]) => ({ name: dept, children: subs }))
    };

    const root = d3.hierarchy(hierarchyData).sum((d: any) => d.value || 0).sort((a: any, b: any) => (b.value || 0) - (a.value || 0));
    d3.pack<any>().size([w, h]).padding(4)(root);

    const svg = d3.select(el).append('svg').attr('width', w).attr('height', h);
    const colors = ['rgba(212,168,83,.15)', 'rgba(124,158,240,.15)', 'rgba(92,191,138,.15)', 'rgba(180,142,240,.15)'];
    const strokeColors = ['#D4A853', '#7C9EF0', '#5CBF8A', '#B48EF0'];

    const node = svg.selectAll('g').data(root.descendants()).join('g')
      .attr('transform', (d: any) => `translate(${d.x},${d.y})`);

    node.append('circle')
      .attr('r', 0)
      .attr('fill', (d: any) => d.depth === 0 ? 'none' : d.depth === 1 ? colors[d.parent?.data?.children?.indexOf(d.data) % 4 || 0] : d.children ? 'rgba(255,255,255,.04)' : 'rgba(212,168,83,.25)')
      .attr('stroke', (d: any) => d.depth === 0 ? '#2E2E3A' : d.depth === 1 ? strokeColors[d.parent?.data?.children?.indexOf(d.data) % 4 || 0] : d.children ? '#2E2E3A' : 'none')
      .attr('stroke-width', (d: any) => d.depth <= 1 ? 1.5 : 0.5)
      .transition().duration(800).delay((d: any) => d.depth * 200)
      .attr('r', (d: any) => d.r);

    // Labels for depth 1 (departments) and 2 (subjects)
    node.filter((d: any) => d.depth === 1).append('text')
      .attr('text-anchor', 'middle').attr('dy', (d: any) => -d.r + 16)
      .attr('fill', '#F5F0E8').attr('font-size', '12px').attr('font-weight', '700')
      .text((d: any) => d.data.name.substring(0, 18));

    node.filter((d: any) => d.depth === 2 && d.r > 20).append('text')
      .attr('text-anchor', 'middle').attr('dy', '0.3em')
      .attr('fill', '#D4A853').attr('font-size', '10px').attr('font-weight', '600')
      .text((d: any) => d.data.name.substring(0, 14));
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
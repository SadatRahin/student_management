/*
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-teacher-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <h2>Teacher Management Dashboard</h2>
    
    <!-- This section only shows if the lists are truly empty -->
    <div *ngIf="students.length === 0" style="color: red; margin-bottom: 10px;">
       ⚠️ Backend returned 0 students. Check if roles are "STUDENT" in your DB.
    </div>
    <div *ngIf="subjects.length === 0" style="color: red; margin-bottom: 10px;">
       ⚠️ No subjects found. Run your SQL insert commands.
    </div>

    <table *ngIf="students.length > 0" border="1" style="width: 100%; text-align: left; border-collapse: collapse;">
      <thead>
        <tr style="background-color: #f2f2f2;">
          <th style="padding: 10px;">Student Email</th>
          <th style="padding: 10px;">Assigned Subjects</th>
          <th style="padding: 10px;">Assign New Subject</th>
        </tr>
      </thead>
      <tbody>
        <tr *ngFor="let student of students">
          <td style="padding: 10px;">{{ student.email }}</td>
          <td style="padding: 10px;">
            <span *ngFor="let sub of student.subjects" style="background: #e0e0e0; margin-right: 5px; padding: 2px 5px; border-radius: 3px;">
              {{ sub.name }}
            </span>
          </td>
          <td style="padding: 10px;">
            <select [(ngModel)]="selectedSubjectId">
              <option [value]="0">-- Select Subject --</option>
              <option *ngFor="let s of subjects" [value]="s.id">{{ s.name }}</option>
            </select>
            <button (click)="assign(student.id)" style="margin-left: 10px;">Assign</button>
          </td>
        </tr>
      </tbody>
    </table>
  `,
  styleUrl: './teacher-dashboard.component.css'
})
export class TeacherDashboardComponent implements OnInit {
  students: any[] = [];
  subjects: any[] = [];
  selectedSubjectId: number = 0;

  constructor(
    private managementService: ManagementService,
    private cdr: ChangeDetectorRef // Added this to force a UI refresh
  ) {}

  ngOnInit(): void {
    this.loadData();
  }

  loadData() {
    // Fetch Students
    this.managementService.getStudents().subscribe({
      next: (data) => {
        console.log('Students received:', data);
        this.students = data;
        this.cdr.detectChanges(); // Force Angular to update the table
      },
      error: (err) => console.error('Failed to load students', err)
    });

    // Fetch Subjects
    this.managementService.getSubjects().subscribe({
      next: (data) => {
        console.log('Subjects received:', data);
        this.subjects = data;
        this.cdr.detectChanges(); // Force Angular to update the dropdown
      },
      error: (err) => console.error('Failed to load subjects', err)
    });
  }

  assign(studentId: number) {
    if (this.selectedSubjectId == 0) {
      alert("Please select a subject from the list first.");
      return;
    }
    this.managementService.assignSubject(studentId, this.selectedSubjectId).subscribe({
      next: () => {
        alert("Success! Subject has been assigned.");
        this.loadData(); // Reload table to show the new subject
      },
      error: (err) => alert("Assignment failed. Check console for details.")
    });
  }
}
  */

/*
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-teacher-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './teacher-dashboard.component.html', // Pointing to external file
  styleUrl: './teacher-dashboard.component.css'
})
export class TeacherDashboardComponent implements OnInit {
  students: any[] = [];
  subjects: any[] = [];
  selectedSubjectId: number = 0;

  constructor(
    private managementService: ManagementService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadData();
  }

  loadData() {
    this.managementService.getStudents().subscribe({
      next: (data) => {
        this.students = data;
        this.cdr.detectChanges();
      }
    });
    this.managementService.getSubjects().subscribe({
      next: (data) => {
        this.subjects = data;
        this.cdr.detectChanges();
      }
    });
  }

  assign(studentId: number) {
    if (this.selectedSubjectId == 0) {
      alert("Please select a subject.");
      return;
    }
    this.managementService.assignSubject(studentId, this.selectedSubjectId).subscribe({
      next: () => {
        alert("Success!");
        this.loadData();
      }
    });
  }
}
  */


/*
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpParams } from '@angular/common/http';
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-teacher-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './teacher-dashboard.component.html',
  styleUrl: './teacher-dashboard.component.css'
})
export class TeacherDashboardComponent implements OnInit {

  activeTab: 'overview' | 'add-student' | 'add-subject' | 'assign' = 'overview';

  // ── Overview ──
  students: any[] = [];
  subjects: any[] = [];

  // ── Add Student ──
  newStudentName: string = '';
  newStudentEmail: string = '';
  newStudentPassword: string = '';
  addStudentLoading = false;
  addStudentMessage = '';
  addStudentError = false;

  // ── Add Subject ──
  newSubjectName: string = '';
  addSubjectLoading = false;
  addSubjectMessage = '';
  addSubjectError = false;

  // ── Assign ──
  assignStudentId: number = 0;
  assignSubjectId: number = 0;
  assignLoading = false;
  assignMessage = '';
  assignError = false;

  private baseUrl = 'http://localhost:8080/api';

  constructor(
    private managementService: ManagementService,
    private http: HttpClient,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadData();
  }

  setTab(tab: 'overview' | 'add-student' | 'add-subject' | 'assign') {
    this.activeTab = tab;
    this.clearMessages();
    if (tab === 'overview' || tab === 'assign') {
      this.loadData();
    }
  }

  clearMessages() {
    this.addStudentMessage = '';
    this.addSubjectMessage = '';
    this.assignMessage = '';
  }

  loadData() {
    this.managementService.getStudents().subscribe({
      next: (data) => { this.students = data; this.cdr.detectChanges(); }
    });
    this.managementService.getSubjects().subscribe({
      next: (data) => { this.subjects = data; this.cdr.detectChanges(); }
    });
  }

  // ── Add Student ──
  addStudent() {
    if (!this.newStudentEmail || !this.newStudentPassword) {
      this.addStudentMessage = 'Email and password are required.';
      this.addStudentError = true;
      return;
    }
    this.addStudentLoading = true;
    this.addStudentMessage = '';
    const body: any = {
      email: this.newStudentEmail.trim(),
      password: this.newStudentPassword,
      role: 'STUDENT'
    };
    if (this.newStudentName.trim()) body.name = this.newStudentName.trim();

    this.http.post(`${this.baseUrl}/auth/signup`, body).subscribe({
      next: () => {
        this.addStudentMessage = `Student "${this.newStudentEmail}" added successfully!`;
        this.addStudentError = false;
        this.newStudentName = '';
        this.newStudentEmail = '';
        this.newStudentPassword = '';
        this.addStudentLoading = false;
        this.loadData();
        this.cdr.detectChanges();
      },
      error: (err) => {
        this.addStudentMessage = err.error || 'Failed to add student.';
        this.addStudentError = true;
        this.addStudentLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  // ── Add Subject ──
  addSubject() {
    if (!this.newSubjectName.trim()) {
      this.addSubjectMessage = 'Subject name is required.';
      this.addSubjectError = true;
      return;
    }
    this.addSubjectLoading = true;
    this.addSubjectMessage = '';

    this.http.post(`${this.baseUrl}/subjects`, { name: this.newSubjectName.trim() }).subscribe({
      next: () => {
        this.addSubjectMessage = `Subject "${this.newSubjectName}" added successfully!`;
        this.addSubjectError = false;
        this.newSubjectName = '';
        this.addSubjectLoading = false;
        this.loadData();
        this.cdr.detectChanges();
      },
      error: () => {
        this.addSubjectMessage = 'Failed to add subject.';
        this.addSubjectError = true;
        this.addSubjectLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  // ── Assign Subject ──
  assign() {
    if (!this.assignStudentId || !this.assignSubjectId) {
      this.assignMessage = 'Please select both a student and a subject.';
      this.assignError = true;
      return;
    }
    this.assignLoading = true;
    this.assignMessage = '';
    const params = new HttpParams()
      .set('studentId', this.assignStudentId.toString())
      .set('subjectId', this.assignSubjectId.toString());

    this.http.post(`${this.baseUrl}/management/assign`, {}, { params }).subscribe({
      next: () => {
        const student = this.students.find(s => s.id == this.assignStudentId);
        const subject = this.subjects.find(s => s.id == this.assignSubjectId);
        this.assignMessage = `"${subject?.name}" assigned to ${student?.name || student?.email} successfully!`;
        this.assignError = false;
        this.assignSubjectId = 0;
        this.assignLoading = false;
        this.loadData();
        this.cdr.detectChanges();
      },
      error: () => {
        this.assignMessage = 'Failed to assign subject.';
        this.assignError = true;
        this.assignLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  // ── Delete Student ──
  deleteStudent(id: number, nameOrEmail: string) {
    if (!confirm(`Delete student "${nameOrEmail}"? This cannot be undone.`)) return;
    this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({
      next: () => {
        this.addStudentMessage = `Student "${nameOrEmail}" deleted.`;
        this.addStudentError = false;
        this.loadData();
        this.cdr.detectChanges();
      },
      error: () => {
        this.addStudentMessage = 'Failed to delete student.';
        this.addStudentError = true;
        this.cdr.detectChanges();
      }
    });
  }

  // ── Delete Subject ──
  deleteSubject(id: number, name: string) {
    if (!confirm(`Delete subject "${name}"? This cannot be undone.`)) return;
    this.http.delete(`${this.baseUrl}/subjects/${id}`).subscribe({
      next: () => {
        this.addSubjectMessage = `Subject "${name}" deleted.`;
        this.addSubjectError = false;
        this.loadData();
        this.cdr.detectChanges();
      },
      error: () => {
        this.addSubjectMessage = 'Failed to delete subject.';
        this.addSubjectError = true;
        this.cdr.detectChanges();
      }
    });
  }

  getStudentName(id: number): string {
    const s = this.students.find(s => s.id == id);
    return s ? (s.name || s.email) : '';
  }

  getSubjectName(id: number): string {
    const s = this.subjects.find(s => s.id == id);
    return s ? s.name : '';
  }
}
  */


/*
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Router } from '@angular/router';
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-teacher-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './teacher-dashboard.component.html',
  styleUrl: './teacher-dashboard.component.css'
})
export class TeacherDashboardComponent implements OnInit {

  activeTab: 'overview' | 'add-student' | 'add-subject' | 'assign' = 'overview';

  students: any[] = [];
  subjects: any[] = [];

  newStudentName = '';
  newStudentEmail = '';
  newStudentPassword = '';
  showPassword = false;
  addStudentLoading = false;
  addStudentMessage = '';
  addStudentError = false;

  newSubjectName = '';
  addSubjectLoading = false;
  addSubjectMessage = '';
  addSubjectError = false;

  assignStudentId: number = 0;
  assignSubjectId: number = 0;
  assignLoading = false;
  assignMessage = '';
  assignError = false;

  private baseUrl = 'http://localhost:8080/api';

  constructor(
    private managementService: ManagementService,
    private http: HttpClient,
    private cdr: ChangeDetectorRef,
    private router: Router
  ) {}

  ngOnInit(): void { this.loadData(); }

  logout() {
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userRole');
    this.router.navigate(['/login']);
  }

  setTab(tab: 'overview' | 'add-student' | 'add-subject' | 'assign') {
    this.activeTab = tab;
    this.clearMessages();
    if (tab === 'overview' || tab === 'assign') this.loadData();
    if (tab === 'add-student' || tab === 'add-subject') this.loadData();
  }

  clearMessages() {
    this.addStudentMessage = '';
    this.addSubjectMessage = '';
    this.assignMessage = '';
  }

  loadData() {
    this.managementService.getStudents().subscribe({
      next: (d) => { this.students = d; this.cdr.detectChanges(); }
    });
    this.managementService.getSubjects().subscribe({
      next: (d) => { this.subjects = d; this.cdr.detectChanges(); }
    });
  }

  getInitial(s: any): string {
    const src = s.name || s.email || '?';
    return src[0].toUpperCase();
  }

  getDisplayName(s: any): string {
    return s.name || s.email || 'Unknown';
  }

  addStudent() {
    if (!this.newStudentEmail || !this.newStudentPassword) {
      this.addStudentMessage = 'Email and password are required.';
      this.addStudentError = true;
      return;
    }
    this.addStudentLoading = true;
    this.addStudentMessage = '';
    const body: any = {
      email: this.newStudentEmail.trim(),
      password: this.newStudentPassword,
      role: 'STUDENT'
    };
    if (this.newStudentName.trim()) body.name = this.newStudentName.trim();
    this.http.post(`${this.baseUrl}/auth/signup`, body).subscribe({
      next: () => {
        this.addStudentMessage = `Student added successfully!`;
        this.addStudentError = false;
        this.newStudentName = '';
        this.newStudentEmail = '';
        this.newStudentPassword = '';
        this.addStudentLoading = false;
        this.loadData();
        this.cdr.detectChanges();
      },
      error: (err) => {
        this.addStudentMessage = err.error || 'Failed to add student.';
        this.addStudentError = true;
        this.addStudentLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  addSubject() {
    if (!this.newSubjectName.trim()) {
      this.addSubjectMessage = 'Subject name is required.';
      this.addSubjectError = true;
      return;
    }
    this.addSubjectLoading = true;
    this.addSubjectMessage = '';
    this.http.post(`${this.baseUrl}/subjects`, { name: this.newSubjectName.trim() }).subscribe({
      next: () => {
        this.addSubjectMessage = `Subject added successfully!`;
        this.addSubjectError = false;
        this.newSubjectName = '';
        this.addSubjectLoading = false;
        this.loadData();
        this.cdr.detectChanges();
      },
      error: () => {
        this.addSubjectMessage = 'Failed to add subject.';
        this.addSubjectError = true;
        this.addSubjectLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  assign() {
    if (!this.assignStudentId || !this.assignSubjectId) {
      this.assignMessage = 'Please select both a student and a subject.';
      this.assignError = true;
      return;
    }
    this.assignLoading = true;
    this.assignMessage = '';
    const params = new HttpParams()
      .set('studentId', this.assignStudentId.toString())
      .set('subjectId', this.assignSubjectId.toString());
    this.http.post(`${this.baseUrl}/management/assign`, {}, { params }).subscribe({
      next: () => {
        const student = this.students.find(s => s.id == this.assignStudentId);
        const subject = this.subjects.find(s => s.id == this.assignSubjectId);
        this.assignMessage = `"${subject?.name}" assigned to ${student?.name || student?.email}!`;
        this.assignError = false;
        this.assignSubjectId = 0;
        this.assignLoading = false;
        this.loadData();
        this.cdr.detectChanges();
      },
      error: () => {
        this.assignMessage = 'Failed to assign subject.';
        this.assignError = true;
        this.assignLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  deleteStudent(id: number, nameOrEmail: string) {
    if (!confirm(`Delete "${nameOrEmail}"? This cannot be undone.`)) return;
    this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({
      next: () => {
        this.addStudentMessage = `Deleted successfully.`;
        this.addStudentError = false;
        this.loadData();
        this.cdr.detectChanges();
      },
      error: () => {
        this.addStudentMessage = 'Failed to delete.';
        this.addStudentError = true;
        this.cdr.detectChanges();
      }
    });
  }

  deleteSubject(id: number, name: string) {
    if (!confirm(`Delete "${name}"? This cannot be undone.`)) return;
    this.http.delete(`${this.baseUrl}/subjects/${id}`).subscribe({
      next: () => {
        this.addSubjectMessage = `Deleted successfully.`;
        this.addSubjectError = false;
        this.loadData();
        this.cdr.detectChanges();
      },
      error: () => {
        this.addSubjectMessage = 'Failed to delete.';
        this.addSubjectError = true;
        this.cdr.detectChanges();
      }
    });
  }

  getStudentName(id: number): string {
    const s = this.students.find(s => s.id == id);
    return s ? (s.name || s.email) : '';
  }

  getSubjectName(id: number): string {
    const s = this.subjects.find(s => s.id == id);
    return s ? s.name : '';
  }
}
*/


/*
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Router } from '@angular/router';
import { ManagementService } from '../services/management.service';
import { EnrolledCountPipe } from '../enrolled-count.pipe';

@Component({
  selector: 'app-teacher-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, EnrolledCountPipe],
  templateUrl: './teacher-dashboard.component.html',
  styleUrl: './teacher-dashboard.component.css'
})
export class TeacherDashboardComponent implements OnInit {

  activeTab: 'dashboard' | 'students' | 'subjects' | 'assign' | 'stats' = 'dashboard';

  students: any[] = [];
  subjects: any[] = [];

  // ── Modals ──
  showAddStudentModal = false;
  showAddSubjectModal = false;
  showAssignModal     = false;

  // ── Add Student ──
  newStudentName     = '';
  newStudentEmail    = '';
  newStudentPassword = '';
  showPassword       = false;
  addStudentLoading  = false;
  addStudentMessage  = '';
  addStudentError    = false;

  // ── Add Subject ──
  newSubjectName    = '';
  addSubjectLoading = false;
  addSubjectMessage = '';
  addSubjectError   = false;

  // ── Assign ──
  assignStudentId: number = 0;
  assignSubjectId: number = 0;
  assignLoading   = false;
  assignMessage   = '';
  assignError     = false;

  // ── Selected student's current subjects (for duplicate prevention) ──
  selectedStudentSubjects: any[] = [];
  loadingStudentSubjects = false;

  private baseUrl = 'http://localhost:8080/api';

  constructor(
    private managementService: ManagementService,
    private http: HttpClient,
    private cdr: ChangeDetectorRef,
    private router: Router
  ) {}

  ngOnInit(): void { this.loadData(); }

  logout() {
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userRole');
    this.router.navigate(['/login']);
  }

  setTab(tab: 'dashboard' | 'students' | 'subjects' | 'assign' | 'stats') {
    this.activeTab = tab;
    this.closeAllModals();
    this.clearMessages();
    this.loadData();
  }

  clearMessages() {
    this.addStudentMessage = '';
    this.addSubjectMessage = '';
    this.assignMessage     = '';
  }

  closeAllModals() {
    this.showAddStudentModal = false;
    this.showAddSubjectModal = false;
    this.showAssignModal     = false;
    this.clearMessages();
    this.selectedStudentSubjects = [];
    this.assignStudentId = 0;
    this.assignSubjectId = 0;
  }

  loadData() {
    this.managementService.getStudents().subscribe({
      next: (d) => { this.students = d; this.cdr.detectChanges(); }
    });
    this.managementService.getSubjects().subscribe({
      next: (d) => { this.subjects = d; this.cdr.detectChanges(); }
    });
  }

  // ── Stats computed props ──

  get totalEnrollments(): number {
    return this.students.reduce((sum, s) => sum + (s.subjects?.length || 0), 0);
  }

  get avgSubjectsPerStudent(): string {
    if (!this.students.length) return '0';
    return (this.totalEnrollments / this.students.length).toFixed(1);
  }

  get mostPopularSubject(): string {
    if (!this.subjects.length || !this.students.length) return '—';
    const counts: Record<number, number> = {};
    for (const s of this.students) {
      for (const sub of (s.subjects || [])) {
        counts[sub.id] = (counts[sub.id] || 0) + 1;
      }
    }
    let maxId = -1, maxCount = 0;
    for (const [id, count] of Object.entries(counts)) {
      if (count > maxCount) { maxCount = count; maxId = +id; }
    }
    const found = this.subjects.find(s => s.id === maxId);
    return found ? found.name : '—';
  }

  get subjectEnrollmentData(): { name: string; count: number; pct: number }[] {
    if (!this.subjects.length) return [];
    const counts: Record<number, number> = {};
    for (const s of this.students) {
      for (const sub of (s.subjects || [])) {
        counts[sub.id] = (counts[sub.id] || 0) + 1;
      }
    }
    const max = Math.max(...Object.values(counts), 1);
    return this.subjects
      .map(sub => ({
        name: sub.name,
        count: counts[sub.id] || 0,
        pct: Math.round(((counts[sub.id] || 0) / max) * 100)
      }))
      .sort((a, b) => b.count - a.count);
  }

  get studentLoadData(): { name: string; count: number; pct: number }[] {
    if (!this.students.length) return [];
    const max = Math.max(...this.students.map(s => s.subjects?.length || 0), 1);
    return this.students.map(s => ({
      name: s.name || s.email,
      count: s.subjects?.length || 0,
      pct: Math.round(((s.subjects?.length || 0) / max) * 100)
    })).sort((a, b) => b.count - a.count);
  }

  get enrollmentDistribution(): { label: string; count: number }[] {
    const dist: Record<string, number> = { '0 subjects': 0, '1–2 subjects': 0, '3–4 subjects': 0, '5+ subjects': 0 };
    for (const s of this.students) {
      const n = s.subjects?.length || 0;
      if (n === 0) dist['0 subjects']++;
      else if (n <= 2) dist['1–2 subjects']++;
      else if (n <= 4) dist['3–4 subjects']++;
      else dist['5+ subjects']++;
    }
    return Object.entries(dist).map(([label, count]) => ({ label, count }));
  }

  // ── Helpers ──
  getInitial(s: any): string {
    return (s.name || s.email || '?')[0].toUpperCase();
  }

  getDisplayName(s: any): string {
    return s.name || s.email || 'Unknown';
  }

  // ── Assign: load student's subjects when student is selected ──
  onAssignStudentChange() {
    this.assignSubjectId = 0;
    this.selectedStudentSubjects = [];
    if (!this.assignStudentId) return;
    this.loadingStudentSubjects = true;
    this.http.get<any[]>(`${this.baseUrl}/management/student-details/${this.assignStudentId}`)
      .subscribe({
        next: (data) => {
          this.selectedStudentSubjects = data;
          this.loadingStudentSubjects = false;
          this.cdr.detectChanges();
        },
        error: () => { this.loadingStudentSubjects = false; }
      });
  }

  isAlreadyAssigned(subjectId: number): boolean {
    return this.selectedStudentSubjects.some(s => s.id === subjectId);
  }

  get availableSubjectsForAssign(): any[] {
    return this.subjects.filter(s => !this.isAlreadyAssigned(s.id));
  }

  // ── CRUD ──
  addStudent() {
    if (!this.newStudentEmail || !this.newStudentPassword) {
      this.addStudentMessage = 'Email and password are required.';
      this.addStudentError = true;
      return;
    }
    this.addStudentLoading = true;
    this.addStudentMessage = '';
    const body: any = { email: this.newStudentEmail.trim(), password: this.newStudentPassword, role: 'STUDENT' };
    if (this.newStudentName.trim()) body.name = this.newStudentName.trim();
    this.http.post(`${this.baseUrl}/auth/signup`, body).subscribe({
      next: () => {
        this.addStudentMessage = 'Student added successfully!';
        this.addStudentError = false;
        this.newStudentName = this.newStudentEmail = this.newStudentPassword = '';
        this.addStudentLoading = false;
        this.loadData();
        this.cdr.detectChanges();
        setTimeout(() => { this.showAddStudentModal = false; this.addStudentMessage = ''; }, 1500);
      },
      error: (err) => {
        this.addStudentMessage = err.error || 'Failed to add student.';
        this.addStudentError = true;
        this.addStudentLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  addSubject() {
    if (!this.newSubjectName.trim()) {
      this.addSubjectMessage = 'Subject name is required.';
      this.addSubjectError = true;
      return;
    }
    this.addSubjectLoading = true;
    this.addSubjectMessage = '';
    this.http.post(`${this.baseUrl}/subjects`, { name: this.newSubjectName.trim() }).subscribe({
      next: () => {
        this.addSubjectMessage = 'Subject added successfully!';
        this.addSubjectError = false;
        this.newSubjectName = '';
        this.addSubjectLoading = false;
        this.loadData();
        this.cdr.detectChanges();
        setTimeout(() => { this.showAddSubjectModal = false; this.addSubjectMessage = ''; }, 1500);
      },
      error: () => {
        this.addSubjectMessage = 'Failed to add subject.';
        this.addSubjectError = true;
        this.addSubjectLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  assign() {
    if (!this.assignStudentId || !this.assignSubjectId) {
      this.assignMessage = 'Please select both a student and a subject.';
      this.assignError = true;
      return;
    }
    if (this.isAlreadyAssigned(this.assignSubjectId)) {
      this.assignMessage = 'This student already has this subject.';
      this.assignError = true;
      return;
    }
    this.assignLoading = true;
    this.assignMessage = '';
    const params = new HttpParams()
      .set('studentId', this.assignStudentId.toString())
      .set('subjectId', this.assignSubjectId.toString());
    this.http.post(`${this.baseUrl}/management/assign`, {}, { params }).subscribe({
      next: () => {
        const student = this.students.find(s => s.id == this.assignStudentId);
        const subject = this.subjects.find(s => s.id == this.assignSubjectId);
        this.assignMessage = `"${subject?.name}" assigned to ${student?.name || student?.email}!`;
        this.assignError = false;
        this.assignSubjectId = 0;
        this.assignLoading = false;
        this.onAssignStudentChange(); // refresh student subjects
        this.loadData();
        this.cdr.detectChanges();
      },
      error: () => {
        this.assignMessage = 'Failed to assign subject.';
        this.assignError = true;
        this.assignLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  deleteStudent(id: number, nameOrEmail: string) {
    if (!confirm(`Delete "${nameOrEmail}"? This cannot be undone.`)) return;
    this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({
      next: () => { this.loadData(); this.cdr.detectChanges(); },
      error: () => alert('Failed to delete.')
    });
  }

  deleteSubject(id: number, name: string) {
    if (!confirm(`Delete "${name}"? This cannot be undone.`)) return;
    this.http.delete(`${this.baseUrl}/subjects/${id}`).subscribe({
      next: () => { this.loadData(); this.cdr.detectChanges(); },
      error: () => alert('Failed to delete.')
    });
  }
}
*/


/*

import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Router } from '@angular/router';
import { ManagementService } from '../services/management.service';
import { EnrolledCountPipe } from '../enrolled-count.pipe';

@Component({
  selector: 'app-teacher-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, EnrolledCountPipe],
  templateUrl: './teacher-dashboard.component.html',
  styleUrl: './teacher-dashboard.component.css'
})
export class TeacherDashboardComponent implements OnInit {

  activeTab: 'dashboard' | 'students' | 'subjects' | 'assign' | 'stats' = 'dashboard';

  students: any[] = [];
  subjects: any[] = [];

  // ── Modals ──
  showAddStudentModal = false;
  showAddSubjectModal = false;
  showAssignModal     = false;

  // ── Add Student ──
  newStudentName     = '';
  newStudentEmail    = '';
  newStudentPassword = '';
  showPassword       = false;
  addStudentLoading  = false;
  addStudentMessage  = '';
  addStudentError    = false;

  // ── Add Subject ──
  newSubjectName    = '';
  addSubjectLoading = false;
  addSubjectMessage = '';
  addSubjectError   = false;

  // ── Assign ──
  assignStudentId: number = 0;
  assignSubjectId: number = 0;
  assignLoading   = false;
  assignMessage   = '';
  assignError     = false;

  // ── Selected student's current subjects (for duplicate prevention) ──
  selectedStudentSubjects: any[] = [];
  loadingStudentSubjects = false;

  private baseUrl = 'http://localhost:8080/api';

  constructor(
    private managementService: ManagementService,
    private http: HttpClient,
    private cdr: ChangeDetectorRef,
    private router: Router
  ) {}

  ngOnInit(): void { this.loadData(); }

  logout() {
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userRole');
    this.router.navigate(['/login']);
  }

  setTab(tab: 'dashboard' | 'students' | 'subjects' | 'assign' | 'stats') {
    this.activeTab = tab;
    this.closeAllModals();
    this.clearMessages();
    this.loadData();
  }

  clearMessages() {
    this.addStudentMessage = '';
    this.addSubjectMessage = '';
    this.assignMessage     = '';
  }

  closeAllModals() {
    this.showAddStudentModal = false;
    this.showAddSubjectModal = false;
    this.showAssignModal     = false;
    this.clearMessages();
    this.selectedStudentSubjects = [];
    this.assignStudentId = 0;
    this.assignSubjectId = 0;
  }

  loadData() {
    this.managementService.getStudents().subscribe({
      next: (d) => { this.students = d; this.cdr.detectChanges(); }
    });
    this.managementService.getSubjects().subscribe({
      next: (d) => { this.subjects = d; this.cdr.detectChanges(); }
    });
  }

  // ── Stats computed props ──

  get totalEnrollments(): number {
    return this.students.reduce((sum, s) => sum + (s.subjects?.length || 0), 0);
  }

  get avgSubjectsPerStudent(): string {
    if (!this.students.length) return '0';
    return (this.totalEnrollments / this.students.length).toFixed(1);
  }

  get mostPopularSubject(): string {
    if (!this.subjects.length || !this.students.length) return '—';
    const counts: Record<number, number> = {};
    for (const s of this.students) {
      for (const sub of (s.subjects || [])) {
        counts[sub.id] = (counts[sub.id] || 0) + 1;
      }
    }
    let maxId = -1, maxCount = 0;
    for (const [id, count] of Object.entries(counts)) {
      if (count > maxCount) { maxCount = count; maxId = +id; }
    }
    const found = this.subjects.find(s => s.id === maxId);
    return found ? found.name : '—';
  }

  // Add this property to calculate the percentage for the circle graph
  get topSubjectPct(): number {
    if (!this.students.length || !this.subjects.length) return 0;
    
    const counts: Record<number, number> = {};
    for (const s of this.students) {
      for (const sub of (s.subjects || [])) {
        counts[sub.id] = (counts[sub.id] || 0) + 1;
      }
    }
    
    const maxCount = Math.max(...Object.values(counts), 0);
    if (maxCount === 0) return 0;

    // This calculates how much of the student body is in the top subject
    return Math.round((maxCount / this.students.length) * 100);
  }

  get subjectEnrollmentData(): { name: string; count: number; pct: number }[] {
    if (!this.subjects.length) return [];
    const counts: Record<number, number> = {};
    for (const s of this.students) {
      for (const sub of (s.subjects || [])) {
        counts[sub.id] = (counts[sub.id] || 0) + 1;
      }
    }
    const max = Math.max(...Object.values(counts), 1);
    return this.subjects
      .map(sub => ({
        name: sub.name,
        count: counts[sub.id] || 0,
        pct: Math.round(((counts[sub.id] || 0) / max) * 100)
      }))
      .sort((a, b) => b.count - a.count);
  }

  get studentLoadData(): { name: string; count: number; pct: number }[] {
    if (!this.students.length) return [];
    const max = Math.max(...this.students.map(s => s.subjects?.length || 0), 1);
    return this.students.map(s => ({
      name: s.name || s.email,
      count: s.subjects?.length || 0,
      pct: Math.round(((s.subjects?.length || 0) / max) * 100)
    })).sort((a, b) => b.count - a.count);
  }

  get enrollmentDistribution(): { label: string; count: number }[] {
    const dist: Record<string, number> = { '0 subjects': 0, '1–2 subjects': 0, '3–4 subjects': 0, '5+ subjects': 0 };
    for (const s of this.students) {
      const n = s.subjects?.length || 0;
      if (n === 0) dist['0 subjects']++;
      else if (n <= 2) dist['1–2 subjects']++;
      else if (n <= 4) dist['3–4 subjects']++;
      else dist['5+ subjects']++;
    }
    return Object.entries(dist).map(([label, count]) => ({ label, count }));
  }

  // ── Helpers ──
  getInitial(s: any): string {
    return (s.name || s.email || '?')[0].toUpperCase();
  }

  getDisplayName(s: any): string {
    return s.name || s.email || 'Unknown';
  }

  // ── Assign: load student's subjects when student is selected ──
  onAssignStudentChange() {
    this.assignSubjectId = 0;
    this.selectedStudentSubjects = [];
    if (!this.assignStudentId) return;
    this.loadingStudentSubjects = true;
    this.http.get<any[]>(`${this.baseUrl}/management/student-details/${this.assignStudentId}`)
      .subscribe({
        next: (data) => {
          this.selectedStudentSubjects = data;
          this.loadingStudentSubjects = false;
          this.cdr.detectChanges();
        },
        error: () => { this.loadingStudentSubjects = false; }
      });
  }

  isAlreadyAssigned(subjectId: number): boolean {
    return this.selectedStudentSubjects.some(s => s.id === subjectId);
  }

  get availableSubjectsForAssign(): any[] {
    return this.subjects.filter(s => !this.isAlreadyAssigned(s.id));
  }

  // ── CRUD ──
  addStudent() {
    if (!this.newStudentEmail || !this.newStudentPassword) {
      this.addStudentMessage = 'Email and password are required.';
      this.addStudentError = true;
      return;
    }
    this.addStudentLoading = true;
    this.addStudentMessage = '';
    const body: any = { email: this.newStudentEmail.trim(), password: this.newStudentPassword, role: 'STUDENT' };
    if (this.newStudentName.trim()) body.name = this.newStudentName.trim();
    this.http.post(`${this.baseUrl}/auth/signup`, body).subscribe({
      next: () => {
        this.addStudentMessage = 'Student added successfully!';
        this.addStudentError = false;
        this.newStudentName = this.newStudentEmail = this.newStudentPassword = '';
        this.addStudentLoading = false;
        this.loadData();
        this.cdr.detectChanges();
        setTimeout(() => { this.showAddStudentModal = false; this.addStudentMessage = ''; }, 1500);
      },
      error: (err) => {
        this.addStudentMessage = err.error || 'Failed to add student.';
        this.addStudentError = true;
        this.addStudentLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  addSubject() {
    if (!this.newSubjectName.trim()) {
      this.addSubjectMessage = 'Subject name is required.';
      this.addSubjectError = true;
      return;
    }
    this.addSubjectLoading = true;
    this.addSubjectMessage = '';
    this.http.post(`${this.baseUrl}/subjects`, { name: this.newSubjectName.trim() }).subscribe({
      next: () => {
        this.addSubjectMessage = 'Subject added successfully!';
        this.addSubjectError = false;
        this.newSubjectName = '';
        this.addSubjectLoading = false;
        this.loadData();
        this.cdr.detectChanges();
        setTimeout(() => { this.showAddSubjectModal = false; this.addSubjectMessage = ''; }, 1500);
      },
      error: () => {
        this.addSubjectMessage = 'Failed to add subject.';
        this.addSubjectError = true;
        this.addSubjectLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  assign() {
    if (!this.assignStudentId || !this.assignSubjectId) {
      this.assignMessage = 'Please select both a student and a subject.';
      this.assignError = true;
      return;
    }
    if (this.isAlreadyAssigned(this.assignSubjectId)) {
      this.assignMessage = 'This student already has this subject.';
      this.assignError = true;
      return;
    }
    this.assignLoading = true;
    this.assignMessage = '';
    const params = new HttpParams()
      .set('studentId', this.assignStudentId.toString())
      .set('subjectId', this.assignSubjectId.toString());
    this.http.post(`${this.baseUrl}/management/assign`, {}, { params }).subscribe({
      next: () => {
        const student = this.students.find(s => s.id == this.assignStudentId);
        const subject = this.subjects.find(s => s.id == this.assignSubjectId);
        this.assignMessage = `"${subject?.name}" assigned to ${student?.name || student?.email}!`;
        this.assignError = false;
        this.assignSubjectId = 0;
        this.assignLoading = false;
        this.onAssignStudentChange(); // refresh student subjects
        this.loadData();
        this.cdr.detectChanges();
      },
      error: () => {
        this.assignMessage = 'Failed to assign subject.';
        this.assignError = true;
        this.assignLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  deleteStudent(id: number, nameOrEmail: string) {
    if (!confirm(`Delete "${nameOrEmail}"? This cannot be undone.`)) return;
    this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({
      next: () => { this.loadData(); this.cdr.detectChanges(); },
      error: () => alert('Failed to delete.')
    });
  }

  deleteSubject(id: number, name: string) {
    if (!confirm(`Delete "${name}"? This cannot be undone.`)) return;
    this.http.delete(`${this.baseUrl}/subjects/${id}`).subscribe({
      next: () => { this.loadData(); this.cdr.detectChanges(); },
      error: () => alert('Failed to delete.')
    });
  }
}
*/

/*
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Router } from '@angular/router';
import { ManagementService } from '../services/management.service';
import { EnrolledCountPipe } from '../enrolled-count.pipe';

@Component({
  selector: 'app-teacher-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, EnrolledCountPipe],
  templateUrl: './teacher-dashboard.component.html',
  styleUrl: './teacher-dashboard.component.css'
})
export class TeacherDashboardComponent implements OnInit {

  activeTab: 'dashboard' | 'students' | 'subjects' | 'teachers' | 'assign' | 'stats' = 'dashboard';

  students: any[] = [];
  subjects: any[] = [];
  teachers: any[] = [];

  // ── Add Student Modal ──
  showAddStudentModal  = false;
  newStudentName       = '';
  newStudentEmail      = '';
  newStudentPassword   = '';
  showPassword         = false;
  addStudentLoading    = false;
  addStudentMessage    = '';
  addStudentError      = false;

  // ── Add Subject Modal ──
  showAddSubjectModal  = false;
  newSubjectName       = '';
  addSubjectLoading    = false;
  addSubjectMessage    = '';
  addSubjectError      = false;

  // ── Add Teacher Modal ──
  showAddTeacherModal  = false;
  newTeacherName       = '';
  newTeacherEmail      = '';
  newTeacherPassword   = '';
  showTeacherPwd       = false;
  addTeacherLoading    = false;
  addTeacherMessage    = '';
  addTeacherError      = false;

  // ── Assign Subject → Student Modal ──
  showAssignModal      = false;
  assignStudentId: number = 0;
  assignSubjectId: number = 0;
  assignLoading        = false;
  assignMessage        = '';
  assignError          = false;
  selectedStudentSubjects: any[] = [];
  loadingStudentSubjects = false;

  // ── Assign Teacher → Subject Modal ──
  showAssignTeacherModal    = false;
  assignTeacherTeacherId: number = 0;
  assignTeacherSubjectId: number = 0;
  assignTeacherLoading      = false;
  assignTeacherMessage      = '';
  assignTeacherError        = false;

  private baseUrl = 'http://localhost:8080/api';

  constructor(
    private managementService: ManagementService,
    private http: HttpClient,
    private cdr: ChangeDetectorRef,
    private router: Router
  ) {}

  ngOnInit(): void { this.loadData(); }

  logout() {
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userRole');
    this.router.navigate(['/login']);
  }

  setTab(tab: typeof this.activeTab) {
    this.activeTab = tab;
    this.closeAllModals();
    this.clearMessages();
    this.loadData();
  }

  clearMessages() {
    this.addStudentMessage    = '';
    this.addSubjectMessage    = '';
    this.addTeacherMessage    = '';
    this.assignMessage        = '';
    this.assignTeacherMessage = '';
  }

  closeAllModals() {
    this.showAddStudentModal    = false;
    this.showAddSubjectModal    = false;
    this.showAddTeacherModal    = false;
    this.showAssignModal        = false;
    this.showAssignTeacherModal = false;
    this.clearMessages();
    this.selectedStudentSubjects = [];
    this.assignStudentId         = 0;
    this.assignSubjectId         = 0;
    this.assignTeacherTeacherId  = 0;
    this.assignTeacherSubjectId  = 0;
  }

  loadData() {
    this.managementService.getStudents().subscribe({ next: d => { this.students = d; this.cdr.detectChanges(); } });
    this.managementService.getSubjects().subscribe({ next: d => { this.subjects = d; this.cdr.detectChanges(); } });
    this.managementService.getTeachers().subscribe({ next: d => { this.teachers = d; this.cdr.detectChanges(); } });
  }

  // ── Computed stats ──────────────────────────────────────

  get totalEnrollments(): number {
    return this.students.reduce((s, e) => s + (e.subjects?.length || 0), 0);
  }

  get avgSubjectsPerStudent(): string {
    return this.students.length ? (this.totalEnrollments / this.students.length).toFixed(1) : '0';
  }

  get mostPopularSubject(): string {
    if (!this.subjects.length || !this.students.length) return '—';
    const counts: Record<number, number> = {};
    for (const s of this.students) for (const sub of s.subjects || []) counts[sub.id] = (counts[sub.id] || 0) + 1;
    let maxId = -1, maxCount = 0;
    for (const [id, count] of Object.entries(counts)) if (+count > maxCount) { maxCount = +count; maxId = +id; }
    return this.subjects.find(s => s.id === maxId)?.name ?? '—';
  }

  get topSubjectPct(): number {
    if (!this.students.length || !this.subjects.length) return 0;
    const counts: Record<number, number> = {};
    for (const s of this.students) for (const sub of s.subjects || []) counts[sub.id] = (counts[sub.id] || 0) + 1;
    const max = Math.max(...Object.values(counts), 0);
    return max ? Math.round((max / this.students.length) * 100) : 0;
  }

  get subjectEnrollmentData(): { name: string; count: number; pct: number }[] {
    if (!this.subjects.length) return [];
    const counts: Record<number, number> = {};
    for (const s of this.students) for (const sub of s.subjects || []) counts[sub.id] = (counts[sub.id] || 0) + 1;
    const max = Math.max(...Object.values(counts), 1);
    return this.subjects
      .map(sub => ({ name: sub.name, count: counts[sub.id] || 0, pct: Math.round(((counts[sub.id] || 0) / max) * 100) }))
      .sort((a, b) => b.count - a.count);
  }

  get studentLoadData(): { name: string; count: number; pct: number }[] {
    if (!this.students.length) return [];
    const max = Math.max(...this.students.map(s => s.subjects?.length || 0), 1);
    return this.students
      .map(s => ({ name: s.name || s.email, count: s.subjects?.length || 0, pct: Math.round(((s.subjects?.length || 0) / max) * 100) }))
      .sort((a, b) => b.count - a.count);
  }

  get enrollmentDistribution(): { label: string; count: number }[] {
    const d: Record<string, number> = { '0 subjects': 0, '1–2 subjects': 0, '3–4 subjects': 0, '5+ subjects': 0 };
    for (const s of this.students) {
      const n = s.subjects?.length || 0;
      if (n === 0) d['0 subjects']++; else if (n <= 2) d['1–2 subjects']++; else if (n <= 4) d['3–4 subjects']++; else d['5+ subjects']++;
    }
    return Object.entries(d).map(([label, count]) => ({ label, count }));
  }

  // ── Helpers ─────────────────────────────────────────────

  getInitial(s: any): string { return (s.name || s.email || '?')[0].toUpperCase(); }
  getDisplayName(s: any): string { return s.name || s.email || 'Unknown'; }

  getStudentsForSubject(subjectId: number): any[] {
    return this.students.filter(s => (s.subjects || []).some((sub: any) => sub.id === subjectId));
  }

  getTeacherForSubject(subjectId: number): any {
    return this.subjects.find(s => s.id === subjectId)?.teacher || null;
  }

  getSubjectsForTeacher(teacherId: number): any[] {
    return this.subjects.filter(s => s.teacher?.id === teacherId);
  }

  // ── Assign subject→student helpers ─────────────────────

  onAssignStudentChange() {
    this.assignSubjectId = 0;
    this.selectedStudentSubjects = [];
    if (!this.assignStudentId) return;
    this.loadingStudentSubjects = true;
    this.http.get<any[]>(`${this.baseUrl}/management/student-details/${this.assignStudentId}`).subscribe({
      next: d => { this.selectedStudentSubjects = d; this.loadingStudentSubjects = false; this.cdr.detectChanges(); },
      error: () => { this.loadingStudentSubjects = false; }
    });
  }

  isAlreadyAssigned(subjectId: number): boolean {
    return this.selectedStudentSubjects.some(s => s.id === subjectId);
  }

  get availableSubjectsForAssign(): any[] {
    return this.subjects.filter(s => !this.isAlreadyAssigned(s.id));
  }

  // ── CRUD operations ─────────────────────────────────────

  addStudent() {
    if (!this.newStudentEmail || !this.newStudentPassword) { this.addStudentMessage = 'Email and password are required.'; this.addStudentError = true; return; }
    this.addStudentLoading = true;
    const body: any = { email: this.newStudentEmail.trim(), password: this.newStudentPassword, role: 'STUDENT' };
    if (this.newStudentName.trim()) body.name = this.newStudentName.trim();
    this.http.post(`${this.baseUrl}/auth/signup`, body).subscribe({
      next: () => {
        this.addStudentMessage = 'Student added!'; this.addStudentError = false;
        this.newStudentName = this.newStudentEmail = this.newStudentPassword = '';
        this.addStudentLoading = false; this.loadData(); this.cdr.detectChanges();
        setTimeout(() => { this.showAddStudentModal = false; this.addStudentMessage = ''; }, 1500);
      },
      error: err => { this.addStudentMessage = err.error || 'Failed.'; this.addStudentError = true; this.addStudentLoading = false; this.cdr.detectChanges(); }
    });
  }

  addSubject() {
    if (!this.newSubjectName.trim()) { this.addSubjectMessage = 'Name required.'; this.addSubjectError = true; return; }
    this.addSubjectLoading = true;
    this.http.post(`${this.baseUrl}/subjects`, { name: this.newSubjectName.trim() }).subscribe({
      next: () => {
        this.addSubjectMessage = 'Subject added!'; this.addSubjectError = false;
        this.newSubjectName = ''; this.addSubjectLoading = false; this.loadData(); this.cdr.detectChanges();
        setTimeout(() => { this.showAddSubjectModal = false; this.addSubjectMessage = ''; }, 1500);
      },
      error: () => { this.addSubjectMessage = 'Failed.'; this.addSubjectError = true; this.addSubjectLoading = false; this.cdr.detectChanges(); }
    });
  }

  addTeacher() {
    if (!this.newTeacherEmail || !this.newTeacherPassword) { this.addTeacherMessage = 'Email and password are required.'; this.addTeacherError = true; return; }
    this.addTeacherLoading = true;
    const body: any = { email: this.newTeacherEmail.trim(), password: this.newTeacherPassword, role: 'TEACHER' };
    if (this.newTeacherName.trim()) body.name = this.newTeacherName.trim();
    this.http.post(`${this.baseUrl}/auth/signup`, body).subscribe({
      next: () => {
        this.addTeacherMessage = 'Teacher added!'; this.addTeacherError = false;
        this.newTeacherName = this.newTeacherEmail = this.newTeacherPassword = '';
        this.addTeacherLoading = false; this.loadData(); this.cdr.detectChanges();
        setTimeout(() => { this.showAddTeacherModal = false; this.addTeacherMessage = ''; }, 1500);
      },
      error: err => { this.addTeacherMessage = err.error || 'Failed.'; this.addTeacherError = true; this.addTeacherLoading = false; this.cdr.detectChanges(); }
    });
  }

  assign() {
    if (!this.assignStudentId || !this.assignSubjectId) { this.assignMessage = 'Select both student and subject.'; this.assignError = true; return; }
    if (this.isAlreadyAssigned(this.assignSubjectId)) { this.assignMessage = 'Already assigned!'; this.assignError = true; return; }
    this.assignLoading = true;
    const params = new HttpParams().set('studentId', this.assignStudentId.toString()).set('subjectId', this.assignSubjectId.toString());
    this.http.post(`${this.baseUrl}/management/assign`, {}, { params }).subscribe({
      next: () => {
        const stu = this.students.find(s => s.id == this.assignStudentId);
        const sub = this.subjects.find(s => s.id == this.assignSubjectId);
        this.assignMessage = `"${sub?.name}" → ${stu?.name || stu?.email}!`; this.assignError = false;
        this.assignSubjectId = 0; this.assignLoading = false;
        this.onAssignStudentChange(); this.loadData(); this.cdr.detectChanges();
      },
      error: () => { this.assignMessage = 'Failed.'; this.assignError = true; this.assignLoading = false; this.cdr.detectChanges(); }
    });
  }

  assignTeacher() {
    if (!this.assignTeacherTeacherId || !this.assignTeacherSubjectId) { this.assignTeacherMessage = 'Select both teacher and subject.'; this.assignTeacherError = true; return; }
    this.assignTeacherLoading = true;
    const params = new HttpParams().set('teacherId', this.assignTeacherTeacherId.toString()).set('subjectId', this.assignTeacherSubjectId.toString());
    this.http.post(`${this.baseUrl}/management/assign-teacher`, {}, { params }).subscribe({
      next: () => {
        const tea = this.teachers.find(t => t.id == this.assignTeacherTeacherId);
        const sub = this.subjects.find(s => s.id == this.assignTeacherSubjectId);
        this.assignTeacherMessage = `${tea?.name || tea?.email} → "${sub?.name}"!`; this.assignTeacherError = false;
        this.assignTeacherTeacherId = 0; this.assignTeacherSubjectId = 0;
        this.assignTeacherLoading = false; this.loadData(); this.cdr.detectChanges();
      },
      error: () => { this.assignTeacherMessage = 'Failed.'; this.assignTeacherError = true; this.assignTeacherLoading = false; this.cdr.detectChanges(); }
    });
  }

  removeSubjectFromStudent(studentId: number, subjectId: number, subjectName: string) {
    if (!confirm(`Remove "${subjectName}" from this student?`)) return;
    this.http.delete(`${this.baseUrl}/management/student/${studentId}/subject/${subjectId}`).subscribe({
      next: () => { this.loadData(); this.cdr.detectChanges(); },
      error: () => alert('Failed to remove subject.')
    });
  }

  deleteStudent(id: number, name: string) {
    if (!confirm(`Delete "${name}"? This cannot be undone.`)) return;
    this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({
      next: () => { this.loadData(); this.cdr.detectChanges(); },
      error: () => alert('Failed to delete.')
    });
  }

  deleteSubject(id: number, name: string) {
    if (!confirm(`Delete "${name}"? This cannot be undone.`)) return;
    this.http.delete(`${this.baseUrl}/subjects/${id}`).subscribe({
      next: () => { this.loadData(); this.cdr.detectChanges(); },
      error: () => alert('Failed to delete.')
    });
  }

  deleteTeacher(id: number, name: string) {
    if (!confirm(`Delete teacher "${name}"? This cannot be undone.`)) return;
    this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({
      next: () => { this.loadData(); this.cdr.detectChanges(); },
      error: () => alert('Failed to delete.')
    });
  }
}
*/
/*
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Router } from '@angular/router';
import { ManagementService } from '../services/management.service';


@Component({
  selector: 'app-teacher-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './teacher-dashboard.component.html',
  styleUrl: './teacher-dashboard.component.css'
})
export class TeacherDashboardComponent implements OnInit {

  activeTab: 'dashboard' | 'students' | 'subjects' | 'teachers' | 'assign' | 'stats' = 'dashboard';

  students: any[] = [];
  subjects: any[] = [];
  teachers: any[] = [];

  // ── Add Student Modal ──
  showAddStudentModal = false;
  newStudentName = ''; newStudentEmail = ''; newStudentPassword = '';
  showStudentPwd = false; addStudentLoading = false;
  addStudentMessage = ''; addStudentError = false;

  // ── Add Subject Modal ──
  showAddSubjectModal = false;
  newSubjectName = ''; addSubjectLoading = false;
  addSubjectMessage = ''; addSubjectError = false;

  // ── Add Teacher Modal ──
  showAddTeacherModal = false;
  newTeacherName = ''; newTeacherEmail = ''; newTeacherPassword = '';
  showTeacherPwd = false; addTeacherLoading = false;
  addTeacherMessage = ''; addTeacherError = false;

  // ── Assign Student → Subject Modal ──
  showAssignModal = false;
  assignStudentId: number = 0; assignSubjectId: number = 0;
  assignLoading = false; assignMessage = ''; assignError = false;
  selectedStudentSubjects: any[] = []; loadingStudentSubjects = false;

  // ── Assign Teacher → Subject Modal ──
  showAssignTeacherModal = false;
  assignTeacherTeacherId: number = 0; assignTeacherSubjectId: number = 0;
  assignTeacherLoading = false; assignTeacherMessage = ''; assignTeacherError = false;

  private baseUrl = 'http://localhost:8080/api';

  constructor(
    private managementService: ManagementService,
    private http: HttpClient,
    private cdr: ChangeDetectorRef,
    private router: Router
  ) {}

  ngOnInit(): void { this.loadData(); }

  logout() {
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userRole');
    this.router.navigate(['/login']);
  }

  setTab(tab: typeof this.activeTab) {
    this.activeTab = tab;
    this.closeAllModals();
    this.clearMessages();
    this.loadData();
  }

  clearMessages() {
    this.addStudentMessage = ''; this.addSubjectMessage = '';
    this.addTeacherMessage = ''; this.assignMessage = ''; this.assignTeacherMessage = '';
  }

  closeAllModals() {
    this.showAddStudentModal = false; this.showAddSubjectModal = false;
    this.showAddTeacherModal = false; this.showAssignModal = false;
    this.showAssignTeacherModal = false;
    this.clearMessages();
    this.selectedStudentSubjects = [];
    this.assignStudentId = 0; this.assignSubjectId = 0;
    this.assignTeacherTeacherId = 0; this.assignTeacherSubjectId = 0;
  }

  loadData() {
    this.managementService.getStudents().subscribe({ next: d => { this.students = d; this.cdr.detectChanges(); } });
    this.managementService.getSubjects().subscribe({ next: d => { this.subjects = d; this.cdr.detectChanges(); } });
    this.managementService.getTeachers().subscribe({ next: d => { this.teachers = d; this.cdr.detectChanges(); } });
  }

  // ── Stats ────────────────────────────────────────────────

  get totalEnrollments(): number {
    return this.students.reduce((s, e) => s + (e.subjects?.length || 0), 0);
  }
  get avgSubjectsPerStudent(): string {
    return this.students.length ? (this.totalEnrollments / this.students.length).toFixed(1) : '0';
  }
  get mostPopularSubject(): string {
    if (!this.subjects.length || !this.students.length) return '—';
    const c: Record<number, number> = {};
    for (const s of this.students) for (const sub of s.subjects || []) c[sub.id] = (c[sub.id] || 0) + 1;
    let maxId = -1, maxCount = 0;
    for (const [id, count] of Object.entries(c)) if (+count > maxCount) { maxCount = +count; maxId = +id; }
    return this.subjects.find(s => s.id === maxId)?.name ?? '—';
  }
  get topSubjectPct(): number {
    if (!this.students.length) return 0;
    const c: Record<number, number> = {};
    for (const s of this.students) for (const sub of s.subjects || []) c[sub.id] = (c[sub.id] || 0) + 1;
    const max = Math.max(...Object.values(c), 0);
    return max ? Math.round((max / this.students.length) * 100) : 0;
  }
  get subjectEnrollmentData(): { name: string; count: number; pct: number }[] {
    if (!this.subjects.length) return [];
    const c: Record<number, number> = {};
    for (const s of this.students) for (const sub of s.subjects || []) c[sub.id] = (c[sub.id] || 0) + 1;
    const max = Math.max(...Object.values(c), 1);
    return this.subjects.map(sub => ({ name: sub.name, count: c[sub.id] || 0, pct: Math.round(((c[sub.id] || 0) / max) * 100) }))
      .sort((a, b) => b.count - a.count);
  }
  get studentLoadData(): { name: string; count: number; pct: number }[] {
    if (!this.students.length) return [];
    const max = Math.max(...this.students.map(s => s.subjects?.length || 0), 1);
    return this.students.map(s => ({ name: s.name || s.email, count: s.subjects?.length || 0, pct: Math.round(((s.subjects?.length || 0) / max) * 100) }))
      .sort((a, b) => b.count - a.count);
  }
  get enrollmentDistribution(): { label: string; count: number }[] {
    const d: Record<string, number> = { '0 subjects': 0, '1–2 subjects': 0, '3–4 subjects': 0, '5+ subjects': 0 };
    for (const s of this.students) {
      const n = s.subjects?.length || 0;
      if (n === 0) d['0 subjects']++; else if (n <= 2) d['1–2 subjects']++; else if (n <= 4) d['3–4 subjects']++; else d['5+ subjects']++;
    }
    return Object.entries(d).map(([label, count]) => ({ label, count }));
  }

  // ── Helpers ─────────────────────────────────────────────

  getInitial(s: any): string { return (s.name || s.email || '?')[0].toUpperCase(); }
  getDisplayName(s: any): string { return s.name || s.email || 'Unknown'; }
  getSubjectsForTeacher(teacherId: number): any[] { return this.subjects.filter(s => s.teacher?.id === teacherId); }

  onAssignStudentChange() {
    this.assignSubjectId = 0; this.selectedStudentSubjects = [];
    if (!this.assignStudentId) return;
    this.loadingStudentSubjects = true;
    this.http.get<any[]>(`${this.baseUrl}/management/student-details/${this.assignStudentId}`).subscribe({
      next: d => { this.selectedStudentSubjects = d; this.loadingStudentSubjects = false; this.cdr.detectChanges(); },
      error: () => { this.loadingStudentSubjects = false; }
    });
  }
  isAlreadyAssigned(subjectId: number): boolean { return this.selectedStudentSubjects.some(s => s.id === subjectId); }
  get availableSubjectsForAssign(): any[] { return this.subjects.filter(s => !this.isAlreadyAssigned(s.id)); }

  // ── CRUD ─────────────────────────────────────────────────

  addStudent() {
    if (!this.newStudentEmail || !this.newStudentPassword) { this.addStudentMessage = 'Email and password required.'; this.addStudentError = true; return; }
    this.addStudentLoading = true;
    const body: any = { email: this.newStudentEmail.trim(), password: this.newStudentPassword, role: 'STUDENT' };
    if (this.newStudentName.trim()) body.name = this.newStudentName.trim();
    this.http.post(`${this.baseUrl}/auth/signup`, body).subscribe({
      next: () => {
        this.addStudentMessage = 'Student added!'; this.addStudentError = false;
        this.newStudentName = this.newStudentEmail = this.newStudentPassword = '';
        this.addStudentLoading = false; this.loadData(); this.cdr.detectChanges();
        setTimeout(() => { this.showAddStudentModal = false; this.addStudentMessage = ''; }, 1500);
      },
      error: err => { this.addStudentMessage = err.error || 'Failed.'; this.addStudentError = true; this.addStudentLoading = false; this.cdr.detectChanges(); }
    });
  }

  addSubject() {
    if (!this.newSubjectName.trim()) { this.addSubjectMessage = 'Name required.'; this.addSubjectError = true; return; }
    this.addSubjectLoading = true;
    this.http.post(`${this.baseUrl}/subjects`, { name: this.newSubjectName.trim() }).subscribe({
      next: () => {
        this.addSubjectMessage = 'Subject added!'; this.addSubjectError = false;
        this.newSubjectName = ''; this.addSubjectLoading = false; this.loadData(); this.cdr.detectChanges();
        setTimeout(() => { this.showAddSubjectModal = false; this.addSubjectMessage = ''; }, 1500);
      },
      error: () => { this.addSubjectMessage = 'Failed.'; this.addSubjectError = true; this.addSubjectLoading = false; this.cdr.detectChanges(); }
    });
  }

  addTeacher() {
    if (!this.newTeacherEmail || !this.newTeacherPassword) { this.addTeacherMessage = 'Email and password required.'; this.addTeacherError = true; return; }
    this.addTeacherLoading = true;
    const body: any = { email: this.newTeacherEmail.trim(), password: this.newTeacherPassword, role: 'TEACHER' };
    if (this.newTeacherName.trim()) body.name = this.newTeacherName.trim();
    this.http.post(`${this.baseUrl}/auth/signup`, body).subscribe({
      next: () => {
        this.addTeacherMessage = 'Teacher added!'; this.addTeacherError = false;
        this.newTeacherName = this.newTeacherEmail = this.newTeacherPassword = '';
        this.addTeacherLoading = false; this.loadData(); this.cdr.detectChanges();
        setTimeout(() => { this.showAddTeacherModal = false; this.addTeacherMessage = ''; }, 1500);
      },
      error: err => { this.addTeacherMessage = err.error || 'Failed.'; this.addTeacherError = true; this.addTeacherLoading = false; this.cdr.detectChanges(); }
    });
  }

  assign() {
    if (!this.assignStudentId || !this.assignSubjectId) { this.assignMessage = 'Select both student and subject.'; this.assignError = true; return; }
    if (this.isAlreadyAssigned(this.assignSubjectId)) { this.assignMessage = 'Already assigned!'; this.assignError = true; return; }
    this.assignLoading = true;
    const params = new HttpParams().set('studentId', this.assignStudentId.toString()).set('subjectId', this.assignSubjectId.toString());
    this.http.post(`${this.baseUrl}/management/assign`, {}, { params }).subscribe({
      next: () => {
        const stu = this.students.find(s => s.id == this.assignStudentId);
        const sub = this.subjects.find(s => s.id == this.assignSubjectId);
        this.assignMessage = `"${sub?.name}" → ${stu?.name || stu?.email}!`; this.assignError = false;
        this.assignSubjectId = 0; this.assignLoading = false;
        this.onAssignStudentChange(); this.loadData(); this.cdr.detectChanges();
      },
      error: () => { this.assignMessage = 'Failed.'; this.assignError = true; this.assignLoading = false; this.cdr.detectChanges(); }
    });
  }

  assignTeacher() {
    if (!this.assignTeacherTeacherId || !this.assignTeacherSubjectId) { this.assignTeacherMessage = 'Select both teacher and subject.'; this.assignTeacherError = true; return; }
    this.assignTeacherLoading = true;
    const params = new HttpParams().set('teacherId', this.assignTeacherTeacherId.toString()).set('subjectId', this.assignTeacherSubjectId.toString());
    this.http.post(`${this.baseUrl}/management/assign-teacher`, {}, { params }).subscribe({
      next: () => {
        const tea = this.teachers.find(t => t.id == this.assignTeacherTeacherId);
        const sub = this.subjects.find(s => s.id == this.assignTeacherSubjectId);
        this.assignTeacherMessage = `${tea?.name || tea?.email} → "${sub?.name}"!`; this.assignTeacherError = false;
        this.assignTeacherTeacherId = 0; this.assignTeacherSubjectId = 0;
        this.assignTeacherLoading = false; this.loadData(); this.cdr.detectChanges();
      },
      error: () => { this.assignTeacherMessage = 'Failed.'; this.assignTeacherError = true; this.assignTeacherLoading = false; this.cdr.detectChanges(); }
    });
  }

  removeSubjectFromStudent(studentId: number, subjectId: number, subjectName: string) {
    if (!confirm(`Remove "${subjectName}" from this student?`)) return;
    this.http.delete(`${this.baseUrl}/management/student/${studentId}/subject/${subjectId}`).subscribe({
      next: () => { this.loadData(); this.cdr.detectChanges(); },
      error: () => alert('Failed to remove subject.')
    });
  }

  removeSubjectFromTeacher(teacherId: number, subjectId: number, subjectName: string): void {
  const confirmed = confirm(`Are you sure you want to unassign "${subjectName}" from this teacher?`);
  
  if (confirmed) {
    // If you are using a backend service, call it here. For example:
    // this.managementService.unassignSubjectFromTeacher(teacherId, subjectId).subscribe({
    //   next: () => {
    //     this.refreshData(); // Refresh list to catch backend update
    //   },
    //   error: (err) => console.error('Failed to unassign subject:', err)
    // });

    // Client-side fallback: Update the local subjects array state immediately
    this.subjects = this.subjects.map(subject => {
      if (subject.id === subjectId) {
        // Remove the teacher assignment from this subject
        return { ...subject, teacher: null };
      }
      return subject;
    });
    
    console.log(`Successfully unassigned ${subjectName} from teacher ID ${teacherId}`);
  }
}

  deleteStudent(id: number, name: string) {
    if (!confirm(`Delete "${name}"? This cannot be undone.`)) return;
    this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({
      next: () => { this.loadData(); this.cdr.detectChanges(); },
      error: () => alert('Failed.')
    });
  }

  deleteSubject(id: number, name: string) {
    if (!confirm(`Delete "${name}"? This cannot be undone.`)) return;
    this.http.delete(`${this.baseUrl}/subjects/${id}`).subscribe({
      next: () => { this.loadData(); this.cdr.detectChanges(); },
      error: () => alert('Failed.')
    });
  }

  deleteTeacher(id: number, name: string) {
    if (!confirm(`Delete teacher "${name}"? This cannot be undone.`)) return;
    this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({
      next: () => { this.loadData(); this.cdr.detectChanges(); },
      error: () => alert('Failed.')
    });
  }
}
*/
/*
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Router } from '@angular/router';
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-teacher-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './teacher-dashboard.component.html',
  styleUrl: './teacher-dashboard.component.css'
})
export class TeacherDashboardComponent implements OnInit {

  activeTab: 'dashboard' | 'students' | 'subjects' | 'teachers' | 'assign' | 'stats' | 'routine' = 'dashboard';

  students: any[] = [];
  subjects: any[] = [];
  teachers: any[] = [];

  // ── Routine Data ──
  routineDays = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'];
  routineSlots = ['08:30-10:00', '10:00-11:30', '11:00-12:30', '14:00-15:30'];
  routines: any[] = [];

  // ── Confirm Modal ──
  showConfirmModal   = false;
  confirmTitle       = '';
  confirmMessage     = '';
  confirmAction: (() => void) | null = null;

  // ── Add Student Modal ──
  showAddStudentModal = false;
  newStudentName       = '';
  newStudentEmail      = '';
  newStudentPassword   = '';
  newStudentDept       = '';
  newStudentPhone      = '';
  newStudentSemester   = '';
  showStudentPwd       = false;
  addStudentLoading    = false;
  addStudentMessage    = '';
  addStudentError      = false;

  // ── Add Subject Modal ──
  showAddSubjectModal = false;
  newSubjectName      = '';
  addSubjectLoading   = false;
  addSubjectMessage   = '';
  addSubjectError     = false;

  // ── Add Teacher Modal ──
  showAddTeacherModal = false;
  newTeacherName      = '';
  newTeacherEmail     = '';
  newTeacherPassword  = '';
  newTeacherDept      = '';
  newTeacherPhone     = '';
  showTeacherPwd      = false;
  addTeacherLoading   = false;
  addTeacherMessage   = '';
  addTeacherError     = false;

  // ── Assign Student → Subject Modal ──
  showAssignModal       = false;
  assignStudentId: number = 0;
  assignSubjectId: number = 0;
  assignLoading         = false;
  assignMessage         = '';
  assignError           = false;
  selectedStudentSubjects: any[] = [];
  loadingStudentSubjects = false;

  // ── Assign Teacher → Subject Modal ──
  showAssignTeacherModal    = false;
  assignTeacherTeacherId: number = 0;
  assignTeacherSubjectId: number = 0;
  assignTeacherLoading      = false;
  assignTeacherMessage      = '';
  assignTeacherError        = false;

  // ── Routine Modal ──
  showRoutineModal    = false;
  newRoutineDay       = '';
  newRoutineSlot      = '';
  newRoutineSubjectId = 0;
  newRoutineTeacherId = 0;
  newRoutineRoom      = '';
  routineLoading      = false;
  routineMessage      = '';
  routineError        = false;

  private baseUrl = 'http://localhost:8080/api';

  constructor(
    private managementService: ManagementService,
    private http: HttpClient,
    private cdr: ChangeDetectorRef,
    private router: Router
  ) {}

  ngOnInit(): void { 
    this.loadData(); 
    this.loadRoutine();
  }

  logout() {
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userRole');
    this.router.navigate(['/login']);
  }

  setTab(tab: typeof this.activeTab) {
    this.activeTab = tab;
    this.closeAllModals();
    this.clearMessages();
    this.loadData();
    if(tab === 'routine') {
      this.loadRoutine();
    }
  }

  clearMessages() {
    this.addStudentMessage    = '';
    this.addSubjectMessage    = '';
    this.addTeacherMessage    = '';
    this.assignMessage        = '';
    this.assignTeacherMessage = '';
    this.routineMessage       = '';
  }

  closeAllModals() {
    this.showAddStudentModal    = false;
    this.showAddSubjectModal    = false;
    this.showAddTeacherModal    = false;
    this.showAssignModal        = false;
    this.showAssignTeacherModal = false;
    this.showConfirmModal       = false;
    this.showRoutineModal       = false;
    
    this.clearMessages();
    
    this.selectedStudentSubjects = [];
    this.assignStudentId         = 0;
    this.assignSubjectId         = 0;
    this.assignTeacherTeacherId  = 0;
    this.assignTeacherSubjectId  = 0;
    
    this.newRoutineDay       = '';
    this.newRoutineSlot      = '';
    this.newRoutineSubjectId = 0;
    this.newRoutineTeacherId = 0;
    this.newRoutineRoom      = '';
  }

  loadData() {
    this.managementService.getStudents().subscribe({ next: d => { this.students = d; this.cdr.detectChanges(); } });
    this.managementService.getSubjects().subscribe({ next: d => { this.subjects = d; this.cdr.detectChanges(); } });
    this.managementService.getTeachers().subscribe({ next: d => { this.teachers = d; this.cdr.detectChanges(); } });
  }

  // ── Custom Confirm Modal ──────────────────────────────────
  openConfirm(title: string, message: string, action: () => void) {
    this.confirmTitle   = title;
    this.confirmMessage = message;
    this.confirmAction  = action;
    this.showConfirmModal = true;
  }

  onConfirmYes() {
    this.showConfirmModal = false;
    if (this.confirmAction) this.confirmAction();
    this.confirmAction = null;
  }

  onConfirmNo() {
    this.showConfirmModal = false;
    this.confirmAction = null;
  }

  // ── Stats ─────────────────────────────────────────────────
  get totalEnrollments(): number { return this.students.reduce((s, e) => s + (e.subjects?.length || 0), 0); }
  get avgSubjectsPerStudent(): string { return this.students.length ? (this.totalEnrollments / this.students.length).toFixed(1) : '0'; }
  
  get mostPopularSubject(): string {
    if (!this.subjects.length || !this.students.length) return '—';
    const c: Record<number, number> = {};
    for (const s of this.students) for (const sub of s.subjects || []) c[sub.id] = (c[sub.id] || 0) + 1;
    let maxId = -1, maxCount = 0;
    for (const [id, count] of Object.entries(c)) if (+count > maxCount) { maxCount = +count; maxId = +id; }
    return this.subjects.find(s => s.id === maxId)?.name ?? '—';
  }
  
  get topSubjectPct(): number {
    if (!this.students.length) return 0;
    const c: Record<number, number> = {};
    for (const s of this.students) for (const sub of s.subjects || []) c[sub.id] = (c[sub.id] || 0) + 1;
    const max = Math.max(...Object.values(c), 0);
    return max ? Math.round((max / this.students.length) * 100) : 0;
  }
  
  get subjectEnrollmentData(): { name: string; count: number; pct: number }[] {
    if (!this.subjects.length) return [];
    const c: Record<number, number> = {};
    for (const s of this.students) for (const sub of s.subjects || []) c[sub.id] = (c[sub.id] || 0) + 1;
    const max = Math.max(...Object.values(c), 1);
    return this.subjects.map(sub => ({ name: sub.name, count: c[sub.id] || 0, pct: Math.round(((c[sub.id] || 0) / max) * 100) })).sort((a, b) => b.count - a.count);
  }
  
  get studentLoadData(): { name: string; count: number; pct: number }[] {
    if (!this.students.length) return [];
    const max = Math.max(...this.students.map(s => s.subjects?.length || 0), 1);
    return this.students.map(s => ({ name: s.name || s.email, count: s.subjects?.length || 0, pct: Math.round(((s.subjects?.length || 0) / max) * 100) })).sort((a, b) => b.count - a.count);
  }
  
  get enrollmentDistribution(): { label: string; count: number }[] {
    const d: Record<string, number> = { '0 subjects': 0, '1–2 subjects': 0, '3–4 subjects': 0, '5+ subjects': 0 };
    for (const s of this.students) {
      const n = s.subjects?.length || 0;
      if (n === 0) d['0 subjects']++; else if (n <= 2) d['1–2 subjects']++; else if (n <= 4) d['3–4 subjects']++; else d['5+ subjects']++;
    }
    return Object.entries(d).map(([label, count]) => ({ label, count }));
  }

  // ── Helpers ──────────────────────────────────────────────
  getInitial(s: any): string { return (s.name || s.email || '?')[0].toUpperCase(); }
  getDisplayName(s: any): string { return s.name || s.email || 'Unknown'; }
  getSubjectsForTeacher(teacherId: number): any[] { return this.subjects.filter(s => s.teacher?.id === teacherId); }
  formatStudentId(id: number): string { return 'STU-' + String(id).padStart(5, '0'); }

  // Visual Helper for Routine UI
  getSubjectColor(subjectName: string): string {
    if (!subjectName) return '#252538';
    const colors = ['#1e3a8a', '#064e3b', '#4c1d95', '#78350f', '#831843', '#115e59', '#3730a3', '#0f766e'];
    let hash = 0;
    for (let i = 0; i < subjectName.length; i++) {
      hash = subjectName.charCodeAt(i) + ((hash << 5) - hash);
    }
    return colors[Math.abs(hash) % colors.length];
  }

  onAssignStudentChange() {
    this.assignSubjectId = 0;
    this.selectedStudentSubjects = [];
    if (!this.assignStudentId) return;
    this.loadingStudentSubjects = true;
    this.http.get<any[]>(`${this.baseUrl}/management/student-details/${this.assignStudentId}`).subscribe({
      next: d => { this.selectedStudentSubjects = d; this.loadingStudentSubjects = false; this.cdr.detectChanges(); },
      error: () => { this.loadingStudentSubjects = false; }
    });
  }
  
  isAlreadyAssigned(subjectId: number): boolean { return this.selectedStudentSubjects.some(s => s.id === subjectId); }
  get availableSubjectsForAssign(): any[] { return this.subjects.filter(s => !this.isAlreadyAssigned(s.id)); }

  // ── CRUD Operations ──────────────────────────────────────
  addStudent() {
    if (!this.newStudentEmail || !this.newStudentPassword) {
      this.addStudentMessage = 'Email and password required.';
      this.addStudentError = true;
      return;
    }
    this.addStudentLoading = true;
    const body: any = { email: this.newStudentEmail.trim(), password: this.newStudentPassword, role: 'STUDENT' };
    if (this.newStudentName.trim()) body.name = this.newStudentName.trim();
    if (this.newStudentDept.trim()) body.department = this.newStudentDept.trim();
    if (this.newStudentPhone.trim()) body.phone = this.newStudentPhone.trim();
    if (this.newStudentSemester.trim()) body.semester = this.newStudentSemester.trim();
    
    this.http.post(`${this.baseUrl}/auth/signup`, body).subscribe({
      next: () => {
        this.addStudentMessage = 'Student added!'; this.addStudentError = false;
        this.addStudentLoading = false; this.loadData(); this.cdr.detectChanges();
        setTimeout(() => { this.closeAllModals(); }, 1500);
      },
      error: err => {
        this.addStudentMessage = err.error || 'Failed.'; this.addStudentError = true;
        this.addStudentLoading = false; this.cdr.detectChanges();
      }
    });
  }

  addSubject() {
    if (!this.newSubjectName.trim()) { this.addSubjectMessage = 'Name required.'; this.addSubjectError = true; return; }
    this.addSubjectLoading = true;
    this.http.post(`${this.baseUrl}/subjects`, { name: this.newSubjectName.trim() }).subscribe({
      next: () => {
        this.addSubjectMessage = 'Subject added!'; this.addSubjectError = false;
        this.addSubjectLoading = false; this.loadData(); this.cdr.detectChanges();
        setTimeout(() => { this.closeAllModals(); }, 1500);
      },
      error: () => { this.addSubjectMessage = 'Failed.'; this.addSubjectError = true; this.addSubjectLoading = false; this.cdr.detectChanges(); }
    });
  }

  addTeacher() {
    if (!this.newTeacherEmail || !this.newTeacherPassword) { this.addTeacherMessage = 'Email and password required.'; this.addTeacherError = true; return; }
    this.addTeacherLoading = true;
    const body: any = {
      email: this.newTeacherEmail.trim(),
      password: this.newTeacherPassword,
      role: 'TEACHER'
    };
    if (this.newTeacherName.trim()) body.name = this.newTeacherName.trim();
    if (this.newTeacherDept.trim()) body.department = this.newTeacherDept.trim();
    if (this.newTeacherPhone.trim()) body.phone = this.newTeacherPhone.trim();
    this.http.post(`${this.baseUrl}/auth/signup`, body).subscribe({
      next: () => {
        this.addTeacherMessage = 'Teacher added!'; this.addTeacherError = false;
        this.addTeacherLoading = false; this.loadData(); this.cdr.detectChanges();
        setTimeout(() => { this.closeAllModals(); }, 1500);
      },
      error: err => { this.addTeacherMessage = err.error || 'Failed.'; this.addTeacherError = true; this.addTeacherLoading = false; this.cdr.detectChanges(); }
    });
  }

  assign() {
    if (!this.assignStudentId || !this.assignSubjectId) { this.assignMessage = 'Select both student and subject.'; this.assignError = true; return; }
    this.assignLoading = true;
    const params = new HttpParams().set('studentId', this.assignStudentId.toString()).set('subjectId', this.assignSubjectId.toString());
    this.http.post(`${this.baseUrl}/management/assign`, {}, { params }).subscribe({
      next: () => {
        this.assignMessage = `Assignment successful!`; this.assignError = false;
        this.assignLoading = false; this.onAssignStudentChange(); this.loadData(); this.cdr.detectChanges();
      },
      error: () => { this.assignMessage = 'Failed.'; this.assignError = true; this.assignLoading = false; this.cdr.detectChanges(); }
    });
  }

  assignTeacher() {
    if (!this.assignTeacherTeacherId || !this.assignTeacherSubjectId) { this.assignTeacherMessage = 'Select both teacher and subject.'; this.assignTeacherError = true; return; }
    this.assignTeacherLoading = true;
    const params = new HttpParams().set('teacherId', this.assignTeacherTeacherId.toString()).set('subjectId', this.assignTeacherSubjectId.toString());
    this.http.post(`${this.baseUrl}/management/assign-teacher`, {}, { params }).subscribe({
      next: () => {
        this.assignTeacherMessage = `Assignment successful!`; this.assignTeacherError = false;
        this.assignTeacherLoading = false; this.loadData(); this.cdr.detectChanges();
      },
      error: () => { this.assignTeacherMessage = 'Failed.'; this.assignTeacherError = true; this.assignTeacherLoading = false; this.cdr.detectChanges(); }
    });
  }

  removeSubjectFromStudent(studentId: number, subjectId: number, subjectName: string) {
    this.openConfirm('Remove Subject', `Remove "${subjectName}" from this student?`, () => {
      this.http.delete(`${this.baseUrl}/management/student/${studentId}/subject/${subjectId}`).subscribe({
        next: () => { this.loadData(); this.cdr.detectChanges(); }, error: () => {}
      });
    });
  }

  removeSubjectFromTeacher(teacherId: number, subjectId: number, subjectName: string) {
    this.openConfirm('Remove Subject', `Remove "${subjectName}" from this teacher?`, () => {
      this.http.delete(`${this.baseUrl}/management/teacher/${teacherId}/subject/${subjectId}`).subscribe({
        next: () => { this.loadData(); this.cdr.detectChanges(); }, error: () => {}
      });
    });
  }

  deleteStudent(id: number, name: string) {
    this.openConfirm('Delete Student', `Delete "${name}"? This cannot be undone.`, () => {
      this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({ next: () => { this.loadData(); }, error: () => {} });
    });
  }

  deleteSubject(id: number, name: string) {
    this.openConfirm('Delete Subject', `Delete "${name}"? This cannot be undone.`, () => {
      this.http.delete(`${this.baseUrl}/subjects/${id}`).subscribe({ next: () => { this.loadData(); }, error: () => {} });
    });
  }

  deleteTeacher(id: number, name: string) {
    this.openConfirm('Delete Teacher', `Delete teacher "${name}"? This cannot be undone.`, () => {
      this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({ next: () => { this.loadData(); }, error: () => {} });
    });
  }

  // ── Routine Operations ──────────────────────────────────────
loadRoutine() {
  this.http.get<any[]>(`${this.baseUrl}/routine`).subscribe({
    next: (data) => { 
      this.routines = data; 
      this.cdr.detectChanges(); 
    },
    error: (err) => { 
      console.error('Error loading routines', err);
    }
  });
}

  getRoutineCell(day: string, slot: string): any {
    if (!this.routines || !this.routines.length) return null;
    return this.routines.find(r => r.dayOfWeek === day && r.timeSlot === slot);
  }

  addRoutine() {
    if (!this.newRoutineDay || !this.newRoutineSlot || !this.newRoutineSubjectId || !this.newRoutineTeacherId) {
      this.routineMessage = 'Please complete all required fields.';
      this.routineError = true;
      return;
    }

    this.routineLoading = true;
    const payload = {
      dayOfWeek: this.newRoutineDay,
      timeSlot: this.newRoutineSlot,
      subjectId: this.newRoutineSubjectId,
      teacherId: this.newRoutineTeacherId,
      roomNo: this.newRoutineRoom.trim()
    };

    this.http.post(`${this.baseUrl}/routine`, payload).subscribe({
      next: () => {
        this.routineMessage = 'Routine slot saved!';
        this.routineError = false;
        this.routineLoading = false;
        this.loadRoutine();
        this.cdr.detectChanges();
        setTimeout(() => { this.closeAllModals(); }, 1500);
      },
      error: (err) => {
        if (err.status === 0) {
          this.routineMessage = 'Server unreachable. Is Spring Boot running?';
        } else {
          this.routineMessage = err.error?.message || err.error || 'Failed to save.';
        }
        this.routineError = true;
        this.routineLoading = false;
        this.cdr.detectChanges();
      }
    });
  }
}
  */
/*
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Router } from '@angular/router';
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-teacher-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './teacher-dashboard.component.html',
  styleUrl: './teacher-dashboard.component.css'
})
export class TeacherDashboardComponent implements OnInit {

  activeTab: 'dashboard'|'students'|'subjects'|'teachers'|'assign'|'stats'|'routine' = 'dashboard';

  students: any[] = [];
  subjects: any[] = [];
  teachers: any[] = [];
  routines: any[] = [];

  routineDays  = ['Saturday','Sunday','Monday','Tuesday','Wednesday','Thursday'];
  routineSlots = ['08:30-10:00','10:00-11:30','11:00-12:30','14:00-15:30'];

  // ── Confirm Modal ──
  showConfirmModal = false;
  confirmTitle     = '';
  confirmMessage   = '';
  confirmAction: (()=>void)|null = null;

  // ── Add Student ──
  showAddStudentModal = false;
  newStudentName=''; newStudentEmail=''; newStudentPassword='';
  newStudentDept=''; newStudentPhone=''; newStudentSemester='';
  addStudentLoading=false; addStudentMessage=''; addStudentError=false;

  // ── Edit Student ──
  showEditStudentModal = false;
  editStudentId: number = 0;
  editStudentName=''; editStudentEmail='';
  editStudentDept=''; editStudentPhone=''; editStudentSemester='';
  editStudentLoading=false; editStudentMessage=''; editStudentError=false;

  // ── Add Subject ──
  showAddSubjectModal=false; newSubjectName='';
  addSubjectLoading=false; addSubjectMessage=''; addSubjectError=false;

  // ── Add Teacher ──
  showAddTeacherModal=false;
  newTeacherName=''; newTeacherEmail=''; newTeacherPassword='';
  addTeacherLoading=false; addTeacherMessage=''; addTeacherError=false;

  // ── Assign Student ──
  showAssignModal=false; assignStudentId:number=0; assignSubjectId:number=0;
  assignLoading=false; assignMessage=''; assignError=false;
  selectedStudentSubjects:any[]=[]; loadingStudentSubjects=false;

  // ── Assign Teacher ──
  showAssignTeacherModal=false;
  assignTeacherTeacherId:number=0; assignTeacherSubjectId:number=0;
  assignTeacherLoading=false; assignTeacherMessage=''; assignTeacherError=false;

  // ── Routine Modal ──
  showRoutineModal=false;
  newRoutineDay=''; newRoutineSlot='';
  newRoutineSubjectId:number=0; newRoutineTeacherId:number=0; newRoutineRoom='';
  routineLoading=false; routineMessage=''; routineError=false;

  private baseUrl = 'http://localhost:8080/api';

  constructor(
    private managementService: ManagementService,
    private http: HttpClient,
    private cdr: ChangeDetectorRef,
    private router: Router
  ) {}

  ngOnInit(): void { this.loadData(); this.loadRoutine(); }

  logout() {
    localStorage.removeItem('userEmail'); localStorage.removeItem('userRole');
    this.router.navigate(['/login']);
  }

  setTab(tab: typeof this.activeTab) {
    this.activeTab = tab; this.closeAllModals(); this.clearMessages(); this.loadData();
    if (tab === 'routine') this.loadRoutine();
  }

  clearMessages() {
    this.addStudentMessage=''; this.editStudentMessage=''; this.addSubjectMessage='';
    this.addTeacherMessage=''; this.assignMessage=''; this.assignTeacherMessage=''; this.routineMessage='';
  }

  closeAllModals() {
    this.showAddStudentModal=false; this.showEditStudentModal=false;
    this.showAddSubjectModal=false; this.showAddTeacherModal=false;
    this.showAssignModal=false; this.showAssignTeacherModal=false;
    this.showConfirmModal=false; this.showRoutineModal=false;
    this.clearMessages();
    this.selectedStudentSubjects=[]; this.assignStudentId=0; this.assignSubjectId=0;
    this.assignTeacherTeacherId=0; this.assignTeacherSubjectId=0;
    this.newRoutineDay=''; this.newRoutineSlot='';
    this.newRoutineSubjectId=0; this.newRoutineTeacherId=0; this.newRoutineRoom='';
  }

  loadData() {
    this.managementService.getStudents().subscribe({ next: d => { this.students=d; this.cdr.detectChanges(); }});
    this.managementService.getSubjects().subscribe({ next: d => { this.subjects=d; this.cdr.detectChanges(); }});
    this.managementService.getTeachers().subscribe({ next: d => { this.teachers=d; this.cdr.detectChanges(); }});
  }

  loadRoutine() {
    this.http.get<any[]>(`${this.baseUrl}/routine`).subscribe({
      next: d => { this.routines=d; this.cdr.detectChanges(); },
      error: err => console.error('Routine load error', err)
    });
  }

  // ── Confirm ──────────────────────────────────────────────
  openConfirm(title:string, message:string, action:()=>void) {
    this.confirmTitle=title; this.confirmMessage=message;
    this.confirmAction=action; this.showConfirmModal=true;
  }
  onConfirmYes() { this.showConfirmModal=false; if(this.confirmAction) this.confirmAction(); this.confirmAction=null; }
  onConfirmNo()  { this.showConfirmModal=false; this.confirmAction=null; }

  // ── Stats ─────────────────────────────────────────────────
  get totalEnrollments(): number { return this.students.reduce((s,e)=>s+(e.subjects?.length||0),0); }
  get avgSubjectsPerStudent(): string { return this.students.length?(this.totalEnrollments/this.students.length).toFixed(1):'0'; }

  get mostPopularSubject(): string {
    if (!this.subjects.length||!this.students.length) return '—';
    const c:Record<number,number>={};
    for(const s of this.students) for(const sub of s.subjects||[]) c[sub.id]=(c[sub.id]||0)+1;
    let maxId=-1,maxCount=0;
    for(const [id,count] of Object.entries(c)) if(+count>maxCount){maxCount=+count;maxId=+id;}
    return this.subjects.find(s=>s.id===maxId)?.name?? '—';
  }
  get topSubjectPct(): number {
    if (!this.students.length) return 0;
    const c:Record<number,number>={};
    for(const s of this.students) for(const sub of s.subjects||[]) c[sub.id]=(c[sub.id]||0)+1;
    const max=Math.max(...Object.values(c),0);
    return max?Math.round((max/this.students.length)*100):0;
  }
  get subjectEnrollmentData(): {name:string;count:number;pct:number}[] {
    if (!this.subjects.length) return [];
    const c:Record<number,number>={};
    for(const s of this.students) for(const sub of s.subjects||[]) c[sub.id]=(c[sub.id]||0)+1;
    const max=Math.max(...Object.values(c),1);
    return this.subjects.map(sub=>({name:sub.name,count:c[sub.id]||0,pct:Math.round(((c[sub.id]||0)/max)*100)})).sort((a,b)=>b.count-a.count);
  }
  get studentLoadData(): {name:string;count:number;pct:number}[] {
    if (!this.students.length) return [];
    const max=Math.max(...this.students.map(s=>s.subjects?.length||0),1);
    return this.students.map(s=>({name:s.name||s.email,count:s.subjects?.length||0,pct:Math.round(((s.subjects?.length||0)/max)*100)})).sort((a,b)=>b.count-a.count);
  }
  get enrollmentDistribution(): {label:string;count:number}[] {
    const d:Record<string,number>={'0 subjects':0,'1–2 subjects':0,'3–4 subjects':0,'5+ subjects':0};
    for(const s of this.students){const n=s.subjects?.length||0;if(n===0)d['0 subjects']++;else if(n<=2)d['1–2 subjects']++;else if(n<=4)d['3–4 subjects']++;else d['5+ subjects']++;}
    return Object.entries(d).map(([label,count])=>({label,count}));
  }

  // Department distribution stat
  get departmentData(): {dept:string;count:number;pct:number}[] {
    const map:Record<string,number>={};
    for(const s of this.students){ const d=s.department||'Unknown'; map[d]=(map[d]||0)+1; }
    const total=this.students.length||1;
    return Object.entries(map).map(([dept,count])=>({dept,count,pct:Math.round(count/total*100)})).sort((a,b)=>b.count-a.count);
  }

  // ── Helpers ──────────────────────────────────────────────
  getInitial(s:any): string { return (s.name||s.email||'?')[0].toUpperCase(); }
  getDisplayName(s:any): string { return s.name||s.email||'Unknown'; }
  getSubjectsForTeacher(tid:number): any[] { return this.subjects.filter(s=>s.teacher?.id===tid); }
  formatStudentId(id:number): string { return 'STU-'+String(id).padStart(5,'0'); }

  getSubjectColor(name:string): string {
    const colors=['#1e3a8a','#064e3b','#4c1d95','#78350f','#831843','#115e59','#3730a3','#0f766e'];
    let hash=0; for(let i=0;i<name.length;i++) hash=name.charCodeAt(i)+((hash<<5)-hash);
    return colors[Math.abs(hash)%colors.length];
  }

  getRoutineCell(day:string,slot:string): any {
    return this.routines.find(r=>r.dayOfWeek===day && r.timeSlot===slot)||null;
  }

  onAssignStudentChange() {
    this.assignSubjectId=0; this.selectedStudentSubjects=[];
    if (!this.assignStudentId) return;
    this.loadingStudentSubjects=true;
    this.http.get<any[]>(`${this.baseUrl}/management/student-details/${this.assignStudentId}`).subscribe({
      next: d=>{ this.selectedStudentSubjects=d; this.loadingStudentSubjects=false; this.cdr.detectChanges(); },
      error: ()=>{ this.loadingStudentSubjects=false; }
    });
  }
  isAlreadyAssigned(subjectId:number): boolean { return this.selectedStudentSubjects.some(s=>s.id===subjectId); }
  get availableSubjectsForAssign(): any[] { return this.subjects.filter(s=>!this.isAlreadyAssigned(s.id)); }

  // ── Open Edit Modal ──────────────────────────────────────
  openEditStudent(s: any) {
    this.editStudentId       = s.id;
    this.editStudentName     = s.name     || '';
    this.editStudentEmail    = s.email    || '';
    this.editStudentDept     = s.department || '';
    this.editStudentPhone    = s.phone    || '';
    this.editStudentSemester = s.semester || '';
    this.editStudentMessage  = '';
    this.editStudentError    = false;
    this.showEditStudentModal = true;
  }

  // ── CRUD ──────────────────────────────────────────────────
  addStudent() {
    if (!this.newStudentEmail||!this.newStudentPassword){this.addStudentMessage='Email and password required.';this.addStudentError=true;return;}
    this.addStudentLoading=true;
    const body:any={email:this.newStudentEmail.trim(),password:this.newStudentPassword,role:'STUDENT'};
    if(this.newStudentName.trim())     body.name=this.newStudentName.trim();
    if(this.newStudentDept.trim())     body.department=this.newStudentDept.trim();
    if(this.newStudentPhone.trim())    body.phone=this.newStudentPhone.trim();
    if(this.newStudentSemester.trim()) body.semester=this.newStudentSemester.trim();
    this.http.post(`${this.baseUrl}/auth/signup`,body).subscribe({
      next:()=>{
        this.addStudentMessage='Student added!';this.addStudentError=false;
        this.newStudentName=this.newStudentEmail=this.newStudentPassword='';
        this.newStudentDept=this.newStudentPhone=this.newStudentSemester='';
        this.addStudentLoading=false;this.loadData();this.cdr.detectChanges();
        setTimeout(()=>{this.closeAllModals();},1500);
      },
      error:err=>{this.addStudentMessage=err.error||'Failed.';this.addStudentError=true;this.addStudentLoading=false;this.cdr.detectChanges();}
    });
  }

  saveEditStudent() {
    this.editStudentLoading=true; this.editStudentMessage='';
    const body:any={};
    if(this.editStudentName.trim())     body.name=this.editStudentName.trim();
    if(this.editStudentDept.trim())     body.department=this.editStudentDept.trim();
    if(this.editStudentPhone.trim())    body.phone=this.editStudentPhone.trim();
    if(this.editStudentSemester.trim()) body.semester=this.editStudentSemester.trim();
    this.http.put(`${this.baseUrl}/management/users/${this.editStudentId}`,body).subscribe({
      next:()=>{
        this.editStudentMessage='Saved!';this.editStudentError=false;
        this.editStudentLoading=false;this.loadData();this.cdr.detectChanges();
        setTimeout(()=>{this.closeAllModals();},1200);
      },
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
    if(!this.newRoutineDay||!this.newRoutineSlot||!this.newRoutineSubjectId||!this.newRoutineTeacherId){
      this.routineMessage='Complete all required fields.';this.routineError=true;return;
    }
    this.routineLoading=true; this.routineMessage='';
    const payload={dayOfWeek:this.newRoutineDay,timeSlot:this.newRoutineSlot,subjectId:this.newRoutineSubjectId,teacherId:this.newRoutineTeacherId,roomNo:this.newRoutineRoom.trim()};
    this.http.post(`${this.baseUrl}/routine`,payload).subscribe({
      next:()=>{
        this.routineMessage='Routine saved!';this.routineError=false;this.routineLoading=false;
        this.loadRoutine();this.cdr.detectChanges();
        setTimeout(()=>{this.closeAllModals();},1200);
      },
      error:err=>{
        this.routineMessage=err.error?.message||err.error||'Failed.';
        this.routineError=true;this.routineLoading=false;this.cdr.detectChanges();
      }
    });
  }

  deleteRoutineCell(day:string,slot:string) {
    const cell=this.getRoutineCell(day,slot);
    if(!cell) return;
    this.openConfirm('Remove Slot',`Remove ${day} ${slot}?`,()=>{
      this.http.delete(`${this.baseUrl}/routine/${cell.id}`).subscribe({next:()=>{this.loadRoutine();this.cdr.detectChanges();}});
    });
  }

  removeSubjectFromStudent(studentId:number,subjectId:number,subjectName:string) {
    this.openConfirm('Remove Subject',`Remove "${subjectName}" from this student?`,()=>{
      this.http.delete(`${this.baseUrl}/management/student/${studentId}/subject/${subjectId}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});
    });
  }
  removeSubjectFromTeacher(teacherId:number,subjectId:number,subjectName:string) {
    this.openConfirm('Remove Subject',`Remove "${subjectName}" from this teacher?`,()=>{
      this.http.delete(`${this.baseUrl}/management/teacher/${teacherId}/subject/${subjectId}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});
    });
  }
  deleteStudent(id:number,name:string) {
    this.openConfirm('Delete Student',`Delete "${name}"? This cannot be undone.`,()=>{
      this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});
    });
  }
  deleteSubject(id:number,name:string) {
    this.openConfirm('Delete Subject',`Delete "${name}"? This cannot be undone.`,()=>{
      this.http.delete(`${this.baseUrl}/subjects/${id}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});
    });
  }
  deleteTeacher(id:number,name:string) {
    this.openConfirm('Delete Teacher',`Delete teacher "${name}"? This cannot be undone.`,()=>{
      this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});
    });
  }
}
  */
 import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Router } from '@angular/router';
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-teacher-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './teacher-dashboard.component.html',
  styleUrl: './teacher-dashboard.component.css'
})
export class TeacherDashboardComponent implements OnInit {

  activeTab: 'dashboard'|'students'|'subjects'|'teachers'|'assign'|'stats'|'routine' = 'dashboard';

  students: any[] = [];
  subjects: any[] = [];
  teachers: any[] = [];
  routines: any[] = [];

  routineDays  = ['Saturday','Sunday','Monday','Tuesday','Wednesday','Thursday'];
  routineSlots = ['08:30-10:00','10:00-11:30','11:00-12:30','14:00-15:30'];

  // ── Confirm Modal ──
  showConfirmModal = false;
  confirmTitle     = '';
  confirmMessage   = '';
  confirmAction: (()=>void)|null = null;

  // ── Add Student ──
  showAddStudentModal = false;
  newStudentName=''; newStudentEmail=''; newStudentPassword='';
  newStudentDept=''; newStudentPhone=''; newStudentSemester='';
  addStudentLoading=false; addStudentMessage=''; addStudentError=false;

  // ── Edit Student ──
  showEditStudentModal = false;
  editStudentId: number = 0;
  editStudentName=''; editStudentEmail='';
  editStudentDept=''; editStudentPhone=''; editStudentSemester='';
  editStudentLoading=false; editStudentMessage=''; editStudentError=false;

  // ── Add Subject ──
  showAddSubjectModal=false; newSubjectName='';
  addSubjectLoading=false; addSubjectMessage=''; addSubjectError=false;

  // ── Add Teacher ──
  showAddTeacherModal=false;
  newTeacherName=''; newTeacherEmail=''; newTeacherPassword=''; newTeacherDept=''; newTeacherPhone='';
  addTeacherLoading=false; addTeacherMessage=''; addTeacherError=false;

  // ── Assign Student ──
  showAssignModal=false; assignStudentId:number=0; assignSubjectId:number=0;
  assignLoading=false; assignMessage=''; assignError=false;
  selectedStudentSubjects:any[]=[]; loadingStudentSubjects=false;

  // ── Assign Teacher ──
  showAssignTeacherModal=false;
  assignTeacherTeacherId:number=0; assignTeacherSubjectId:number=0;
  assignTeacherLoading=false; assignTeacherMessage=''; assignTeacherError=false;

  theme: 'light' | 'dark' = 'dark';

  // ── Routine Modal ──
  showRoutineModal=false;
  newRoutineDay=''; newRoutineSlot='';
  newRoutineSubjectId:number=0; newRoutineTeacherId:number=0; newRoutineRoom='';
  routineLoading=false; routineMessage=''; routineError=false;

  private baseUrl = 'http://localhost:8080/api';

  constructor(
    private managementService: ManagementService,
    private http: HttpClient,
    private cdr: ChangeDetectorRef,
    private router: Router
  ) {}

  ngOnInit(): void { this.loadTheme(); this.loadData(); this.loadRoutine(); }

  loadTheme(): void {
    const stored = localStorage.getItem('dashboardTheme');
    this.theme = stored === 'light' ? 'light' : 'dark';
    this.applyTheme();
  }

  toggleTheme(): void {
    this.theme = this.theme === 'dark' ? 'light' : 'dark';
    this.applyTheme();
  }

  applyTheme(): void {
    document.documentElement.setAttribute('data-theme', this.theme);
    document.body.setAttribute('data-theme', this.theme);
    localStorage.setItem('dashboardTheme', this.theme);
  }

  logout() {
    localStorage.removeItem('userEmail'); localStorage.removeItem('userRole');
    this.router.navigate(['/login']);
  }

  setTab(tab: typeof this.activeTab) {
    this.activeTab = tab; this.closeAllModals(); this.clearMessages(); this.loadData();
    if (tab === 'routine') this.loadRoutine();
  }

  clearMessages() {
    this.addStudentMessage=''; this.editStudentMessage=''; this.addSubjectMessage='';
    this.addTeacherMessage=''; this.assignMessage=''; this.assignTeacherMessage=''; this.routineMessage='';
  }

  closeAllModals() {
    this.showAddStudentModal=false; this.showEditStudentModal=false;
    this.showAddSubjectModal=false; this.showAddTeacherModal=false;
    this.showAssignModal=false; this.showAssignTeacherModal=false;
    this.showConfirmModal=false; this.showRoutineModal=false;
    this.clearMessages();
    this.selectedStudentSubjects=[]; this.assignStudentId=0; this.assignSubjectId=0;
    this.assignTeacherTeacherId=0; this.assignTeacherSubjectId=0;
    this.newRoutineDay=''; this.newRoutineSlot='';
    this.newRoutineSubjectId=0; this.newRoutineTeacherId=0; this.newRoutineRoom='';
  }

  loadData() {
    this.managementService.getStudents().subscribe({ next: d => { this.students=d; this.cdr.detectChanges(); }});
    this.managementService.getSubjects().subscribe({ next: d => { this.subjects=d; this.cdr.detectChanges(); }});
    this.managementService.getTeachers().subscribe({ next: d => { this.teachers=d; this.cdr.detectChanges(); }});
  }

  loadRoutine() {
    this.http.get<any[]>(`${this.baseUrl}/routine`).subscribe({
      next: d => { this.routines=d; this.cdr.detectChanges(); },
      error: err => console.error('Routine load error', err)
    });
  }

  // ── Confirm ──────────────────────────────────────────────
  openConfirm(title:string, message:string, action:()=>void) {
    this.confirmTitle=title; this.confirmMessage=message;
    this.confirmAction=action; this.showConfirmModal=true;
  }
  onConfirmYes() { this.showConfirmModal=false; if(this.confirmAction) this.confirmAction(); this.confirmAction=null; }
  onConfirmNo()  { this.showConfirmModal=false; this.confirmAction=null; }

  // ── Stats ─────────────────────────────────────────────────
  get totalEnrollments(): number { return this.students.reduce((s,e)=>s+(e.subjects?.length||0),0); }
  get avgSubjectsPerStudent(): string { return this.students.length?(this.totalEnrollments/this.students.length).toFixed(1):'0'; }

  get mostPopularSubject(): string {
    if (!this.subjects.length||!this.students.length) return '—';
    const c:Record<number,number>={};
    for(const s of this.students) for(const sub of s.subjects||[]) c[sub.id]=(c[sub.id]||0)+1;
    let maxId=-1,maxCount=0;
    for(const [id,count] of Object.entries(c)) if(+count>maxCount){maxCount=+count;maxId=+id;}
    return this.subjects.find(s=>s.id===maxId)?.name?? '—';
  }
  
  get topSubjectPct(): number {
    if (!this.students.length) return 0;
    const c:Record<number,number>={};
    for(const s of this.students) for(const sub of s.subjects||[]) c[sub.id]=(c[sub.id]||0)+1;
    const max=Math.max(...Object.values(c),0);
    return max?Math.round((max/this.students.length)*100):0;
  }
  
  get subjectEnrollmentData(): {name:string;count:number;pct:number}[] {
    if (!this.subjects.length) return [];
    const c:Record<number,number>={};
    for(const s of this.students) for(const sub of s.subjects||[]) c[sub.id]=(c[sub.id]||0)+1;
    const max=Math.max(...Object.values(c),1);
    return this.subjects.map(sub=>({name:sub.name,count:c[sub.id]||0,pct:Math.round(((c[sub.id]||0)/max)*100)})).sort((a,b)=>b.count-a.count);
  }
  
  get studentLoadData(): {name:string;count:number;pct:number}[] {
    if (!this.students.length) return [];
    const max=Math.max(...this.students.map(s=>s.subjects?.length||0),1);
    return this.students.map(s=>({name:s.name||s.email,count:s.subjects?.length||0,pct:Math.round(((s.subjects?.length||0)/max)*100)})).sort((a,b)=>b.count-a.count);
  }
  
  get enrollmentDistribution(): {label:string;count:number}[] {
    const d:Record<string,number>={'0 subjects':0,'1–2 subjects':0,'3–4 subjects':0,'5+ subjects':0};
    for(const s of this.students){const n=s.subjects?.length||0;if(n===0)d['0 subjects']++;else if(n<=2)d['1–2 subjects']++;else if(n<=4)d['3–4 subjects']++;else d['5+ subjects']++;}
    return Object.entries(d).map(([label,count])=>({label,count}));
  }

  // Department distribution stat
  get departmentData(): {dept:string;count:number;pct:number}[] {
    const map:Record<string,number>={};
    for(const s of this.students){ const d=s.department||'Unknown'; map[d]=(map[d]||0)+1; }
    const total=this.students.length||1;
    return Object.entries(map).map(([dept,count])=>({dept,count,pct:Math.round(count/total*100)})).sort((a,b)=>b.count-a.count);
  }

  get subjectsWithTeacher(): number {
    return this.subjects.filter(s => s.teacher).length;
  }

  get subjectsNoTeacher(): any[] {
    return this.subjects.filter(s => !s.teacher);
  }

  getTeacherWorkload(): {name: string; count: number; pct: number}[] {
    if (!this.teachers.length) return [];
    const max = Math.max(...this.teachers.map(t => this.getSubjectsForTeacher(t.id).length), 1);
    return this.teachers.map(t => ({
      name: t.name || t.email,
      count: this.getSubjectsForTeacher(t.id).length,
      pct: Math.round(this.getSubjectsForTeacher(t.id).length / max * 100)
    })).sort((a,b) => b.count - a.count);
  }

  // ── UI Visual Helpers ──────────────────────────────────────
  getPieColor(i: number): string {
    return ['#E05C5C','#D4A853','#7C9EF0','#5CBF8A','#B48EF0','#F0C97A'][i % 6];
  }

  getPieSegments(): {path: string; color: string}[] {
    const dist = this.enrollmentDistribution;
    const total = dist.reduce((s, d) => s + d.count, 0);
    if (!total) return [];
    
    const colors = ['#E05C5C','#D4A853','#7C9EF0','#5CBF8A'];
    const cx = 60, cy = 60, r = 46;
    let startAngle = -Math.PI / 2;
    
    return dist.map((d, i) => {
      const pct = d.count / total;
      if (pct === 0) return null;
      
      const angle = pct * 2 * Math.PI;
      const x1 = cx + r * Math.cos(startAngle);
      const y1 = cy + r * Math.sin(startAngle);
      const x2 = cx + r * Math.cos(startAngle + angle);
      const y2 = cy + r * Math.sin(startAngle + angle);
      const large = angle > Math.PI ? 1 : 0;
      
      const path = pct >= 1
        ? `M ${cx-r} ${cy} a ${r} ${r} 0 1 1 ${r*2} 0 a ${r} ${r} 0 1 1 -${r*2} 0`
        : `M ${cx} ${cy} L ${x1} ${y1} A ${r} ${r} 0 ${large} 1 ${x2} ${y2} Z`;
        
      startAngle += angle;
      return { path, color: colors[i % colors.length] };
    }).filter((s): s is {path:string;color:string} => s !== null);
  }

  getInitial(s:any): string { return (s.name||s.email||'?')[0].toUpperCase(); }
  getDisplayName(s:any): string { return s.name||s.email||'Unknown'; }
  getSubjectsForTeacher(tid:number): any[] { return this.subjects.filter(s=>s.teacher?.id===tid); }
  formatStudentId(id:number): string { return 'STU-'+String(id).padStart(5,'0'); }

  getSubjectColor(name:string): string {
    const colors=['#1e3a8a','#064e3b','#4c1d95','#78350f','#831843','#115e59','#3730a3','#0f766e'];
    let hash=0; for(let i=0;i<name.length;i++) hash=name.charCodeAt(i)+((hash<<5)-hash);
    return colors[Math.abs(hash)%colors.length];
  }

  getRoutineCell(day:string,slot:string): any {
    return this.routines.find(r=>r.dayOfWeek===day && r.timeSlot===slot)||null;
  }

  // ── Assignment & Forms ────────────────────────────────────
  onAssignStudentChange() {
    this.assignSubjectId=0; this.selectedStudentSubjects=[];
    if (!this.assignStudentId) return;
    this.loadingStudentSubjects=true;
    this.http.get<any[]>(`${this.baseUrl}/management/student-details/${this.assignStudentId}`).subscribe({
      next: d=>{ this.selectedStudentSubjects=d; this.loadingStudentSubjects=false; this.cdr.detectChanges(); },
      error: ()=>{ this.loadingStudentSubjects=false; }
    });
  }
  
  isAlreadyAssigned(subjectId:number): boolean { return this.selectedStudentSubjects.some(s=>s.id===subjectId); }
  get availableSubjectsForAssign(): any[] { return this.subjects.filter(s=>!this.isAlreadyAssigned(s.id)); }

  // ── Open Edit Modal ──────────────────────────────────────
  openEditStudent(s: any) {
    this.editStudentId       = s.id;
    this.editStudentName     = s.name     || '';
    this.editStudentEmail    = s.email    || '';
    this.editStudentDept     = s.department || '';
    this.editStudentPhone    = s.phone    || '';
    this.editStudentSemester = s.semester || '';
    this.editStudentMessage  = '';
    this.editStudentError    = false;
    this.showEditStudentModal = true;
  }

  // ── CRUD ──────────────────────────────────────────────────
  addStudent() {
    if (!this.newStudentEmail||!this.newStudentPassword){this.addStudentMessage='Email and password required.';this.addStudentError=true;return;}
    this.addStudentLoading=true;
    const body:any={email:this.newStudentEmail.trim(),password:this.newStudentPassword,role:'STUDENT'};
    if(this.newStudentName.trim())     body.name=this.newStudentName.trim();
    if(this.newStudentDept.trim())     body.department=this.newStudentDept.trim();
    if(this.newStudentPhone.trim())    body.phone=this.newStudentPhone.trim();
    if(this.newStudentSemester.trim()) body.semester=this.newStudentSemester.trim();
    this.http.post(`${this.baseUrl}/auth/signup`,body).subscribe({
      next:()=>{
        this.addStudentMessage='Student added!';this.addStudentError=false;
        this.newStudentName=this.newStudentEmail=this.newStudentPassword='';
        this.newStudentDept=this.newStudentPhone=this.newStudentSemester='';
        this.addStudentLoading=false;this.loadData();this.cdr.detectChanges();
        setTimeout(()=>{this.closeAllModals();},1500);
      },
      error:err=>{this.addStudentMessage=err.error||'Failed.';this.addStudentError=true;this.addStudentLoading=false;this.cdr.detectChanges();}
    });
  }

  saveEditStudent() {
    this.editStudentLoading=true; this.editStudentMessage='';
    const body:any={};
    if(this.editStudentName.trim())     body.name=this.editStudentName.trim();
    if(this.editStudentDept.trim())     body.department=this.editStudentDept.trim();
    if(this.editStudentPhone.trim())    body.phone=this.editStudentPhone.trim();
    if(this.editStudentSemester.trim()) body.semester=this.editStudentSemester.trim();
    this.http.put(`${this.baseUrl}/management/users/${this.editStudentId}`,body).subscribe({
      next:()=>{
        this.editStudentMessage='Saved!';this.editStudentError=false;
        this.editStudentLoading=false;this.loadData();this.cdr.detectChanges();
        setTimeout(()=>{this.closeAllModals();},1200);
      },
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
    if(!this.newRoutineDay||!this.newRoutineSlot||!this.newRoutineSubjectId||!this.newRoutineTeacherId){
      this.routineMessage='Complete all required fields.';this.routineError=true;return;
    }
    this.routineLoading=true; this.routineMessage='';
    const payload={dayOfWeek:this.newRoutineDay,timeSlot:this.newRoutineSlot,subjectId:this.newRoutineSubjectId,teacherId:this.newRoutineTeacherId,roomNo:this.newRoutineRoom.trim()};
    this.http.post(`${this.baseUrl}/routine`,payload).subscribe({
      next:()=>{
        this.routineMessage='Routine saved!';this.routineError=false;this.routineLoading=false;
        this.loadRoutine();this.cdr.detectChanges();
        setTimeout(()=>{this.closeAllModals();},1200);
      },
      error:err=>{
        this.routineMessage=err.error?.message||err.error||'Failed.';
        this.routineError=true;this.routineLoading=false;this.cdr.detectChanges();
      }
    });
  }

  deleteRoutineCell(day:string,slot:string) {
    const cell=this.getRoutineCell(day,slot);
    if(!cell) return;
    this.openConfirm('Remove Slot',`Remove ${day} ${slot}?`,()=>{
      this.http.delete(`${this.baseUrl}/routine/${cell.id}`).subscribe({next:()=>{this.loadRoutine();this.cdr.detectChanges();}});
    });
  }

  removeSubjectFromStudent(studentId:number,subjectId:number,subjectName:string) {
    this.openConfirm('Remove Subject',`Remove "${subjectName}" from this student?`,()=>{
      this.http.delete(`${this.baseUrl}/management/student/${studentId}/subject/${subjectId}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});
    });
  }
  removeSubjectFromTeacher(teacherId:number,subjectId:number,subjectName:string) {
    this.openConfirm('Remove Subject',`Remove "${subjectName}" from this teacher?`,()=>{
      this.http.delete(`${this.baseUrl}/management/teacher/${teacherId}/subject/${subjectId}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});
    });
  }
  deleteStudent(id:number,name:string) {
    this.openConfirm('Delete Student',`Delete "${name}"? This cannot be undone.`,()=>{
      this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});
    });
  }
  deleteSubject(id:number,name:string) {
    this.openConfirm('Delete Subject',`Delete "${name}"? This cannot be undone.`,()=>{
      this.http.delete(`${this.baseUrl}/subjects/${id}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});
    });
  }
  deleteTeacher(id:number,name:string) {
    this.openConfirm('Delete Teacher',`Delete teacher "${name}"? This cannot be undone.`,()=>{
      this.http.delete(`${this.baseUrl}/management/users/${id}`).subscribe({next:()=>{this.loadData();this.cdr.detectChanges();}});
    });
  }
}
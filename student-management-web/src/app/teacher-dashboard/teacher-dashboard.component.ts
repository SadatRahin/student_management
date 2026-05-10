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
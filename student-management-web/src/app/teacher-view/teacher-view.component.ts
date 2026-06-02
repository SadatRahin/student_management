/*
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common'; // 1. Add this import
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-teacher-view',
  standalone: true,                // 2. Ensure this is here
  imports: [CommonModule],         // 3. Add CommonModule here
  templateUrl: './teacher-view.component.html',
  styleUrls: ['./teacher-view.component.css']
})
export class TeacherViewComponent implements OnInit {
  mySubjects: any[] = [];
  isLoading = true;

  constructor(private managementService: ManagementService) {}

  ngOnInit(): void {
    const email = localStorage.getItem('userEmail');
    
    if (email) {
      this.managementService.getMyTeachingSubjects(email).subscribe({
        next: (data) => {
          this.mySubjects = data;
          this.isLoading = false;
        },
        error: (err) => {
          console.error("Fetch error:", err);
          this.isLoading = false;
        }
      });
    } else {
      this.isLoading = false;
    }
  }
}
*/

/*
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-teacher-view',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './teacher-view.component.html',
  styleUrl: './teacher-view.component.css'
})
export class TeacherViewComponent implements OnInit {

  mySubjects: any[] = [];
  isLoading = true;
  errorMessage = '';
  teacherName  = '';
  teacherEmail = '';
  

  constructor(
    private managementService: ManagementService,
    private cdr: ChangeDetectorRef,
    private router: Router
  ) {}

  ngOnInit(): void {
    const email = localStorage.getItem('userEmail');
    const name  = localStorage.getItem('userName');
    if (!email) { this.router.navigate(['/login']); return; }
    this.teacherEmail = email;
    this.teacherName  = name || '';
    this.loadSubjects();
  }

  getInitial(): string {
    return (this.teacherName || this.teacherEmail || '?')[0].toUpperCase();
  }

  getDisplayName(): string {
    return this.teacherName || this.teacherEmail;
  }

  loadSubjects(): void {
    this.isLoading = true;
    this.errorMessage = '';
    this.managementService.getMyTeachingSubjects(this.teacherEmail).subscribe({
      next: (data) => {
        this.mySubjects = data;
        this.isLoading  = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error('Failed to load subjects:', err);
        this.errorMessage = 'Could not load your subjects. Please try again.';
        this.isLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  // Total students across all subjects (deduplicated by id)
  get totalUniqueStudents(): number {
    const ids = new Set<number>();
    for (const sub of this.mySubjects) {
      for (const stu of sub.students || []) ids.add(stu.id);
    }
    return ids.size;
  }

  getStudentInitial(s: any): string {
    return (s.name || s.email || '?')[0].toUpperCase();
  }

  getStudentName(s: any): string {
    return s.name || s.email || 'Unknown';
  }

  logout(): void {
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userRole');
    localStorage.removeItem('userName');
    this.router.navigate(['/login']);
  }
}
  */

import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-teacher-view',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './teacher-view.component.html',
  styleUrl: './teacher-view.component.css'
})
export class TeacherViewComponent implements OnInit {

  activeTab: 'dashboard' | 'my-subjects' | 'students' | 'routine' | 'profile' = 'dashboard';

  // ── User info ──
  teacherName  = '';
  teacherEmail = '';
  teacherDept  = '';
  teacherPhone = '';

  // ── Data ──
  mySubjects: any[] = [];
  routines:   any[] = [];
  isLoading   = true;
  errorMessage = '';
  theme: 'light' | 'dark' = 'dark';

  routineDays  = ['Saturday','Sunday','Monday','Tuesday','Wednesday','Thursday'];
  routineSlots = ['08:30-10:00','10:00-11:30','11:00-12:30','14:00-15:30'];

  private baseUrl = 'http://localhost:8080/api';

  constructor(
    private managementService: ManagementService,
    private http: HttpClient,
    private cdr: ChangeDetectorRef,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.loadTheme();
    const email = localStorage.getItem('userEmail');
    if (!email) { this.router.navigate(['/login']); return; }
    this.teacherEmail = email;
    this.teacherName  = localStorage.getItem('userName')     || '';
    this.teacherDept  = localStorage.getItem('userDept')     || '';
    this.teacherPhone = localStorage.getItem('userPhone')    || '';
    this.loadAll();
  }

  loadAll(): void {
    this.isLoading = true;
    this.errorMessage = '';

    this.managementService.getMyTeachingSubjects(this.teacherEmail).subscribe({
      next: data => {
        this.mySubjects = data;
        this.isLoading  = false;
        this.cdr.detectChanges();
      },
      error: () => {
        this.errorMessage = 'Could not load your subjects.';
        this.isLoading = false;
        this.cdr.detectChanges();
      }
    });

    this.http.get<any[]>(`${this.baseUrl}/routine`).subscribe({
      next: d => { this.routines = d; this.cdr.detectChanges(); },
      error: () => {}
    });
  }

  setTab(tab: typeof this.activeTab): void {
    this.activeTab = tab;
    this.loadAll();
  }

  logout(): void {
    localStorage.clear();
    this.router.navigate(['/login']);
  }

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

  // ── Helpers ──
  getInitial(s?: any): string {
    if (s) return (s.name || s.email || '?')[0].toUpperCase();
    return (this.teacherName || this.teacherEmail || '?')[0].toUpperCase();
  }

  getSubjectColor(name: string): string {
    const colors = ['#1e3a8a','#064e3b','#4c1d95','#78350f','#831843','#115e59','#3730a3','#0f766e','#7c2d12','#1e40af'];
    let hash = 0;
    for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash);
    return colors[Math.abs(hash) % colors.length];
  }

  getRoutineCell(day: string, slot: string): any {
    return this.routines.find(r => r.dayOfWeek === day && r.timeSlot === slot) || null;
  }

  // ── Stats ──
  get totalUniqueStudents(): number {
    const ids = new Set<number>();
    for (const sub of this.mySubjects)
      for (const stu of sub.students || []) ids.add(stu.id);
    return ids.size;
  }

  get allUniqueStudents(): any[] {
    const map = new Map<number, any>();
    for (const sub of this.mySubjects)
      for (const stu of sub.students || []) map.set(stu.id, stu);
    return Array.from(map.values());
  }

  getStudentsForSubject(subjectId: number): any[] {
    const sub = this.mySubjects.find(s => s.id === subjectId);
    return sub?.students || [];
  }
}
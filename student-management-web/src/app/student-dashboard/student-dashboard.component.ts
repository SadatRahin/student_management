/*
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-student-dashboard',
  standalone: true,
  imports: [CommonModule],
  // Use 'template' instead of 'templateUrl' for now to force the update
  template: `
    <h2>Student Dashboard</h2>
    <h3>My Enrolled Subjects:</h3>
    <ul>
      <li *ngFor="let subject of mySubjects">
        {{ subject.name }}
      </li>
    </ul>
    <p *ngIf="mySubjects.length === 0">No subjects assigned yet.</p>
  `,
  styleUrl: './student-dashboard.component.css'
})
export class StudentDashboardComponent implements OnInit {
  mySubjects: any[] = [];

  constructor(private managementService: ManagementService) {}

  ngOnInit(): void {
    const email = localStorage.getItem('userEmail'); // Retrieved during login
    if (email) {
      this.managementService.getMySubjects(email).subscribe(data => {
        this.mySubjects = data;
      });
    }
  }
}
*/
/*
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-student-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div style="padding: 20px;">
      <h2>Student Dashboard</h2>
      <h3>My Enrolled Subjects:</h3>
      <ul *ngIf="mySubjects.length > 0">
        <li *ngFor="let subject of mySubjects">
          <strong>{{ subject.name }}</strong>
        </li>
      </ul>
      <p *ngIf="mySubjects.length === 0">No subjects assigned yet.</p>
    </div>
  `,
  styleUrl: './student-dashboard.component.css'
})
export class StudentDashboardComponent implements OnInit {
  mySubjects: any[] = [];

  constructor(private managementService: ManagementService) {}

  ngOnInit(): void {
    const email = localStorage.getItem('userEmail'); 
    
    if (email) {
      console.log("Attempting to fetch subjects for:", email);
      this.managementService.getMySubjects(email).subscribe({
        next: (data) => {
          this.mySubjects = data;
          console.log("Subjects received:", data);
        },
        error: (err) => {
          console.error("Error fetching subjects:", err);
        }
      });
    } else {
      console.warn("No userEmail found in localStorage. Please log in again.");
    }
  }
}
  */

/*
import { Component, OnInit, ChangeDetectorRef } from '@angular/core'; // 1. Add ChangeDetectorRef
import { CommonModule } from '@angular/common';
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-student-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div style="padding: 20px;">
      <h2>Student Dashboard</h2>
      <h3>My Enrolled Subjects:</h3>
      
      <ul *ngIf="mySubjects && mySubjects.length > 0">
        <li *ngFor="let subject of mySubjects">
          <strong>{{ subject.name }}</strong> (ID: {{ subject.id }})
        </li>
      </ul>

      <p *ngIf="!mySubjects || mySubjects.length === 0">No subjects assigned yet.</p>
    </div>
  `,
  styleUrl: './student-dashboard.component.css'
})
export class StudentDashboardComponent implements OnInit {
  mySubjects: any[] = [];

  constructor(
    private managementService: ManagementService,
    private cdr: ChangeDetectorRef // 2. Inject it
  ) {}

  ngOnInit(): void {
    const email = localStorage.getItem('userEmail'); 
    
    if (email) {
      this.managementService.getMySubjects(email).subscribe({
        next: (data) => {
          console.log("Data arriving in component:", data);
          this.mySubjects = data;
          this.cdr.detectChanges(); // 3. Force the UI to refresh
        },
        error: (err) => {
          console.error("Error fetching subjects:", err);
        }
      });
    }
  }
}
  */



/*
 import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-student-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './student-dashboard.component.html', // Pointing to external file
  styleUrl: './student-dashboard.component.css'
})
export class StudentDashboardComponent implements OnInit {
  mySubjects: any[] = [];

  constructor(
    private managementService: ManagementService,
    private cdr: ChangeDetectorRef 
  ) {}

  ngOnInit(): void {
    const email = localStorage.getItem('userEmail'); 
    if (email) {
      this.managementService.getMySubjects(email).subscribe({
        next: (data) => {
          this.mySubjects = data;
          this.cdr.detectChanges(); 
        },
        error: (err) => console.error("Error:", err)
      });
    }
  }
}
  */
/*
import { Component, OnInit, OnDestroy, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { ManagementService } from '../services/management.service';

@Component({
  selector: 'app-student-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './student-dashboard.component.html',
  styleUrl: './student-dashboard.component.css'
})
export class StudentDashboardComponent implements OnInit, OnDestroy {
  // Matches your HTML variable names exactly
  subjects: any[] = [];
  isLoading = true;
  errorMessage = '';
  userEmail = '';

  private destroy$ = new Subject<void>();

  constructor(
    private managementService: ManagementService,
    private router: Router,
    private cdr: ChangeDetectorRef 
  ) {}

  ngOnInit(): void {
    const email = localStorage.getItem('userEmail');
    if (!email) {
      this.router.navigate(['/login']);
      return;
    }

    this.userEmail = email;
    this.loadSubjects();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  // Returns the first letter of the email for the sidebar avatar
  getInitial(): string {
    return this.userEmail ? this.userEmail[0].toUpperCase() : '?';
  }

  loadSubjects(): void {
    this.isLoading = true;
    this.errorMessage = '';

    this.managementService.getMySubjects(this.userEmail)
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (data: any) => { 
          console.log('Backend Data Received:', data);
          
          // Fix: Extracting the 'subjects' array from the student object
          if (data && data.subjects) {
            this.subjects = data.subjects;
          } else if (Array.isArray(data)) {
            this.subjects = data;
          } else {
            this.subjects = [];
          }
          
          this.isLoading = false;
          this.cdr.detectChanges(); // Force UI refresh
        },
        error: (err) => {
          console.error('Fetch Error:', err);
          this.errorMessage = 'Could not load your courses. Please check your connection.';
          this.isLoading = false;
          this.cdr.detectChanges();
        }
      });
  }

  logout(): void {
    localStorage.clear();
    this.router.navigate(['/login']);
  }
}
*/
/*
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';


@Component({
  selector: 'app-student-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './student-dashboard.component.html',
  styleUrl: './student-dashboard.component.css'
})
export class StudentDashboardComponent implements OnInit {

  activeTab: 'dashboard' | 'profile' | 'my-courses' | 'all-courses' = 'dashboard';

  // User info
  userEmail = '';
  userName  = '';
  userDept  = '';
  userSemester = '';
  userPhone = '';
  userId: number = 0;
  

  // Data
  mySubjects:  any[] = [];
  allSubjects: any[] = [];
  loading = true;
  error   = '';
  

  private baseUrl = 'http://localhost:8080/api';

  constructor(
    private http: HttpClient,
    private cdr: ChangeDetectorRef,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.userEmail    = localStorage.getItem('userEmail') || '';
    this.userName     = localStorage.getItem('userName')  || '';
    this.userDept     = localStorage.getItem('userDept')  || '';
    this.userSemester = localStorage.getItem('userSemester') || '';
    this.userPhone    = localStorage.getItem('userPhone') || '';
    this.load();
  }

  load(): void {
    this.loading = true;
    this.error = '';

    // Load my subjects
    this.http.get<any[]>(`${this.baseUrl}/management/my-subjects?email=${this.userEmail}`).subscribe({
      next: data => {
        this.mySubjects = Array.isArray(data) ? data : [];
        this.loading = false;
        this.cdr.detectChanges();
      },
      error: () => {
        this.error = 'Could not load your courses.';
        this.loading = false;
        this.cdr.detectChanges();
      }
    });

    // Load all subjects
    this.http.get<any[]>(`${this.baseUrl}/management/subjects`).subscribe({
      next: data => { this.allSubjects = data; this.cdr.detectChanges(); },
      error: () => {}
    });
  }

  setTab(tab: typeof this.activeTab): void {
    this.activeTab = tab;
    this.load();
  }

  logout(): void {
    localStorage.clear();
    this.router.navigate(['/login']);
  }

  getInitial(s: any): string { return (s?.name || s?.email || '?')[0].toUpperCase(); }

  isEnrolled(subjectId: number): boolean {
    return this.mySubjects.some(s => s.id === subjectId);
  }

  // Stats helpers
  get totalCourses(): number { return this.mySubjects.length; }

  get coursesWithTeacher(): number {
    return this.mySubjects.filter(s => s.teacher).length;
  }

  get subjectsByDept(): {dept: string; count: number}[] {
    // Group all available subjects (we don't have dept on subjects, so return subjects)
    return [];
  }

  getSubjectInitial(name: string): string {
    return name ? name[0].toUpperCase() : '?';
  }

  getSubjectColor(name: string): string {
    const colors = ['#1e3a8a','#064e3b','#4c1d95','#78350f','#831843','#115e59','#3730a3','#0f766e','#7c2d12','#1e40af'];
    let hash = 0;
    for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash);
    return colors[Math.abs(hash) % colors.length];
  }
}
*/
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';

@Component({
  selector: 'app-student-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './student-dashboard.component.html',
  styleUrl: './student-dashboard.component.css'
})
export class StudentDashboardComponent implements OnInit {

  activeTab: 'dashboard' | 'my-courses' | 'all-courses' | 'routine' | 'profile' = 'dashboard';

  // ── User info (from localStorage) ──
  userEmail    = '';
  userName     = '';
  userDept     = '';
  userSemester = '';
  userPhone    = '';

  // ── Data ──
  mySubjects:  any[] = [];
  allSubjects: any[] = [];
  routines:    any[] = [];
  loading = true;
  error   = '';
  theme: 'light' | 'dark' = 'dark';

  routineDays  = ['Saturday','Sunday','Monday','Tuesday','Wednesday','Thursday'];
  routineSlots = ['08:30-10:00','10:00-11:30','11:00-12:30','14:00-15:30'];

  private baseUrl = 'http://localhost:8080/api';

  constructor(
    private http: HttpClient,
    private cdr: ChangeDetectorRef,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.loadTheme();
    this.userEmail    = localStorage.getItem('userEmail')    || '';
    this.userName     = localStorage.getItem('userName')     || '';
    this.userDept     = localStorage.getItem('userDept')  || '';
    this.userSemester = localStorage.getItem('userSemester') || '';
    this.userPhone    = localStorage.getItem('userPhone')    || '';
    this.loadAll();
  }

  loadAll(): void {
    this.loading = true;
    this.error = '';

    this.http.get<any[]>(`${this.baseUrl}/management/my-subjects?email=${this.userEmail}`).subscribe({
      next: d => { this.mySubjects = Array.isArray(d) ? d : []; this.loading = false; this.cdr.detectChanges(); },
      error: () => { this.error = 'Could not load your courses.'; this.loading = false; this.cdr.detectChanges(); }
    });

    this.http.get<any[]>(`${this.baseUrl}/management/subjects`).subscribe({
      next: d => { this.allSubjects = d; this.cdr.detectChanges(); },
      error: () => {}
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
  getInitial(s: any): string { return (s?.name || s?.email || '?')[0].toUpperCase(); }
  getSubjectInitial(name: string): string { return name ? name[0].toUpperCase() : '?'; }

  isEnrolled(subjectId: number): boolean {
    return this.mySubjects.some(s => s.id === subjectId);
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
  get totalCourses(): number { return this.mySubjects.length; }
  get coursesWithTeacher(): number { return this.mySubjects.filter(s => s.teacher).length; }
}
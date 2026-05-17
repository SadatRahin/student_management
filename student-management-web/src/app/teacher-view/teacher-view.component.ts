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
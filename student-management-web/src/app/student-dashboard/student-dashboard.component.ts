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
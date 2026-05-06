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
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { StudentService } from './services/student.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './app.html',
  styleUrls: ['./app.css']
})
export class AppComponent implements OnInit {
  students: any[] = [];
  subjects: any[] = [];
  subjectCounts: { [key: number]: number } = {};
  studentSubjectCounts: { [key: number]: number } = {};

  // For viewing specific details
  selectedStudentName: string = '';
  subjectsOfSelectedStudent: any[] = [];
  selectedSubjectName: string = '';
  studentsOfSelectedSubject: any[] = [];

  newStudent = { name: '', email: '' };
  newSubject = { name: '' };
  selectedStudentId: number = 0;
  selectedSubjectId: number = 0;

  constructor(private studentService: StudentService, private cdr: ChangeDetectorRef) {}

  ngOnInit() {
    this.refreshData();
  }

  refreshData() {
    this.studentService.getAllStudents().subscribe(data => {
      this.students = data;
      this.students.forEach(s => {
        this.studentService.getSubjectsForStudent(s.id).subscribe(list => {
          this.studentSubjectCounts[s.id] = list.length;
          this.cdr.detectChanges();
        });
      });
    });

    this.studentService.getAllSubjects().subscribe(data => {
      this.subjects = data;
      this.subjects.forEach(sub => {
        this.studentService.getSubjectCount(sub.id).subscribe(count => {
          this.subjectCounts[sub.id] = count;
          this.cdr.detectChanges();
        });
      });
    });
  }

  viewStudentDetails(student: any) {
    this.selectedStudentName = student.name;
    this.studentService.getSubjectsForStudent(student.id).subscribe(data => {
      this.subjectsOfSelectedStudent = data;
      this.cdr.detectChanges();
    });
  }

  viewSubjectDetails(subject: any) {
    this.selectedSubjectName = subject.name;
    this.studentService.getStudentsForSubject(subject.id).subscribe(data => {
      this.studentsOfSelectedSubject = data;
      this.cdr.detectChanges();
    });
  }

  addStudent() {
    this.studentService.createStudent(this.newStudent).subscribe(() => {
      this.newStudent = { name: '', email: '' };
      this.refreshData();
    });
  }

  addSubject() {
    this.studentService.createSubject(this.newSubject).subscribe(() => {
      this.newSubject = { name: '' };
      this.refreshData();
    });
  }

  assign() {
    if (this.selectedStudentId && this.selectedSubjectId) {
      this.studentService.assignSubject(this.selectedStudentId, this.selectedSubjectId).subscribe(() => {
        this.refreshData();
      });
    }
  }
}
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class StudentService {
  private baseUrl = 'http://localhost:8080/api';

  constructor(private http: HttpClient) { }

  // Students
  getAllStudents(): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/students`);
  }
  createStudent(student: any): Observable<any> {
    return this.http.post(`${this.baseUrl}/students`, student);
  }

  // Subjects
  getAllSubjects(): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/subjects`);
  }
  createSubject(subject: any): Observable<any> {
    return this.http.post(`${this.baseUrl}/subjects`, subject);
  }

  // Relationships
  assignSubject(studentId: number, subjectId: number): Observable<any> {
    return this.http.post(`${this.baseUrl}/student-subjects/assign?studentId=${studentId}&subjectId=${subjectId}`, {});
  }

  getSubjectCount(subjectId: number): Observable<number> {
    return this.http.get<number>(`${this.baseUrl}/student-subjects/subject/${subjectId}/count`);
  }

  getSubjectsForStudent(studentId: number): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/student-subjects/student/${studentId}`);
  }

  getStudentsForSubject(subjectId: number): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/student-subjects/subject-details/${subjectId}`);
  }
}
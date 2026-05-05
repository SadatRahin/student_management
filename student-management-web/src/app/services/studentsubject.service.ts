import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class StudentSubjectService {
  private apiUrl = 'http://localhost:8080/api/student-subjects';

  constructor(private http: HttpClient) { }

  assignSubject(studentId: number, subjectId: number): Observable<any> {
    return this.http.post(`${this.apiUrl}/assign?studentId=${studentId}&subjectId=${subjectId}`, {});
  }

  getSubjectsForStudent(studentId: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/student/${studentId}`);
  }

  getStudentCountForSubject(subjectId: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/subject/${subjectId}/count`);
  }

  getAllStudentSubjects(): Observable<any> {
    return this.http.get(this.apiUrl);
  }

  removeStudentSubject(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`);
  }
}
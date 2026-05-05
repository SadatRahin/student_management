import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SubjectService {
  private apiUrl = 'http://localhost:8080/api/subjects';

  constructor(private http: HttpClient) { }

  getAllSubjects(): Observable<any> {
    return this.http.get(this.apiUrl);
  }

  getSubjectById(id: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/${id}`);
  }

  createSubject(subject: any): Observable<any> {
    return this.http.post(this.apiUrl, subject);
  }

  updateSubject(id: number, subject: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/${id}`, subject);
  }

  deleteSubject(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`);
  }
}
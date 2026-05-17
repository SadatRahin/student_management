/*
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http'; // Added HttpParams
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ManagementService {
  private baseUrl = 'http://localhost:8080/api/management';

  constructor(private http: HttpClient) {}

  getStudents(): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/students`);
  }

  getSubjects(): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/subjects`);
  }

  assignSubject(studentId: number, subjectId: number): Observable<any> {
    const params = new HttpParams()
      .set('studentId', studentId.toString())
      .set('subjectId', subjectId.toString());
    return this.http.post(`${this.baseUrl}/assign`, {}, { params });
  }

  getMySubjects(email: string): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/my-subjects`, {
      params: new HttpParams().set('email', email)
    });
  }
}

*/

import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class ManagementService {
  private baseUrl = 'http://localhost:8080/api/management';

  constructor(private http: HttpClient) {}

  getStudents(): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/students`);
  }

  getSubjects(): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/subjects`);
  }

  getTeachers(): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/teachers`);
  }

  assignSubject(studentId: number, subjectId: number): Observable<any> {
    const params = new HttpParams()
      .set('studentId', studentId.toString())
      .set('subjectId', subjectId.toString());
    return this.http.post(`${this.baseUrl}/assign`, {}, { params });
  }

  getMySubjects(email: string): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/my-subjects`, {
      params: new HttpParams().set('email', email)
    });
  }

  getMyTeachingSubjects(email: string): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/my-teaching-subjects`, {
      params: new HttpParams().set('email', email)
    });
  }
}
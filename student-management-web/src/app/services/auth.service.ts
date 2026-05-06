/*
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private apiUrl = 'http://localhost:8080/api/auth';

  constructor(private http: HttpClient, private router: Router) {}

  // Handles the "Single Sign-Up" logic
  signup(user: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/signup`, user);
  }

  // Handles Login and "Automatic Recognition"
  login(credentials: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/login`, credentials).pipe(
      tap((res: any) => {
        // Save token and role to local storage
        localStorage.setItem('token', res.token);
        localStorage.setItem('userRole', res.role);
        this.redirectByRole(res.role);
      })
    );
  }

  redirectByRole(role: string) {
    if (role === 'ADMIN') this.router.navigate(['/admin-dashboard']);
    else if (role === 'TEACHER') this.router.navigate(['/teacher-dashboard']);
    else this.router.navigate(['/student-dashboard']);
  }

  getRole() {
    return localStorage.getItem('userRole');
  }

  logout() {
    localStorage.clear();
    this.router.navigate(['/login']);
  }
}
  */
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private baseUrl = 'http://localhost:8080/api/auth';

  constructor(private http: HttpClient) {}

  // Existing login method
  login(credentials: any): Observable<any> {
    return this.http.post(`${this.baseUrl}/login`, credentials);
  }

  // MISSING METHOD 1: Signup
  signup(user: any): Observable<any> {
    return this.http.post(`${this.baseUrl}/signup`, user);
  }

  // MISSING METHOD 2: getRole (Used by your route guards)
  getRole(): string | null {
    return localStorage.getItem('userRole');
  }

  logout(): void {
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userRole');
  }
}
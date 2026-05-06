/*
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent {
  credentials = { email: '', password: '' };

  constructor(private authService: AuthService) {}

  onLogin() {
    this.authService.login(this.credentials).subscribe({
      next: (res) => {
        console.log('Logged in successfully', res);
        // The AuthService logic we wrote earlier will automatically 
        // redirect them to the Student or Teacher dashboard now.
      },
      error: (err) => {
        alert('Invalid credentials. Please check your email and password.');
      }
    });
  }
}
  */

import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router'; 
import { AuthService } from '../../services/auth.service'; // Double check this path!

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent {
  credentials = { email: '', password: '' };

  // ADD 'private' BEFORE THE NAMES BELOW
  constructor(
    private authService: AuthService, 
    private router: Router
  ) {}

  onLogin() {
    if (!this.credentials.email || !this.credentials.password) {
      alert("Please enter both email and password");
      return;
    }

    this.authService.login(this.credentials).subscribe({
      next: (response: any) => {
        // Save email so Student Dashboard can use it
        localStorage.setItem('userEmail', this.credentials.email);
        localStorage.setItem('userRole', response.role);
        
        console.log("Logged in successfully:", response);

        if (response.role === 'TEACHER') {
          this.router.navigate(['/teacher-dashboard']);
        } else {
          this.router.navigate(['/student-dashboard']);
        }
      },
      error: (err) => {
        console.error("Login failed", err);
        alert("Invalid credentials.");
      }
    });
  }
}
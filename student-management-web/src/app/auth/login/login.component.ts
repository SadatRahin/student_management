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


/*
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { Router } from '@angular/router'; 
import { AuthService } from '../../services/auth.service'; // Double check this path!

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
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
  */


/*
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router'; // Added RouterModule
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule], // Include RouterModule for links
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent {
  // UI State Properties
  email = '';
  password = '';
  showPwd = false;
  isLoading = false;
  errorMessage = '';
  currentYear = new Date().getFullYear();

  constructor(
    private authService: AuthService, 
    private router: Router
  ) {}

  // Helper to toggle password visibility
  togglePassword() {
    this.showPwd = !this.showPwd;
  }

  login() {
    // 1. Basic Validation
    if (!this.email || !this.password) {
      this.errorMessage = 'Email and password are required.';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    // 2. Prepare the object to match what AuthService expects
    const loginData = { 
      email: this.email, 
      password: this.password 
    };

    // 3. Call the service (passing the object, not two strings)
    this.authService.login(loginData).subscribe({
      next: (response: any) => {
        // Save session data
        localStorage.setItem('userEmail', this.email);
        localStorage.setItem('userRole', response.role);
        
        console.log("Login successful:", response);
        this.isLoading = false;

        // Redirect based on role
        if (response.role === 'TEACHER') {
          this.router.navigate(['/teacher-dashboard']);
        } else {
          this.router.navigate(['/student-dashboard']);
        }
      },
      error: (err) => {
        console.error("Login Error:", err);
        this.errorMessage = 'Invalid email or password. Please try again.';
        this.isLoading = false;
      }
    });
  }
}
*/

import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent {
  email    = '';
  password = '';
  showPwd  = false;
  isLoading    = false;
  errorMessage = '';
  currentYear  = new Date().getFullYear();

  constructor(private authService: AuthService, private router: Router) {}

  login() {
    if (!this.email || !this.password) {
      this.errorMessage = 'Email and password are required.';
      return;
    }
    this.isLoading = true;
    this.errorMessage = '';

    const loginData = { email: this.email, password: this.password };

    this.authService.login(loginData).subscribe({
      next: (response: any) => {
        localStorage.setItem('userEmail', this.email);
        localStorage.setItem('userRole',  response.role);
        if (response.name) localStorage.setItem('userName', response.name);
        this.isLoading = false;

        if      (response.role === 'ADMIN')   this.router.navigate(['/admin-dashboard']);
        else if (response.role === 'TEACHER') this.router.navigate(['/teacher-dashboard']);
        else                                  this.router.navigate(['/student-dashboard']);
      },
      error: () => {
        this.errorMessage = 'Invalid email or password.';
        this.isLoading = false;
      }
    });
  }
}
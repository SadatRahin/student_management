/*
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-signup',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './signup.component.html',
  styleUrl: './signup.component.css'
})
export class SignupComponent {
  user = {
    email: '',
    password: '',
    role: 'STUDENT'
  };

  constructor(private authService: AuthService) {}

  onSignup() {
    this.authService.signup(this.user).subscribe({
      next: (res) => {
        alert('Registration successful! Redirecting to login...');
        // The routerLink in HTML handles navigation back to login
      },
      error: (err) => {
        alert('Signup failed. Email might already be in use.');
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
  selector: 'app-signup',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './signup.component.html',
  styleUrl: './signup.component.css'
})
export class SignupComponent {
  user = {
    email: '',
    password: '',
    role: 'STUDENT' // Default role
  };

  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  onSignup() {
    if (!this.user.email || !this.user.password) {
      alert("Please fill in all fields.");
      return;
    }

    this.authService.signup(this.user).subscribe({
      next: (res: any) => {
        console.log('Signup successful', res);
        alert('Registration successful! Please login.');
        this.router.navigate(['/login']);
      },
      error: (err: any) => {
        console.error('Signup failed', err);
        alert('Registration failed. Email might already be in use.');
      }
    });
  }
}
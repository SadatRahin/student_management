/*

import { Routes } from '@angular/router';
import { SignupComponent } from './auth/signup/signup.component';
import { LoginComponent } from './auth/login/login.component';
import { RoleGuard } from './guards/role-guard'; 

export const routes: Routes = [
  { path: 'signup', component: SignupComponent },
  { path: 'login', component: LoginComponent },
  { 
    path: 'teacher-dashboard', 
    loadComponent: () => import('./teacher/teacher.component').then(m => m.TeacherComponent),
    canActivate: [RoleGuard], 
    data: { expectedRole: 'TEACHER' } 
  },
  { 
    path: 'student-dashboard', 
    loadComponent: () => import('./student/student.component').then(m => m.StudentComponent),
    canActivate: [RoleGuard], 
    data: { expectedRole: 'STUDENT' } 
  },
  { path: '', redirectTo: '/login', pathMatch: 'full' }
];
*/


/*
import { Routes } from '@angular/router';
import { LoginComponent } from './auth/login/login.component';
import { SignupComponent } from './auth/signup/signup.component';
import { TeacherDashboardComponent } from './teacher-dashboard/teacher-dashboard.component';
import { StudentDashboardComponent } from './student-dashboard/student-dashboard.component';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: 'signup', component: SignupComponent },
  { path: 'teacher-dashboard', component: TeacherDashboardComponent },
  { path: 'student-dashboard', component: StudentDashboardComponent },
  { path: '', redirectTo: '/login', pathMatch: 'full' }
];
*/



import { Routes } from '@angular/router';
import { LoginComponent } from './auth/login/login.component';
import { TeacherDashboardComponent } from './teacher-dashboard/teacher-dashboard.component';
import { TeacherViewComponent } from './teacher-view/teacher-view.component';
import { StudentDashboardComponent } from './student-dashboard/student-dashboard.component';

export const routes: Routes = [
  { path: 'login',             component: LoginComponent },
  { path: 'admin-dashboard',   component: TeacherDashboardComponent },   // ADMIN role
  { path: 'teacher-dashboard', component: TeacherViewComponent },         // TEACHER role
  { path: 'student-dashboard', component: StudentDashboardComponent },    // STUDENT role
  { path: '',                  redirectTo: '/login', pathMatch: 'full' },
  { path: '**',                redirectTo: '/login' },
];
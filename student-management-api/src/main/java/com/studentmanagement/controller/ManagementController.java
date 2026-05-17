/* 
package com.studentmanagement.controller;

import com.studentmanagement.entity.User;
import com.studentmanagement.entity.Subject;
import com.studentmanagement.repository.UserRepository;
import com.studentmanagement.repository.SubjectRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/management")
@CrossOrigin(origins = "http://localhost:4200")
public class ManagementController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    @GetMapping("/students")
    public ResponseEntity<List<User>> getAllStudents() {
        return ResponseEntity.ok(userRepository.findAll().stream()
                .filter(u -> "STUDENT".equalsIgnoreCase(u.getRole()))
                .collect(Collectors.toList()));
    }

    @GetMapping("/subjects")
    public ResponseEntity<List<Subject>> getAllSubjects() {
        return ResponseEntity.ok(subjectRepository.findAll());
    }

    @PostMapping("/assign")
    @Transactional
    public ResponseEntity<?> assignSubject(@RequestParam Long studentId, @RequestParam Long subjectId) {
        User student = userRepository.findById(studentId).orElse(null);
        Subject subject = subjectRepository.findById(subjectId).orElse(null);

        if (student != null && subject != null) {
            if (!student.getSubjects().contains(subject)) {
                student.getSubjects().add(subject);
                userRepository.save(student);
            }
            return ResponseEntity.ok(Collections.singletonMap("message", "Success"));
        }
        return ResponseEntity.badRequest().body("User or Subject not found");
    }

    @GetMapping("/my-subjects")
    public ResponseEntity<?> getMySubjects(@RequestParam String email) {
        return userRepository.findByEmail(email)
                .map(user -> ResponseEntity.ok(user.getSubjects()))
                .orElse(ResponseEntity.badRequest().build());
    }
}
*/

/*
package com.studentmanagement.controller;

import com.studentmanagement.entity.User;
import com.studentmanagement.entity.Subject;
import com.studentmanagement.repository.UserRepository;
import com.studentmanagement.repository.SubjectRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/management")
@CrossOrigin(origins = "http://localhost:4200")
public class ManagementController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    @GetMapping("/students")
    public ResponseEntity<List<User>> getAllStudents() {
        return ResponseEntity.ok(userRepository.findAll().stream()
                .filter(u -> "STUDENT".equalsIgnoreCase(u.getRole()))
                .collect(Collectors.toList()));
    }

    @GetMapping("/subjects")
    public ResponseEntity<List<Subject>> getAllSubjects() {
        return ResponseEntity.ok(subjectRepository.findAll());
    }

    @PostMapping("/assign")
    @Transactional
    public ResponseEntity<?> assignSubject(@RequestParam Long studentId, @RequestParam Long subjectId) {
        User student = userRepository.findById(studentId).orElse(null);
        Subject subject = subjectRepository.findById(subjectId).orElse(null);

        if (student != null && subject != null) {
            if (!student.getSubjects().contains(subject)) {
                student.getSubjects().add(subject);
                userRepository.save(student);
            }
            return ResponseEntity.ok(Collections.singletonMap("message", "Success"));
        }
        return ResponseEntity.badRequest().body("User or Subject not found");
    }

    @GetMapping("/my-subjects")
    public ResponseEntity<?> getMySubjects(@RequestParam("email") String email) {
        // Debug line: Check your console to see if the email is arriving correctly
        System.out.println("DEBUG: Fetching subjects for student: " + email);
        
return userRepository.findByEmail(email)
            .<ResponseEntity<Object>>map(user -> ResponseEntity.ok(user.getSubjects()))
            .orElse(ResponseEntity.status(404).body("Student record not found for email: " + email));
}
}
*/


/*
package com.studentmanagement.controller;

import com.studentmanagement.entity.User;
import com.studentmanagement.entity.Subject;
import com.studentmanagement.repository.UserRepository;
import com.studentmanagement.repository.SubjectRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/management")
@CrossOrigin(origins = "*")
public class ManagementController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    @GetMapping("/students")
    public ResponseEntity<List<User>> getAllStudents() {
        return ResponseEntity.ok(userRepository.findAll().stream()
                .filter(u -> "STUDENT".equalsIgnoreCase(u.getRole()))
                .collect(Collectors.toList()));
    }

    @GetMapping("/subjects")
    public ResponseEntity<List<Subject>> getAllSubjects() {
        return ResponseEntity.ok(subjectRepository.findAll());
    }

    @PostMapping("/assign")
    @Transactional
    public ResponseEntity<?> assignSubject(@RequestParam Long studentId, @RequestParam Long subjectId) {
        User student = userRepository.findById(studentId).orElse(null);
        Subject subject = subjectRepository.findById(subjectId).orElse(null);

        if (student != null && subject != null) {
            if (!student.getSubjects().contains(subject)) {
                student.getSubjects().add(subject);
                userRepository.save(student);
            }
            return ResponseEntity.ok(Collections.singletonMap("message", "Success"));
        }
        return ResponseEntity.badRequest().body("User or Subject not found");
    }

    /* 
    // Simplified version to fix the "Red Line"
    @GetMapping("/my-subjects")
    public ResponseEntity<?> getMySubjects(@RequestParam("email") String email) {
        System.out.println("DEBUG: Fetching subjects for student: " + email);
        
        Optional<User> user = userRepository.findByEmail(email);
        if (user.isPresent()) {
            return ResponseEntity.ok(user.get().getSubjects());
        } else {
            return ResponseEntity.status(404).body("Student not found");
        }
    }
    */
/*
@GetMapping("/my-subjects")
    public ResponseEntity<?> getMySubjects(@RequestParam("email") String email) {
        System.out.println("DEBUG: Fetching subjects for student: " + email);
        
        return userRepository.findByEmail(email)
                .map(user -> ResponseEntity.ok((Object) user.getSubjects()))
                .orElse(ResponseEntity.status(404).body("Student record not found for email: " + email));
    }
}
*/




/* 

package com.studentmanagement.controller;

import com.studentmanagement.entity.User;
import com.studentmanagement.entity.Subject;
import com.studentmanagement.repository.UserRepository;
import com.studentmanagement.repository.SubjectRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/management")
@CrossOrigin(origins = "*")
public class ManagementController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    @GetMapping("/students")
    public ResponseEntity<List<User>> getAllStudents() {
        return ResponseEntity.ok(userRepository.findAll().stream()
                .filter(u -> "STUDENT".equalsIgnoreCase(u.getRole()))
                .collect(Collectors.toList()));
    }

    @GetMapping("/subjects")
    public ResponseEntity<List<Subject>> getAllSubjects() {
        return ResponseEntity.ok(subjectRepository.findAll());
    }

    @PostMapping("/assign")
    @Transactional
    public ResponseEntity<?> assignSubject(@RequestParam Long studentId, @RequestParam Long subjectId) {
        User student = userRepository.findById(studentId).orElse(null);
        Subject subject = subjectRepository.findById(subjectId).orElse(null);

        if (student != null && subject != null) {
            if (!student.getSubjects().contains(subject)) {
                student.getSubjects().add(subject);
                userRepository.save(student);
            }
            return ResponseEntity.ok(Collections.singletonMap("message", "Success"));
        }
        return ResponseEntity.badRequest().body("User or Subject not found");
    }

    @GetMapping("/my-subjects")
    public ResponseEntity<?> getMySubjects(@RequestParam("email") String email) {
        Optional<User> user = userRepository.findByEmail(email);
        if (user.isPresent()) {
            return ResponseEntity.ok(user.get().getSubjects());
        }
        return ResponseEntity.status(404).body("Student record not found");
    }

    // --- NEW ENDPOINTS FOR FLUTTER DASHBOARD ---

    @GetMapping("/student-details/{id}")
    public ResponseEntity<?> getStudentSubjects(@PathVariable Long id) {
        Optional<User> user = userRepository.findById(id);
        if (user.isPresent()) {
            return ResponseEntity.ok(user.get().getSubjects());
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/subject-details/{id}")
    public ResponseEntity<?> getSubjectStudents(@PathVariable Long id) {
        Optional<Subject> subject = subjectRepository.findById(id);
        if (subject.isPresent()) {
            return ResponseEntity.ok(subject.get().getStudents());
        }
        return ResponseEntity.notFound().build();
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
    if (userRepository.existsById(id)) {
        userRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
    return ResponseEntity.notFound().build();
    }
}
*/


package com.studentmanagement.controller;

import com.studentmanagement.entity.User;
import com.studentmanagement.entity.Subject;
import com.studentmanagement.repository.UserRepository;
import com.studentmanagement.repository.SubjectRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/management")
@CrossOrigin(origins = "*")
public class ManagementController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    // ── GET ALL STUDENTS ────────────────────────────────────
    @GetMapping("/students")
    public ResponseEntity<List<User>> getAllStudents() {
        return ResponseEntity.ok(userRepository.findAll().stream()
                .filter(u -> "STUDENT".equalsIgnoreCase(u.getRole()))
                .collect(Collectors.toList()));
    }

    // ── GET ALL TEACHERS ────────────────────────────────────
    @GetMapping("/teachers")
    public ResponseEntity<List<User>> getAllTeachers() {
        return ResponseEntity.ok(userRepository.findAll().stream()
                .filter(u -> "TEACHER".equalsIgnoreCase(u.getRole()))
                .collect(Collectors.toList()));
    }

    // ── GET ALL SUBJECTS ────────────────────────────────────
    @GetMapping("/subjects")
    public ResponseEntity<List<Subject>> getAllSubjects() {
        return ResponseEntity.ok(subjectRepository.findAll());
    }

    // ── ASSIGN SUBJECT TO STUDENT ───────────────────────────
    @PostMapping("/assign")
    @Transactional
    public ResponseEntity<?> assignSubject(@RequestParam Long studentId, @RequestParam Long subjectId) {
        User student = userRepository.findById(studentId).orElse(null);
        Subject subject = subjectRepository.findById(subjectId).orElse(null);
        if (student != null && subject != null) {
            if (!student.getSubjects().contains(subject)) {
                student.getSubjects().add(subject);
                userRepository.save(student);
            }
            return ResponseEntity.ok(Collections.singletonMap("message", "Success"));
        }
        return ResponseEntity.badRequest().body("User or Subject not found");
    }

    // ── REMOVE SUBJECT FROM STUDENT ─────────────────────────
    @DeleteMapping("/student/{studentId}/subject/{subjectId}")
    @Transactional
    public ResponseEntity<?> removeSubjectFromStudent(
            @PathVariable Long studentId,
            @PathVariable Long subjectId) {
        User student = userRepository.findById(studentId).orElse(null);
        if (student == null) return ResponseEntity.notFound().build();
        student.getSubjects().removeIf(s -> s.getId().equals(subjectId));
        userRepository.save(student);
        return ResponseEntity.ok(Collections.singletonMap("message", "Subject removed"));
    }

    // ── ASSIGN TEACHER TO SUBJECT ───────────────────────────
    @PostMapping("/assign-teacher")
    @Transactional
    public ResponseEntity<?> assignTeacher(@RequestParam Long teacherId, @RequestParam Long subjectId) {
        User teacher = userRepository.findById(teacherId).orElse(null);
        Subject subject = subjectRepository.findById(subjectId).orElse(null);
        if (teacher != null && subject != null) {
            subject.setTeacher(teacher);
            subjectRepository.save(subject);
            return ResponseEntity.ok(Collections.singletonMap("message", "Teacher assigned"));
        }
        return ResponseEntity.badRequest().body("Teacher or Subject not found");
    }

    // ── DELETE USER (student or teacher) ────────────────────
    @DeleteMapping("/users/{id}")
    @Transactional
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        if (userRepository.existsById(id)) {
            userRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    // ── GET STUDENT'S SUBJECTS ──────────────────────────────
    @GetMapping("/my-subjects")
    public ResponseEntity<?> getMySubjects(@RequestParam("email") String email) {
        Optional<User> user = userRepository.findByEmail(email);
        if (user.isPresent()) {
            return ResponseEntity.ok(user.get().getSubjects());
        }
        return ResponseEntity.status(404).body("Student record not found");
    }

    // ── GET TEACHER'S SUBJECTS (with enrolled students) ─────
    @GetMapping("/my-teaching-subjects")
    public ResponseEntity<?> getMyTeachingSubjects(@RequestParam("email") String email) {
        Optional<User> teacher = userRepository.findByEmail(email);
        if (teacher.isPresent()) {
            List<Subject> subjects = subjectRepository.findByTeacher(teacher.get());
            return ResponseEntity.ok(subjects);
        }
        return ResponseEntity.status(404).body("Teacher not found");
    }

    // ── GET STUDENT DETAILS (subjects) ──────────────────────
    @GetMapping("/student-details/{id}")
    public ResponseEntity<?> getStudentSubjects(@PathVariable Long id) {
        Optional<User> user = userRepository.findById(id);
        if (user.isPresent()) {
            return ResponseEntity.ok(user.get().getSubjects());
        }
        return ResponseEntity.notFound().build();
    }

    // ── GET SUBJECT DETAILS (students) ──────────────────────
    @GetMapping("/subject-details/{id}")
    public ResponseEntity<?> getSubjectStudents(@PathVariable Long id) {
        Optional<Subject> subject = subjectRepository.findById(id);
        if (subject.isPresent()) {
            return ResponseEntity.ok(subject.get().getStudents());
        }
        return ResponseEntity.notFound().build();
    }
}
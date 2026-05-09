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
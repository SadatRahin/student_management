package com.studentmanagement.controller;

import com.studentmanagement.entity.Meeting;
import com.studentmanagement.entity.Subject;
import com.studentmanagement.entity.User;
import com.studentmanagement.repository.MeetingRepository;
import com.studentmanagement.repository.SubjectRepository;
import com.studentmanagement.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/meetings")
@CrossOrigin(origins = "*")
public class MeetingController {

    @Autowired
    private MeetingRepository meetingRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    @Autowired
    private UserRepository userRepository;

    // ── Create a meeting ──
    @PostMapping
    public ResponseEntity<?> createMeeting(@RequestBody Map<String, Object> body) {
        try {
            String title = body.get("title").toString();
            Long subjectId = Long.valueOf(body.get("subjectId").toString());
            String creatorEmail = body.get("creatorEmail").toString();

            Subject subject = subjectRepository.findById(subjectId)
                .orElseThrow(() -> new RuntimeException("Subject not found"));
            User creator = userRepository.findByEmail(creatorEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

            // Generate unique room code
            String roomCode = "bup-" + subject.getName().toLowerCase().replaceAll("[^a-z0-9]", "-")
                + "-" + System.currentTimeMillis() % 100000;

            Meeting meeting = new Meeting();
            meeting.setTitle(title);
            meeting.setRoomCode(roomCode);
            meeting.setSubject(subject);
            meeting.setCreatedBy(creator);
            meeting.setStatus("ACTIVE");
            meeting.setCreatedAt(LocalDateTime.now());

            meetingRepository.save(meeting);
            return ResponseEntity.ok(meeting);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // ── Get all meetings (for admin) ──
    @GetMapping
    public ResponseEntity<?> getAll() {
        return ResponseEntity.ok(meetingRepository.findAllByOrderByCreatedAtDesc());
    }

    // ── Get active meetings ──
    @GetMapping("/active")
    public ResponseEntity<?> getActive() {
        return ResponseEntity.ok(meetingRepository.findByStatus("ACTIVE"));
    }

    // ── Get meetings by teacher email ──
    @GetMapping("/teacher")
    public ResponseEntity<?> getByTeacher(@RequestParam String email) {
        return ResponseEntity.ok(meetingRepository.findByCreatedByEmail(email));
    }

    // ── Get active meetings for a list of subject IDs (for students) ──
    @GetMapping("/student")
    public ResponseEntity<?> getForStudent(@RequestParam String subjectIds) {
        try {
            String[] parts = subjectIds.split(",");
            List<Long> ids = new ArrayList<>();
            for (String p : parts) {
                if (!p.trim().isEmpty()) ids.add(Long.valueOf(p.trim()));
            }
            if (ids.isEmpty()) return ResponseEntity.ok(Collections.emptyList());
            return ResponseEntity.ok(meetingRepository.findBySubjectIdInAndStatus(ids, "ACTIVE"));
        } catch (Exception e) {
            return ResponseEntity.ok(Collections.emptyList());
        }
    }

    // ── End a meeting ──
    @PutMapping("/{id}/end")
    public ResponseEntity<?> endMeeting(@PathVariable Long id) {
        try {
            Meeting meeting = meetingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Meeting not found"));
            meeting.setStatus("ENDED");
            meetingRepository.save(meeting);
            return ResponseEntity.ok(meeting);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // ── Delete a meeting ──
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteMeeting(@PathVariable Long id) {
        meetingRepository.deleteById(id);
        return ResponseEntity.ok("Deleted");
    }
}
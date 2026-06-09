package com.studentmanagement.controller;

import com.studentmanagement.entity.Notice;
import com.studentmanagement.entity.User;
import com.studentmanagement.repository.NoticeRepository;
import com.studentmanagement.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/notices")
@CrossOrigin(origins = "*")
public class NoticeController {

    @Autowired private NoticeRepository noticeRepo;
    @Autowired private UserRepository userRepo;

    // ── Get active notices (for students/teachers) ──
    @GetMapping
    public ResponseEntity<?> getActive() {
        return ResponseEntity.ok(noticeRepo.findByActiveTrueOrderByCreatedAtDesc());
    }

    // ── Get all notices including inactive (for admin) ──
    @GetMapping("/all")
    public ResponseEntity<?> getAll() {
        return ResponseEntity.ok(noticeRepo.findAllByOrderByCreatedAtDesc());
    }

    // ── Create a notice (admin only) ──
    @PostMapping
    public ResponseEntity<?> create(@RequestBody Map<String, Object> body) {
        try {
            String title    = body.get("title").toString();
            String content  = body.get("content").toString();
            String priority = body.getOrDefault("priority", "NORMAL").toString().toUpperCase();
            String email    = body.getOrDefault("creatorEmail", "admin@gmail.com").toString();

            Notice n = new Notice();
            n.setTitle(title);
            n.setContent(content);
            n.setPriority(priority);
            n.setCreatedAt(LocalDateTime.now());
            n.setActive(true);

            userRepo.findByEmail(email).ifPresent(n::setCreatedBy);

            noticeRepo.save(n);
            return ResponseEntity.ok(n);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // ── Update a notice ──
    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        try {
            Notice n = noticeRepo.findById(id).orElseThrow(() -> new RuntimeException("Not found"));
            if (body.containsKey("title"))    n.setTitle(body.get("title").toString());
            if (body.containsKey("content"))  n.setContent(body.get("content").toString());
            if (body.containsKey("priority")) n.setPriority(body.get("priority").toString().toUpperCase());
            if (body.containsKey("active"))   n.setActive(Boolean.parseBoolean(body.get("active").toString()));
            noticeRepo.save(n);
            return ResponseEntity.ok(n);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // ── Delete a notice ──
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        noticeRepo.deleteById(id);
        return ResponseEntity.ok("Deleted");
    }
}
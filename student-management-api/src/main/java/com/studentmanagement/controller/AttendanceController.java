package com.studentmanagement.controller;

import com.studentmanagement.entity.Attendance;
import com.studentmanagement.entity.Subject;
import com.studentmanagement.entity.User;
import com.studentmanagement.repository.AttendanceRepository;
import com.studentmanagement.repository.SubjectRepository;
import com.studentmanagement.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/attendance")
@CrossOrigin(origins = "*")
public class AttendanceController {

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    @Autowired
    private UserRepository userRepository;

    // ── Mark single attendance ──
    @PostMapping("/mark")
    public ResponseEntity<?> markAttendance(@RequestBody Map<String, Object> body) {
        try {
            Long studentId = Long.valueOf(body.get("studentId").toString());
            Long subjectId = Long.valueOf(body.get("subjectId").toString());
            String dateStr = body.get("date").toString();
            String status  = body.get("status").toString(); // PRESENT, ABSENT, LATE
            Long markedById = body.get("markedById") != null
                ? Long.valueOf(body.get("markedById").toString()) : null;

            LocalDate date = LocalDate.parse(dateStr);

            User student = userRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found"));
            Subject subject = subjectRepository.findById(subjectId)
                .orElseThrow(() -> new RuntimeException("Subject not found"));

            // Check if already exists — update it
            Optional<Attendance> existing = attendanceRepository
                .findByStudentIdAndSubjectIdAndDate(studentId, subjectId, date);

            Attendance att;
            if (existing.isPresent()) {
                att = existing.get();
                att.setStatus(status.toUpperCase());
            } else {
                att = new Attendance();
                att.setStudent(student);
                att.setSubject(subject);
                att.setDate(date);
                att.setStatus(status.toUpperCase());
            }

            if (markedById != null) {
                userRepository.findById(markedById).ifPresent(att::setMarkedBy);
            }

            attendanceRepository.save(att);
            return ResponseEntity.ok(att);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // ── Mark bulk attendance (for a whole class at once) ──
    @PostMapping("/mark-bulk")
    public ResponseEntity<?> markBulk(@RequestBody Map<String, Object> body) {
        try {
            Long subjectId = Long.valueOf(body.get("subjectId").toString());
            String dateStr = body.get("date").toString();
            Long markedById = body.get("markedById") != null
                ? Long.valueOf(body.get("markedById").toString()) : null;
            LocalDate date = LocalDate.parse(dateStr);

            Subject subject = subjectRepository.findById(subjectId)
                .orElseThrow(() -> new RuntimeException("Subject not found"));

            User markedBy = null;
            if (markedById != null) {
                markedBy = userRepository.findById(markedById).orElse(null);
            }

            // records: [{studentId: 1, status: "PRESENT"}, ...]
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> records = (List<Map<String, Object>>) body.get("records");

            List<Attendance> saved = new ArrayList<>();
            for (Map<String, Object> rec : records) {
                Long studentId = Long.valueOf(rec.get("studentId").toString());
                String status  = rec.get("status").toString().toUpperCase();

                User student = userRepository.findById(studentId).orElse(null);
                if (student == null) continue;

                Optional<Attendance> existing = attendanceRepository
                    .findByStudentIdAndSubjectIdAndDate(studentId, subjectId, date);

                Attendance att;
                if (existing.isPresent()) {
                    att = existing.get();
                    att.setStatus(status);
                } else {
                    att = new Attendance();
                    att.setStudent(student);
                    att.setSubject(subject);
                    att.setDate(date);
                    att.setStatus(status);
                }
                att.setMarkedBy(markedBy);
                saved.add(attendanceRepository.save(att));
            }

            return ResponseEntity.ok(saved);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // ── Get attendance by subject + date ──
    @GetMapping("/subject/{subjectId}")
    public ResponseEntity<?> getBySubjectAndDate(
            @PathVariable Long subjectId,
            @RequestParam(required = false) String date) {
        if (date != null && !date.isEmpty()) {
            LocalDate d = LocalDate.parse(date);
            return ResponseEntity.ok(attendanceRepository.findBySubjectIdAndDate(subjectId, d));
        }
        return ResponseEntity.ok(attendanceRepository.findBySubjectId(subjectId));
    }

    // ── Get attendance by student ──
    @GetMapping("/student/{studentId}")
    public ResponseEntity<?> getByStudent(@PathVariable Long studentId) {
        return ResponseEntity.ok(attendanceRepository.findByStudentId(studentId));
    }

    // ── Get attendance for a student in a specific subject ──
    @GetMapping("/subject/{subjectId}/student/{studentId}")
    public ResponseEntity<?> getBySubjectAndStudent(
            @PathVariable Long subjectId, @PathVariable Long studentId) {
        return ResponseEntity.ok(
            attendanceRepository.findBySubjectIdAndStudentId(subjectId, studentId));
    }

    // ── Update single attendance record ──
    @PutMapping("/{id}")
    public ResponseEntity<?> updateAttendance(
            @PathVariable Long id, @RequestBody Map<String, Object> body) {
        try {
            Attendance att = attendanceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Record not found"));
            if (body.containsKey("status")) {
                att.setStatus(body.get("status").toString().toUpperCase());
            }
            attendanceRepository.save(att);
            return ResponseEntity.ok(att);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // ── Delete attendance record ──
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteAttendance(@PathVariable Long id) {
        attendanceRepository.deleteById(id);
        return ResponseEntity.ok("Deleted");
    }

    // ── Summary for a subject: per-student stats ──
    @GetMapping("/summary/subject/{subjectId}")
    public ResponseEntity<?> subjectSummary(@PathVariable Long subjectId) {
        List<Attendance> all = attendanceRepository.findBySubjectId(subjectId);

        // Count distinct dates = total classes
        long totalClasses = all.stream().map(Attendance::getDate).distinct().count();

        // Group by student
        Map<Long, List<Attendance>> byStudent = all.stream()
            .collect(Collectors.groupingBy(a -> a.getStudent().getId()));

        List<Map<String, Object>> summary = new ArrayList<>();
        for (Map.Entry<Long, List<Attendance>> entry : byStudent.entrySet()) {
            List<Attendance> recs = entry.getValue();
            User stu = recs.get(0).getStudent();

            long present = recs.stream().filter(a -> "PRESENT".equals(a.getStatus())).count();
            long absent  = recs.stream().filter(a -> "ABSENT".equals(a.getStatus())).count();
            long late    = recs.stream().filter(a -> "LATE".equals(a.getStatus())).count();
            double pct   = totalClasses > 0 ? Math.round(present * 100.0 / totalClasses) : 0;

            Map<String, Object> row = new LinkedHashMap<>();
            row.put("studentId", stu.getId());
            row.put("studentName", stu.getName() != null ? stu.getName() : stu.getEmail());
            row.put("studentEmail", stu.getEmail());
            row.put("totalClasses", totalClasses);
            row.put("present", present);
            row.put("absent", absent);
            row.put("late", late);
            row.put("percentage", pct);
            summary.add(row);
        }

        return ResponseEntity.ok(summary);
    }

    // ── Summary for a student across all subjects ──
    @GetMapping("/summary/student/{studentId}")
    public ResponseEntity<?> studentSummary(@PathVariable Long studentId) {
        List<Attendance> all = attendanceRepository.findByStudentId(studentId);

        Map<Long, List<Attendance>> bySubject = all.stream()
            .collect(Collectors.groupingBy(a -> a.getSubject().getId()));

        List<Map<String, Object>> summary = new ArrayList<>();
        for (Map.Entry<Long, List<Attendance>> entry : bySubject.entrySet()) {
            List<Attendance> recs = entry.getValue();
            Subject sub = recs.get(0).getSubject();

            // Total classes for this subject (across all students)
            long totalForSubject = attendanceRepository.findBySubjectId(sub.getId())
                .stream().map(Attendance::getDate).distinct().count();

            long present = recs.stream().filter(a -> "PRESENT".equals(a.getStatus())).count();
            long absent  = recs.stream().filter(a -> "ABSENT".equals(a.getStatus())).count();
            long late    = recs.stream().filter(a -> "LATE".equals(a.getStatus())).count();
            double pct   = totalForSubject > 0 ? Math.round(present * 100.0 / totalForSubject) : 0;

            Map<String, Object> row = new LinkedHashMap<>();
            row.put("subjectId", sub.getId());
            row.put("subjectName", sub.getName());
            row.put("totalClasses", totalForSubject);
            row.put("present", present);
            row.put("absent", absent);
            row.put("late", late);
            row.put("percentage", pct);
            summary.add(row);
        }

        return ResponseEntity.ok(summary);
    }
}
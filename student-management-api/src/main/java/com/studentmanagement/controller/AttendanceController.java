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

    // ── Time-based analysis: daily trends, day-of-week, subject rates, at-risk ──
    @GetMapping("/stats/time-analysis")
    public ResponseEntity<?> timeAnalysis() {
        List<Attendance> all = attendanceRepository.findAll();
        Map<String, Object> result = new LinkedHashMap<>();

        // 1. Daily attendance counts (last 30 days)
        Map<LocalDate, List<Attendance>> byDate = all.stream()
            .collect(Collectors.groupingBy(Attendance::getDate));
        List<Map<String, Object>> dailyStats = new ArrayList<>();
        LocalDate today = LocalDate.now();
        for (int i = 29; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            List<Attendance> dayRecs = byDate.getOrDefault(d, Collections.emptyList());
            long total = dayRecs.size();
            long present = dayRecs.stream().filter(a -> "PRESENT".equals(a.getStatus())).count();
            long late = dayRecs.stream().filter(a -> "LATE".equals(a.getStatus())).count();
            long absent = dayRecs.stream().filter(a -> "ABSENT".equals(a.getStatus())).count();
            double pct = total > 0 ? Math.round((present + late) * 100.0 / total) : 0;
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("date", d.toString());
            row.put("dayOfWeek", d.getDayOfWeek().toString());
            row.put("total", total);
            row.put("present", present);
            row.put("late", late);
            row.put("absent", absent);
            row.put("percentage", pct);
            dailyStats.add(row);
        }
        result.put("dailyStats", dailyStats);

        // 2. Day-of-week averages
        Map<String, List<Map<String, Object>>> byDow = dailyStats.stream()
            .filter(d -> ((Number)d.get("total")).longValue() > 0)
            .collect(Collectors.groupingBy(d -> (String)d.get("dayOfWeek")));
        List<Map<String, Object>> dowStats = new ArrayList<>();
        String[] days = {"SATURDAY","SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY"};
        for (String day : days) {
            List<Map<String, Object>> recs = byDow.getOrDefault(day, Collections.emptyList());
            double avg = recs.stream().mapToDouble(r -> ((Number)r.get("percentage")).doubleValue()).average().orElse(0);
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("day", day.charAt(0) + day.substring(1).toLowerCase());
            row.put("avgPercentage", Math.round(avg));
            row.put("classCount", recs.size());
            dowStats.add(row);
        }
        result.put("dayOfWeekStats", dowStats);

        // 3. Per-subject attendance rates
        Map<Long, List<Attendance>> bySubject = all.stream()
            .collect(Collectors.groupingBy(a -> a.getSubject().getId()));
        List<Map<String, Object>> subjectRates = new ArrayList<>();
        for (Map.Entry<Long, List<Attendance>> entry : bySubject.entrySet()) {
            List<Attendance> recs = entry.getValue();
            String name = recs.get(0).getSubject().getName();
            long total = recs.size();
            long present = recs.stream().filter(a -> "PRESENT".equals(a.getStatus())).count();
            long late = recs.stream().filter(a -> "LATE".equals(a.getStatus())).count();
            double pct = total > 0 ? Math.round((present + late) * 100.0 / total) : 0;
            long totalClasses = recs.stream().map(Attendance::getDate).distinct().count();
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("subjectName", name);
            row.put("totalRecords", total);
            row.put("totalClasses", totalClasses);
            row.put("present", present);
            row.put("late", late);
            row.put("absent", total - present - late);
            row.put("percentage", pct);
            subjectRates.add(row);
        }
        subjectRates.sort((a, b) -> Double.compare(
            ((Number)b.get("percentage")).doubleValue(),
            ((Number)a.get("percentage")).doubleValue()));
        result.put("subjectRates", subjectRates);

        // 4. At-risk students (below 75% in any subject)
        List<Map<String, Object>> atRisk = new ArrayList<>();
        Map<Long, Map<Long, List<Attendance>>> bySubjectStudent = all.stream()
            .collect(Collectors.groupingBy(
                a -> a.getSubject().getId(),
                Collectors.groupingBy(a -> a.getStudent().getId())));
        for (Map.Entry<Long, Map<Long, List<Attendance>>> subEntry : bySubjectStudent.entrySet()) {
            long totalClasses = bySubject.get(subEntry.getKey()).stream()
                .map(Attendance::getDate).distinct().count();
            String subName = bySubject.get(subEntry.getKey()).get(0).getSubject().getName();
            for (Map.Entry<Long, List<Attendance>> stuEntry : subEntry.getValue().entrySet()) {
                List<Attendance> recs = stuEntry.getValue();
                long present = recs.stream().filter(a -> "PRESENT".equals(a.getStatus())).count();
                double pct = totalClasses > 0 ? Math.round(present * 100.0 / totalClasses) : 0;
                if (pct < 75) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("studentName", recs.get(0).getStudent().getName() != null
                        ? recs.get(0).getStudent().getName() : recs.get(0).getStudent().getEmail());
                    row.put("subjectName", subName);
                    row.put("percentage", pct);
                    row.put("present", present);
                    row.put("totalClasses", totalClasses);
                    atRisk.add(row);
                }
            }
        }
        atRisk.sort((a, b) -> Double.compare(
            ((Number)a.get("percentage")).doubleValue(),
            ((Number)b.get("percentage")).doubleValue()));
        result.put("atRiskStudents", atRisk);

        // 5. Overall stats
        long totalRecords = all.size();
        long totalPresent = all.stream().filter(a -> "PRESENT".equals(a.getStatus())).count();
        long totalLate = all.stream().filter(a -> "LATE".equals(a.getStatus())).count();
        long totalAbsent = all.stream().filter(a -> "ABSENT".equals(a.getStatus())).count();
        long totalDays = all.stream().map(Attendance::getDate).distinct().count();
        result.put("totalRecords", totalRecords);
        result.put("totalPresent", totalPresent);
        result.put("totalLate", totalLate);
        result.put("totalAbsent", totalAbsent);
        result.put("totalDays", totalDays);
        result.put("overallRate", totalRecords > 0
            ? Math.round((totalPresent + totalLate) * 100.0 / totalRecords) : 0);

        return ResponseEntity.ok(result);
    }
}
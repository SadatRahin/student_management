package com.studentmanagement.controller;

import com.studentmanagement.entity.Routine;
import com.studentmanagement.entity.Subject;
import com.studentmanagement.entity.User;
import com.studentmanagement.repository.RoutineRepository;
import com.studentmanagement.repository.SubjectRepository;
import com.studentmanagement.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/routine")
@CrossOrigin(origins = "*")
public class RoutineController {

    @Autowired private RoutineRepository routineRepository;
    @Autowired private SubjectRepository subjectRepository;
    @Autowired private UserRepository    userRepository;

    @GetMapping
    public ResponseEntity<List<Routine>> getAll() {
        return ResponseEntity.ok(routineRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Map<String, Object> body) {
        try {
            String dayOfWeek = (String) body.get("dayOfWeek");
            String timeSlot  = (String) body.get("timeSlot");
            String roomNo    = (String) body.get("roomNo");

            Long subjectId = Long.valueOf(body.get("subjectId").toString());
            Long teacherId = Long.valueOf(body.get("teacherId").toString());

            Subject subject = subjectRepository.findById(subjectId).orElse(null);
            User    teacher = userRepository.findById(teacherId).orElse(null);

            if (subject == null) return ResponseEntity.badRequest().body("Subject not found");
            if (teacher == null) return ResponseEntity.badRequest().body("Teacher not found");

            // Upsert: if slot already exists for day+time, update it
            List<Routine> existing = routineRepository.findAll().stream()
                .filter(r -> r.getDayOfWeek().equals(dayOfWeek) && r.getTimeSlot().equals(timeSlot))
                .toList();

            Routine routine = existing.isEmpty() ? new Routine() : existing.get(0);
            routine.setDayOfWeek(dayOfWeek);
            routine.setTimeSlot(timeSlot);
            routine.setRoomNo(roomNo);
            routine.setSubject(subject);
            routine.setTeacher(teacher);

            routineRepository.save(routine);
            return ResponseEntity.ok(routine);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        if (routineRepository.existsById(id)) {
            routineRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
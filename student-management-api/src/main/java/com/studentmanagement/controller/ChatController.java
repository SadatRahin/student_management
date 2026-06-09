package com.studentmanagement.controller;

import com.studentmanagement.entity.ChatMessage;
import com.studentmanagement.entity.Subject;
import com.studentmanagement.entity.User;
import com.studentmanagement.repository.ChatMessageRepository;
import com.studentmanagement.repository.SubjectRepository;
import com.studentmanagement.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/chat")
@CrossOrigin(origins = "*")
public class ChatController {

    @Autowired private ChatMessageRepository chatRepo;
    @Autowired private UserRepository userRepo;
    @Autowired private SubjectRepository subjectRepo;

    // ── Send a message ──
    @PostMapping("/send")
    public ResponseEntity<?> send(@RequestBody Map<String, Object> body) {
        try {
            Long senderId   = Long.valueOf(body.get("senderId").toString());
            Long receiverId = Long.valueOf(body.get("receiverId").toString());
            String text      = body.get("message").toString();
            String type      = body.getOrDefault("messageType", "CHAT").toString();

            User sender   = userRepo.findById(senderId).orElseThrow();
            User receiver = userRepo.findById(receiverId).orElseThrow();

            ChatMessage msg = new ChatMessage();
            msg.setSender(sender);
            msg.setReceiver(receiver);
            msg.setMessage(text);
            msg.setMessageType(type);
            msg.setTimestamp(LocalDateTime.now());

            if (body.containsKey("subjectId") && body.get("subjectId") != null) {
                Long subId = Long.valueOf(body.get("subjectId").toString());
                subjectRepo.findById(subId).ifPresent(msg::setSubject);
            }

            chatRepo.save(msg);
            return ResponseEntity.ok(msg);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // ── Get conversation between two users ──
    @GetMapping("/messages")
    public ResponseEntity<?> getMessages(@RequestParam Long userId, @RequestParam Long otherId) {
        return ResponseEntity.ok(chatRepo.findConversation(userId, otherId));
    }

    // ── Mark messages as read ──
    @PutMapping("/read")
    public ResponseEntity<?> markRead(@RequestParam Long userId, @RequestParam Long otherId) {
        List<ChatMessage> msgs = chatRepo.findConversation(userId, otherId);
        for (ChatMessage m : msgs) {
            if (m.getReceiver().getId().equals(userId) && !m.isReadStatus()) {
                m.setReadStatus(true);
                chatRepo.save(m);
            }
        }
        return ResponseEntity.ok("OK");
    }

    // ── Get contacts for a user (people they can chat with) ──
    @GetMapping("/contacts")
    public ResponseEntity<?> getContacts(@RequestParam String email) {
        User me = userRepo.findByEmail(email).orElse(null);
        if (me == null) return ResponseEntity.ok(Collections.emptyList());

        Set<Long> contactIds = new HashSet<>();
        List<Map<String, Object>> contacts = new ArrayList<>();
        String myRole = me.getRole();

        if ("ADMIN".equals(myRole)) {
            // Admin can chat with everyone
            for (User u : userRepo.findAll()) {
                if (!u.getId().equals(me.getId())) contactIds.add(u.getId());
            }
        } else if ("TEACHER".equals(myRole)) {
            // Teacher: students in their subjects + admins + co-teachers
            List<Subject> mySubjects = subjectRepo.findByTeacher(me);
            for (Subject s : mySubjects) {
                for (User stu : s.getStudents()) contactIds.add(stu.getId());
            }
            for (User u : userRepo.findAll()) {
                if ("ADMIN".equals(u.getRole())) contactIds.add(u.getId());
            }
        } else {
            // Student: teachers of enrolled subjects + admins
            for (Subject s : me.getSubjects()) {
                if (s.getTeacher() != null) contactIds.add(s.getTeacher().getId());
            }
            for (User u : userRepo.findAll()) {
                if ("ADMIN".equals(u.getRole())) contactIds.add(u.getId());
            }
        }

        contactIds.remove(me.getId());

        // Build contact list with unread counts
        List<ChatMessage> unread = chatRepo.findUnread(me.getId());
        for (Long cid : contactIds) {
            User u = userRepo.findById(cid).orElse(null);
            if (u == null) continue;
            long unreadCount = unread.stream().filter(m -> m.getSender().getId().equals(cid)).count();
            Map<String, Object> c = new LinkedHashMap<>();
            c.put("id", u.getId());
            c.put("name", u.getName() != null ? u.getName() : u.getEmail());
            c.put("email", u.getEmail());
            c.put("role", u.getRole());
            c.put("unread", unreadCount);
            contacts.add(c);
        }

        // Sort: unread first, then by name
        contacts.sort((a, b) -> {
            int cmp = Long.compare((Long)b.get("unread"), (Long)a.get("unread"));
            return cmp != 0 ? cmp : ((String)a.get("name")).compareToIgnoreCase((String)b.get("name"));
        });

        return ResponseEntity.ok(contacts);
    }

    // ── Get my user ID by email (auto-creates admin if needed) ──
    @GetMapping("/me")
    public ResponseEntity<?> getMyId(@RequestParam String email) {
        User me = userRepo.findByEmail(email).orElse(null);

        // Auto-create admin user in DB if doesn't exist (hardcoded login)
        if (me == null && "admin@gmail.com".equals(email)) {
            me = new User();
            me.setEmail("admin@gmail.com");
            me.setName("Admin");
            me.setPassword("admin");
            me.setRole("ADMIN");
            me = userRepo.save(me);
        }

        if (me == null) return ResponseEntity.badRequest().body("Not found");
        Map<String, Object> r = new LinkedHashMap<>();
        r.put("id", me.getId());
        r.put("name", me.getName());
        r.put("email", me.getEmail());
        r.put("role", me.getRole());
        return ResponseEntity.ok(r);
    }
}
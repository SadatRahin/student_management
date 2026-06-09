package com.studentmanagement.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.time.LocalDateTime;

@Entity
@Table(name = "meetings")
public class Meeting {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, unique = true)
    private String roomCode;

    @ManyToOne
    @JoinColumn(name = "subject_id")
    @JsonIgnoreProperties({"students", "teacher"})
    private Subject subject;

    @ManyToOne
    @JoinColumn(name = "created_by_id")
    @JsonIgnoreProperties({"subjects", "password"})
    private User createdBy;

    @Column(nullable = false)
    private String status; // ACTIVE, ENDED

    private LocalDateTime createdAt;

    public Meeting() {
        this.createdAt = LocalDateTime.now();
        this.status = "ACTIVE";
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getRoomCode() { return roomCode; }
    public void setRoomCode(String roomCode) { this.roomCode = roomCode; }

    public Subject getSubject() { return subject; }
    public void setSubject(Subject subject) { this.subject = subject; }

    public User getCreatedBy() { return createdBy; }
    public void setCreatedBy(User createdBy) { this.createdBy = createdBy; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
package com.studentmanagement.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Table(name = "routines",
       uniqueConstraints = @UniqueConstraint(columnNames = {"day_of_week", "time_slot"}))
public class Routine {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "day_of_week", nullable = false)
    private String dayOfWeek;

    @Column(name = "time_slot", nullable = false)
    private String timeSlot;

    @Column(name = "room_no")
    private String roomNo;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "subject_id")
    @JsonIgnoreProperties({"students", "teacher"})
    private Subject subject;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "teacher_id")
    @JsonIgnoreProperties({"subjects", "password"})
    private User teacher;

    // ── Getters & Setters ──
    public Long getId()              { return id; }
    public void setId(Long id)       { this.id = id; }

    public String getDayOfWeek()                 { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek)   { this.dayOfWeek = dayOfWeek; }

    public String getTimeSlot()                { return timeSlot; }
    public void setTimeSlot(String timeSlot)   { this.timeSlot = timeSlot; }

    public String getRoomNo()              { return roomNo; }
    public void setRoomNo(String roomNo)   { this.roomNo = roomNo; }

    public Subject getSubject()                { return subject; }
    public void setSubject(Subject subject)    { this.subject = subject; }

    public User getTeacher()               { return teacher; }
    public void setTeacher(User teacher)   { this.teacher = teacher; }
}
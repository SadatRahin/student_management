package com.studentmanagement.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.time.LocalDateTime;

@Entity
@Table(name = "chat_messages")
public class ChatMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "sender_id", nullable = false)
    @JsonIgnoreProperties({"subjects", "password"})
    private User sender;

    @ManyToOne
    @JoinColumn(name = "receiver_id", nullable = false)
    @JsonIgnoreProperties({"subjects", "password"})
    private User receiver;

    @ManyToOne
    @JoinColumn(name = "subject_id")
    @JsonIgnoreProperties({"students", "teacher"})
    private Subject subject;

    @Column(nullable = false, length = 2000)
    private String message;

    @Column(nullable = false)
    private String messageType; // CHAT, FEEDBACK, QUERY

    private LocalDateTime timestamp;

    @Column(name = "read_status")
    private boolean readStatus;

    public ChatMessage() {
        this.timestamp = LocalDateTime.now();
        this.readStatus = false;
        this.messageType = "CHAT";
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public User getSender() { return sender; }
    public void setSender(User sender) { this.sender = sender; }
    public User getReceiver() { return receiver; }
    public void setReceiver(User receiver) { this.receiver = receiver; }
    public Subject getSubject() { return subject; }
    public void setSubject(Subject subject) { this.subject = subject; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getMessageType() { return messageType; }
    public void setMessageType(String messageType) { this.messageType = messageType; }
    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
    public boolean isReadStatus() { return readStatus; }
    public void setReadStatus(boolean readStatus) { this.readStatus = readStatus; }
}
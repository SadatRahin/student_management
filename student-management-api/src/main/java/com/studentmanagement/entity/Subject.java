

/* 
package com.studentmanagement.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "subjects")
public class Subject {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;

    @ManyToMany(mappedBy = "subjects")
    @JsonIgnoreProperties("subjects")
    private List<User> students = new ArrayList<>();

    public Subject() {}

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public List<User> getStudents() { return students; }
    public void setStudents(List<User> students) { this.students = students; }
}

*/



package com.studentmanagement.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "subjects")
public class Subject {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    // Teacher assigned to this subject
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "teacher_id")
    @JsonIgnoreProperties({"subjects", "password", "students"})
    private User teacher;

    // Students enrolled in this subject (inverse side of User.subjects)
    @ManyToMany(mappedBy = "subjects", fetch = FetchType.EAGER)
    @JsonIgnoreProperties("subjects")
    private List<User> students = new ArrayList<>();

    public Subject() {}

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public User getTeacher() { return teacher; }
    public void setTeacher(User teacher) { this.teacher = teacher; }

    public List<User> getStudents() { return students; }
    public void setStudents(List<User> students) { this.students = students; }
}
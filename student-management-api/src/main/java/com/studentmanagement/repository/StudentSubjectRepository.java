package com.studentmanagement.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.studentmanagement.entity.StudentSubject;

@Repository
public interface StudentSubjectRepository extends JpaRepository<StudentSubject, Long> {
}
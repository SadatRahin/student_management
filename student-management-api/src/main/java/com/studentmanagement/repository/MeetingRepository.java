package com.studentmanagement.repository;

import com.studentmanagement.entity.Meeting;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MeetingRepository extends JpaRepository<Meeting, Long> {

    List<Meeting> findByStatus(String status);

    List<Meeting> findBySubjectId(Long subjectId);

    List<Meeting> findByCreatedByEmail(String email);

    List<Meeting> findByCreatedByEmailAndStatus(String email, String status);

    List<Meeting> findBySubjectIdInAndStatus(List<Long> subjectIds, String status);

    List<Meeting> findAllByOrderByCreatedAtDesc();
}
package com.studentmanagement.repository;

import com.studentmanagement.entity.Notice;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface NoticeRepository extends JpaRepository<Notice, Long> {
    List<Notice> findByActiveTrueOrderByCreatedAtDesc();
    List<Notice> findAllByOrderByCreatedAtDesc();
}
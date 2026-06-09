package com.studentmanagement.repository;

import com.studentmanagement.entity.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    @Query("SELECT m FROM ChatMessage m WHERE (m.sender.id = :uid AND m.receiver.id = :oid) OR (m.sender.id = :oid AND m.receiver.id = :uid) ORDER BY m.timestamp ASC")
    List<ChatMessage> findConversation(@Param("uid") Long userId, @Param("oid") Long otherId);

    @Query("SELECT m FROM ChatMessage m WHERE m.receiver.id = :uid AND m.readStatus = false")
    List<ChatMessage> findUnread(@Param("uid") Long userId);

    @Query(value = "SELECT DISTINCT CASE WHEN sender_id = :uid THEN receiver_id ELSE sender_id END FROM chat_messages WHERE sender_id = :uid OR receiver_id = :uid", nativeQuery = true)
    List<Long> findContactIds(@Param("uid") Long userId);
}
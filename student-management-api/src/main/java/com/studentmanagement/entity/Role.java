package com.studentmanagement.entity;

import com.fasterxml.jackson.annotation.JsonCreator;

public enum Role {
    STUDENT, TEACHER;

    @JsonCreator
        public static Role fromValue(String value) {
            return Role.valueOf(value.toUpperCase());
        }
    
}
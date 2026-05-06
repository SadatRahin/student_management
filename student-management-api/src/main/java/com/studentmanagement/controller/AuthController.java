/*
package com.studentmanagement.controller;

import com.studentmanagement.entity.User;
import com.studentmanagement.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "http://localhost:4200") // Allows your Angular and Flutter apps to connect
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/signup")
public ResponseEntity<?> registerUser(@RequestBody User user) {
    if (userRepository.findByEmail(user.getEmail()).isPresent()) {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Error: Email already exists!");
        return ResponseEntity.badRequest().body(response);
    }

    userRepository.save(user);
    
    Map<String, String> response = new HashMap<>();
    response.put("message", "User registered successfully as " + user.getRole());
    return ResponseEntity.ok(response); // This sends valid JSON: {"message": "..."}
}

@PostMapping("/login")
public ResponseEntity<?> loginUser(@RequestBody User loginRequest) {
    // 1. Find user by email
    java.util.Optional<User> user = userRepository.findByEmail(loginRequest.getEmail());

    // 2. Check if user exists and password matches
    if (user.isPresent() && user.get().getPassword().equals(loginRequest.getPassword())) {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Login successful");
        response.put("role", user.get().getRole());
        response.put("email", user.get().getEmail());
        
        return ResponseEntity.ok(response); // Sends JSON: {"message": "...", "role": "..."}
    }

    // 3. If login fails
    Map<String, String> errorResponse = new HashMap<>();
    errorResponse.put("message", "Invalid email or password");
    return ResponseEntity.status(401).body(errorResponse);
}
}
*/
package com.studentmanagement.controller;

import com.studentmanagement.entity.User;
import com.studentmanagement.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "http://localhost:4200")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody User user) {
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("Error: Email is already taken!");
        }
        
        // Save the new user to the 'users' table
        userRepository.save(user);
        return ResponseEntity.ok(Collections.singletonMap("message", "User registered successfully!"));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody User loginRequest) {
        Optional<User> userOptional = userRepository.findByEmail(loginRequest.getEmail());

        if (userOptional.isPresent()) {
            User user = userOptional.get();
            // Basic password check (Note: In production, use BCrypt)
            if (user.getPassword().equals(loginRequest.getPassword())) {
                Map<String, String> response = new HashMap<>();
                response.put("role", user.getRole());
                response.put("email", user.getEmail());
                response.put("message", "Login successful");
                return ResponseEntity.ok(response);
            }
        }
        
        return ResponseEntity.status(401).body("Invalid email or password");
    }
}
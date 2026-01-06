package com.exam.authservice.controller;

import com.exam.authservice.dto.LoginRequest;
import com.exam.authservice.repository.UserRepository;
import com.exam.authservice.service.JwtService;
import lombok.AllArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
@AllArgsConstructor
public class AuthController {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final UserDetailsService userDetailsService;

    @PostMapping("login")
    public String login(@RequestBody LoginRequest loginRequest) {
        // Fetch user from database
        var user = userRepository.findByUsername(loginRequest.getUsername())
            .orElseThrow(() -> new UsernameNotFoundException("User not found"));
        
        // Verify password by comparing with stored hash
        if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
            throw new BadCredentialsException("Invalid credentials");
        }
        
        // Load user details and generate JWT token
        var userDetails = userDetailsService.loadUserByUsername(loginRequest.getUsername());
        return jwtService.generateToken(userDetails);
    }
}

package com.exam.authservice.config;

import com.exam.authservice.service.JwtService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * JWT Authentication Filter
 * 
 * This filter intercepts every request (except /auth endpoints) to:
 * 1. Extract JWT token from Authorization header
 * 2. Validate the token using JwtService
 * 3. Load user details
 * 4. Set authentication in SecurityContext for the request duration
 * 
 * Extends OncePerRequestFilter to ensure it runs only once per request
 */
@Component
@AllArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {

        // Extract Authorization header
        String authHeader = request.getHeader("Authorization");
        String jwt;
        String username;

        // If no Authorization header or doesn't start with "Bearer ", skip this filter
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        // Extract JWT token (remove "Bearer " prefix)
        jwt = authHeader.substring(7);

        // Extract username from token
        username = jwtService.extractUsername(jwt);

        // If username exists and user is not already authenticated
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            // Load user details from database
            UserDetails userDetails = this.userDetailsService.loadUserByUsername(username);

            // Validate token
            if (jwtService.isTokenValid(jwt, userDetails)) {
                // Create authentication token
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null, // No credentials needed here
                        userDetails.getAuthorities()
                );

                // Set request details
                authToken.setDetails(
                        new WebAuthenticationDetailsSource().buildDetails(request)
                );

                // Set authentication in security context
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        }

        // Continue with the filter chain
        filterChain.doFilter(request, response);
    }
}

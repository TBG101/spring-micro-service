package com.exam.gatewayservice.config;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;

import java.util.Collections;

/**
 * Custom Reactive WebFilter to handle JWT Authentication
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter implements WebFilter {

    private final JwtTokenProvider jwtTokenProvider;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        String token = resolveToken(exchange.getRequest());

        // 1. Check if token exists and is valid
        if (StringUtils.hasText(token) && jwtTokenProvider.validateToken(token)) {
            // 2. Extract username
            String username = jwtTokenProvider.getUsernameFromToken(token);

            // 3. Create UserDetails (You can extend this to extract Roles from JWT if needed)
            UserDetails userDetails = User.builder().username(username).password("") // Password not needed for token auth
                    .roles("USER") // Default role, or extract from token claims
                    .build();

            // 4. Create Authentication object
            UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());

            var authorities = jwtTokenProvider.getAuthoritiesFromToken(token);

            // new request
            ServerHttpRequest mutatedRequest = exchange.getRequest()
                    .mutate()
                    .header("X-Authenticated-User", username)
                    .header("X-Roles", String.valueOf(authorities))
                    .build();

            ServerWebExchange mutatedExchange = exchange
                    .mutate()
                    .request(mutatedRequest)
                    .build();

            // 5. Pass to chain WITH Security Context
            return chain.filter(exchange).contextWrite(ReactiveSecurityContextHolder.withAuthentication(authentication));
        }

        // 6. If no valid token, continue without setting security context
        // (Spring Security will reject it later if the path requires auth)
        return chain.filter(exchange);
    }

    private String resolveToken(ServerHttpRequest request) {
        String bearerToken = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
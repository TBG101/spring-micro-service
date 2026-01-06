package com.exam.authservice;

import com.exam.authservice.entities.User;
import com.exam.authservice.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootApplication
@EnableDiscoveryClient
public class AuthServiceApplication {
    @Bean
    public CommandLineRunner commandLineRunner(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        return args -> {
            if (userRepository.count() == 0) {
                User user = new User();
                user.setUsername("admin");
                user.setPassword(passwordEncoder.encode("admin"));
                user.setRole("ADMIN");
                userRepository.save(user);

                User user2 = new User();
                user2.setUsername("user");
                user2.setPassword(passwordEncoder.encode("user"));
                user2.setRole("USER");
                userRepository.save(user2);
            }
        };
    }


    public static void main(String[] args) {
        SpringApplication.run(AuthServiceApplication.class, args);
    }

}

package com.exam.productservice.config;

import com.exam.productservice.entities.Category;
import com.exam.productservice.entities.Product;
import com.exam.productservice.repository.CategoryRepository;
import com.exam.productservice.repository.ProductRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.annotation.Transactional;

@Configuration
public class MockDataConfig {

    @Bean
    @Transactional
    public CommandLineRunner loadMockData(ProductRepository productRepository, CategoryRepository categoryRepository) {
        return args -> {
            // Check if categories exist
            if (categoryRepository.count() == 0) {
                System.out.println("Loading mock categories...");
                
                // Create and save mock categories
                Category electronics = Category.builder()
                        .name("Electronics")
                        .build();

                Category clothing = Category.builder()
                        .name("Clothing")
                        .build();

                Category home = Category.builder()
                        .name("Home & Garden")
                        .build();

                Category books = Category.builder()
                        .name("Books")
                        .build();

                categoryRepository.save(electronics);
                categoryRepository.save(clothing);
                categoryRepository.save(home);
                categoryRepository.save(books);
                categoryRepository.flush();

                System.out.println("Mock categories loaded successfully!");
            }
            
            // Check if products exist
            if (productRepository.count() == 0) {
                System.out.println("Loading mock products...");
                
                Category electronics = categoryRepository.findByName("Electronics");
                Category clothing = categoryRepository.findByName("Clothing");
                Category home = categoryRepository.findByName("Home & Garden");
                Category books = categoryRepository.findByName("Books");

                // Create and save mock products
                Product product1 = Product.builder()
                        .name("Wireless Headphones")
                        .description("High-quality Bluetooth headphones with noise cancellation")
                        .price(149.99)
                        .category(electronics)
                        .stockId(1L)
                        .build();

                Product product2 = Product.builder()
                        .name("Cotton T-Shirt")
                        .description("Comfortable 100% cotton t-shirt")
                        .price(29.99)
                        .category(clothing)
                        .stockId(2L)
                        .build();

                Product product3 = Product.builder()
                        .name("LED Desk Lamp")
                        .description("Energy-efficient LED lamp with adjustable brightness")
                        .price(59.99)
                        .category(electronics)
                        .stockId(3L)
                        .build();

                Product product4 = Product.builder()
                        .name("Yoga Mat")
                        .description("Premium non-slip yoga mat")
                        .price(39.99)
                        .category(home)
                        .stockId(4L)
                        .build();

                Product product5 = Product.builder()
                        .name("Programming Guide")
                        .description("Complete guide to Java programming")
                        .price(49.99)
                        .category(books)
                        .stockId(5L)
                        .build();

                productRepository.save(product1);
                productRepository.save(product2);
                productRepository.save(product3);
                productRepository.save(product4);
                productRepository.save(product5);
                productRepository.flush();

                System.out.println("Mock products loaded successfully!");
                System.out.println("Total products in database: " + productRepository.count());
            } else {
                System.out.println("Products already exist in database. Total: " + productRepository.count());
            }
        };
    }
}

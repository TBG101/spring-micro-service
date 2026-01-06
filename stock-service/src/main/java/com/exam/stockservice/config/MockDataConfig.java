package com.exam.stockservice.config;

import com.exam.stockservice.entities.Stock;
import com.exam.stockservice.repository.StockRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MockDataConfig {

    @Bean
    public CommandLineRunner loadMockData(StockRepository stockRepository) {
        return args -> {
            // Check if data already exists
            if (stockRepository.count() == 0) {
                // Create and save mock stock data
                Stock stock1 = Stock.builder()
                        .productId(1L)
                        .quantity(100)
                        .build();

                Stock stock2 = Stock.builder()
                        .productId(2L)
                        .quantity(250)
                        .build();

                Stock stock3 = Stock.builder()
                        .productId(3L)
                        .quantity(75)
                        .build();

                Stock stock4 = Stock.builder()
                        .productId(4L)
                        .quantity(500)
                        .build();

                Stock stock5 = Stock.builder()
                        .productId(5L)
                        .quantity(150)
                        .build();

                stockRepository.save(stock1);
                stockRepository.save(stock2);
                stockRepository.save(stock3);
                stockRepository.save(stock4);
                stockRepository.save(stock5);

                System.out.println("Mock data loaded successfully!");
            }
        };
    }
}

package com.exam.stockservice.repository;

import com.exam.stockservice.entities.Stock;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StockRepository extends JpaRepository<Stock, Long> {
    public Stock findByProductId(Long productId);
}

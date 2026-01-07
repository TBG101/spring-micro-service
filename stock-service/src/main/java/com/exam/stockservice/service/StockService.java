package com.exam.stockservice.service;

import com.exam.stockservice.entities.Stock;
import com.exam.stockservice.repository.StockRepository;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
@Transactional
public class StockService {
    private final StockRepository stockRepository;

    public Stock findStockById(Long id) {
        return stockRepository.findById(id).orElse(null);
    }

    public List<Stock> findAll() {
        return stockRepository.findAll();
    }

    public Stock findStockByProductId(Long productId) {
        return stockRepository.findByProductId(productId);
    }

    public Stock saveStock(Stock stock) {
        return stockRepository.save(stock);
    }
}

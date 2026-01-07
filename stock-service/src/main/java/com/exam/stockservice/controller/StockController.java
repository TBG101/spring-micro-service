package com.exam.stockservice.controller;

import com.exam.stockservice.entities.Stock;
import com.exam.stockservice.service.StockService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@AllArgsConstructor
@RequestMapping("/stocks")
public class StockController {
    private final StockService stockService;

    @GetMapping()
    public List<Stock> getStocks() {
        return stockService.findAll();
    }

    @GetMapping("{id}")
    public Stock getStockById(@PathVariable Long id) {
        return stockService.findStockById(id);
    }

    @GetMapping("/product/{id}")
    public Stock getStockByProductId(@PathVariable Long id) {
        return stockService.findStockByProductId(id);
    }

    @PostMapping()
    public Stock createStock(@RequestBody Stock stock) {
        return stockService.saveStock(stock);
    }
}

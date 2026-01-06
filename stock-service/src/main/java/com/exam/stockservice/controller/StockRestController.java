package com.exam.stockservice.controller;

import com.exam.stockservice.entities.Stock;
import com.exam.stockservice.tools.StockTool;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/stocks")
@RequiredArgsConstructor
public class StockRestController {
    private final StockTool stockTool;

    @GetMapping("")
    public List<Stock> getAllStocks() {
        return stockTool.getStocks();
    }

    @GetMapping("/{id}")
    public Stock getStockById(@PathVariable Long id) {
        return stockTool.getStockById(id);
    }

    @GetMapping("/product/{productId}")
    public Stock getStockByProductId(@PathVariable Long productId) {
        return stockTool.getStockByProductId(productId);
    }
}

package com.exam.productservice.feign;

import com.exam.productservice.model.Stock;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@FeignClient(name = "STOCK-SERVICE")
public interface StockClient {
    @GetMapping("/stocks")
    @CircuitBreaker(name = "stock-client-cb", fallbackMethod = "getDefaultAllStock")
    List<Stock> getAllStocks();

    default List<Stock> getDefaultAllStock() {
        return List.of();
    }

    @GetMapping("/stocks/{id}")
    @CircuitBreaker(name = "stock-client-cb", fallbackMethod = "getDefaultStock")
    Stock getStockById(@PathVariable("id") Long id);

    @GetMapping("/stocks/product/{id}")
    @CircuitBreaker(name = "stock-client-cb", fallbackMethod = "getDefaultStock")
    Stock getStockByProductId(@PathVariable("id") Long id);

    @PostMapping("/stocks")
    @CircuitBreaker(name = "stock-client-cb", fallbackMethod = "getDefaultStock")
    Stock createStock(@RequestBody Stock stock);

    default Stock getDefaultStock(Long id) {
        return Stock.builder().id(id).quantity(0).build();
    }

}

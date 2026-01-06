package com.exam.stockservice.controller;

import com.exam.stockservice.entities.Stock;
import com.exam.stockservice.tools.StockTool;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/mcp")
@RequiredArgsConstructor
public class McpStockController {
    private final StockTool stockTool;

    /**
     * MCP Server endpoint for stocks
     * Exposes stock tools via MCP protocol
     */
    @GetMapping("")
    public Map<String, Object> getMcpInfo() {
        return Map.of(
            "name", "Stock Service MCP Server",
            "version", "1.0",
            "tools", List.of(
                Map.of("name", "getStocks", "description", "Get all stocks for products"),
                Map.of("name", "getStock", "description", "Get stock by id"),
                Map.of("name", "getStockByProductId", "description", "Get stock by product id")
            )
        );
    }

    @PostMapping("/tools/getStocks")
    public List<Stock> getStocks() {
        return stockTool.getStocks();
    }

    @PostMapping("/tools/getStock")
    public Stock getStock(@RequestBody Map<String, Object> params) {
        Long id = ((Number) params.get("id")).longValue();
        return stockTool.getStockById(id);
    }

    @PostMapping("/tools/getStockByProductId")
    public Stock getStockByProductId(@RequestBody Map<String, Object> params) {
        Long productId = ((Number) params.get("productId")).longValue();
        return stockTool.getStockByProductId(productId);
    }
}

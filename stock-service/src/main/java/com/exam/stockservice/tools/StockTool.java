package com.exam.stockservice.tools;

import com.exam.stockservice.entities.Stock;
import com.exam.stockservice.service.StockService;
import lombok.AllArgsConstructor;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@AllArgsConstructor
public class StockTool {
    private final StockService stockService;

    @Tool(name = "getStocks", description = "Get all stocks for products")
    public List<Stock> getStocks() {
        return stockService.findAll();
    }

    @Tool(name = "getStock", description = "Get stock by id")
    public Stock getStockById(@ToolParam(description = "id of the stock") Long id) {
        return stockService.findStockById(id);
    }

    @Tool(name = "getStockByProductId", description = "Get stock by product id")
    public Stock getStockByProductId(@ToolParam(description = "id of the product") Long productId) {
        return stockService.findStockByProductId(productId);
    }
}

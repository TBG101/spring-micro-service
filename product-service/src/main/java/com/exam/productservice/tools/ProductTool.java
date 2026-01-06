package com.exam.productservice.tools;

import com.exam.productservice.entities.Product;
import com.exam.productservice.service.ProductService;
import lombok.AllArgsConstructor;
import org.springaicommunity.mcp.annotation.McpTool;
import org.springaicommunity.mcp.annotation.McpToolParam;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@AllArgsConstructor
public class ProductTool {
    private final ProductService productService;

    @McpTool(name = "getAllProducts", description = "Get a list of all available products with their stock")
    public List<Product> getAllProducts() {
        return productService.getAllProducts();
    }

    @McpTool(name = "getProduct", description = "Get product by id with it's stock")
    public Product getProduct(@McpToolParam(description = "Id of the product") long id) {
        return productService.getProductById(id);
    }
}

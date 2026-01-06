package com.exam.productservice.controller;

import com.exam.productservice.entities.Product;
import com.exam.productservice.tools.ProductTool;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/mcp")
@RequiredArgsConstructor
public class McpProductController {
    private final ProductTool productTool;

    /**
     * MCP Server endpoint for products
     * Exposes product tools via MCP protocol
     */
    @GetMapping("")
    public Map<String, Object> getMcpInfo() {
        return Map.of("name", "Product Service MCP Server", "version", "1.0", "tools", List.of(Map.of("name", "getProducts", "description", "Get all products with their stock"), Map.of("name", "getProduct", "description", "Get product by id with it's stock")));
    }

    @PostMapping("/tools/getProducts")
    public List<Product> getProducts() {
        return productTool.getAllProducts();
    }

    @PostMapping("/tools/getProduct")
    public Product getProduct(@RequestBody Map<String, Object> params) {
        Long id = ((Number) params.get("id")).longValue();
        return productTool.getProduct(id);
    }
}

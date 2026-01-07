package com.exam.productservice.controller;

import com.exam.productservice.dto.ProductRequest;
import com.exam.productservice.entities.Product;
import com.exam.productservice.service.ProductService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/product")
@AllArgsConstructor
public class ProductController {
    private final ProductService productService;


    @GetMapping()
    public List<Product> getProducts() {
        return productService.getAllProducts();
    }

    @GetMapping("{id}")
    public Product getProduct(@PathVariable Long id) {
        return productService.getProductById(id);
    }

    @PostMapping()
    public Product createProduct(@RequestBody ProductRequest request) {
        return productService.saveProduct(request.getProduct(), request.getQuantity());
    }
}

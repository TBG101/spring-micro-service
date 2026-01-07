package com.exam.productservice.service;

import com.exam.productservice.entities.Product;
import com.exam.productservice.feign.StockClient;
import com.exam.productservice.model.Stock;
import com.exam.productservice.repository.ProductRepository;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class ProductService {
    private final ProductRepository productRepository;
    private final StockClient stockClient;

    public List<Product> getAllProducts() {
        var products = productRepository.findAll();
        products.forEach(product -> {
            try {
                product.setStock(stockClient.getStockByProductId(product.getId()));
            } catch (Exception e) {
                // If stock service fails, set a default stock
                System.err.println("Failed to fetch stock for product " + product.getId() + ": " + e.getMessage());
                product.setStock(com.exam.productservice.model.Stock.builder()
                        .id(product.getId())
                        .quantity(0)
                        .build());
            }
        });
        return products;
    }

    public Product getProductById(Long id) {
        Product product = productRepository.findById(id).orElseThrow(() -> new RuntimeException("Product not found"));
        try {
            product.setStock(stockClient.getStockByProductId(id));
        } catch (Exception e) {
            // If stock service fails, set a default stock
            System.err.println("Failed to fetch stock for product " + id + ": " + e.getMessage());
            product.setStock(com.exam.productservice.model.Stock.builder()
                    .id(id)
                    .quantity(0)
                    .build());
        }
        return product;
    }

    public Product saveProduct(Product product, int quantity) {
        Product savedProduct = productRepository.save(product);
        try {
            Stock stock = Stock.builder()
                    .id(savedProduct.getId())
                    .quantity(quantity)
                    .build();
            Stock createdStock = stockClient.createStock(stock);
            savedProduct.setStock(createdStock);
            savedProduct.setStockId(createdStock.getId());
            productRepository.save(savedProduct);
        } catch (Exception e) {
            System.err.println("Failed to create stock for product " + savedProduct.getId() + ": " + e.getMessage());
            savedProduct.setStock(Stock.builder()
                    .id(savedProduct.getId())
                    .quantity(quantity)
                    .build());
        }
        return savedProduct;
    }
}

package com.exam.productservice.dto;

import com.exam.productservice.entities.Product;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ProductRequest {
    private Product product;
    private int quantity;
}

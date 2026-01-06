package com.exam.productservice.model;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class Stock {
    private long id;
    private int quantity;
}

package com.exam.productservice.repository;

import com.exam.productservice.entities.Category;
import com.exam.productservice.entities.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    public Product findByName(String name);

    public List<Product> findByCategory(Category category);

    public Product findByNameAndCategory(String name, Category category);

}

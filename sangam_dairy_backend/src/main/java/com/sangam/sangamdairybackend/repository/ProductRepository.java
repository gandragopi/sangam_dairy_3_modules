package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

@SuppressWarnings("all")
public interface ProductRepository extends JpaRepository<Product, Long> {

    @Query("SELECT p FROM Product p WHERE p.active IS NULL OR p.active = true")
    List<Product> findActiveProducts();

    List<Product> findByActiveTrue();

    List<Product> findByActiveFalse();

    List<Product> findByCategoryAndActiveTrue(String category);

    Optional<Product> findByNameAndCategory(String name, String category);

    Optional<Product> findByNameIgnoreCase(String name);

    boolean existsByNameIgnoreCase(String name);
}

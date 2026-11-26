package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

@SuppressWarnings("all")
public interface CartItemRepository extends JpaRepository<CartItem, Long> {

    List<CartItem> findByCartKey(String cartKey);

    Optional<CartItem> findByCartKeyAndProductIdAndPackSize(
            String cartKey,
            Long productId,
            String packSize
    );

    void deleteByCartKey(String cartKey);
}

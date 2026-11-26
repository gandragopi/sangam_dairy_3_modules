package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.CartItem;
import com.sangam.sangamdairybackend.repository.CartItemRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cart")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class CartController {

    private final CartItemRepository cartItemRepository;

    public CartController(CartItemRepository cartItemRepository) {
        this.cartItemRepository = cartItemRepository;
    }

    // ============================================================
    // GET CART
    // ============================================================

    @GetMapping("/{cartKey}")
    public List<CartItem> getCart(
            @PathVariable String cartKey) {

        return cartItemRepository.findByCartKey(cartKey);
    }

    // ============================================================
    // ADD TO CART
    // ============================================================

    @PostMapping
    public CartItem addToCart(
            @RequestBody CartItem cartItem) {

        var existingItem =
                cartItemRepository
                        .findByCartKeyAndProductIdAndPackSize(
                                cartItem.getCartKey(),
                                cartItem.getProductId(),
                                cartItem.getPackSize()
                        );

        if (existingItem.isPresent()) {

            CartItem item = existingItem.get();

            int oldQuantity =
                    item.getQuantity() == null
                            ? 0
                            : item.getQuantity();

            int newQuantity =
                    cartItem.getQuantity() == null
                            ? 1
                            : cartItem.getQuantity();

            item.setQuantity(oldQuantity + newQuantity);

            return cartItemRepository.save(item);
        }

        return cartItemRepository.save(cartItem);
    }

    // ============================================================
    // UPDATE QUANTITY
    // ============================================================

    @PutMapping("/{id}")
    public CartItem updateQuantity(
            @PathVariable Long id,
            @RequestBody CartItem cartItem) {

        CartItem existingItem =
                cartItemRepository.findById(id)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Cart item not found with id: " + id
                                )
                        );

        existingItem.setQuantity(
                cartItem.getQuantity()
        );

        return cartItemRepository.save(existingItem);
    }

    // ============================================================
    // REMOVE ITEM
    // ============================================================

    @DeleteMapping("/{id}")
    public void removeFromCart(
            @PathVariable Long id) {

        cartItemRepository.deleteById(id);
    }

    // ============================================================
    // CLEAR CART
    // ============================================================

    @DeleteMapping("/clear/{cartKey}")
    public void clearCart(
            @PathVariable String cartKey) {

        cartItemRepository.deleteByCartKey(cartKey);
    }
}

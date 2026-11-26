package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.Order;
import com.sangam.sangamdairybackend.repository.OrderRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class OrderController {

    private final OrderRepository orderRepository;

    public OrderController(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    @GetMapping
    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrderById(@PathVariable String id) {
        return orderRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/customer/{phone}")
    public List<Order> getOrdersByCustomerPhone(@PathVariable String phone) {
        return orderRepository.findByCustomerPhone(phone);
    }

    @PostMapping
    public Order createOrder(@RequestBody Order order) {
        if (order.getId() == null || order.getId().trim().isEmpty()) {
            order.setId("ORD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        }
        if (order.getCreatedAt() == null) {
            order.setCreatedAt(LocalDateTime.now());
        }
        if (order.getStatus() == null || order.getStatus().trim().isEmpty()) {
            order.setStatus("PLACED");
        }
        if (order.getPaymentStatus() == null || order.getPaymentStatus().trim().isEmpty()) {
            order.setPaymentStatus("PENDING");
        }
        return orderRepository.save(order);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Order> updateOrderStatus(
            @PathVariable String id,
            @RequestBody(required = false) Map<String, String> body,
            @RequestParam(required = false) String status
    ) {
        String newStatus = null;
        if (body != null && body.containsKey("status")) {
            newStatus = body.get("status");
        } else if (status != null && !status.trim().isEmpty()) {
            newStatus = status;
        }

        final String statusToSet = newStatus;
        if (statusToSet == null) {
            return ResponseEntity.badRequest().build();
        }

        return orderRepository.findById(id)
                .map(existingOrder -> {
                    existingOrder.setStatus(statusToSet);
                    return ResponseEntity.ok(orderRepository.save(existingOrder));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Order> updateOrder(@PathVariable String id, @RequestBody Order updatedOrder) {
        return orderRepository.findById(id)
                .map(existingOrder -> {
                    if (updatedOrder.getCustomerName() != null) existingOrder.setCustomerName(updatedOrder.getCustomerName());
                    if (updatedOrder.getCustomerPhone() != null) existingOrder.setCustomerPhone(updatedOrder.getCustomerPhone());
                    if (updatedOrder.getDeliveryAddress() != null) existingOrder.setDeliveryAddress(updatedOrder.getDeliveryAddress());
                    if (updatedOrder.getTotalAmount() != null) existingOrder.setTotalAmount(updatedOrder.getTotalAmount());
                    if (updatedOrder.getStatus() != null) existingOrder.setStatus(updatedOrder.getStatus());
                    if (updatedOrder.getPaymentStatus() != null) existingOrder.setPaymentStatus(updatedOrder.getPaymentStatus());
                    if (updatedOrder.getPaymentMethod() != null) existingOrder.setPaymentMethod(updatedOrder.getPaymentMethod());
                    if (updatedOrder.getTransactionId() != null) existingOrder.setTransactionId(updatedOrder.getTransactionId());
                    return ResponseEntity.ok(orderRepository.save(existingOrder));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}

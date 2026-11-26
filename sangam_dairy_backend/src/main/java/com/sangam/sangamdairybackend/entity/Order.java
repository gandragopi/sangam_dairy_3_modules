package com.sangam.sangamdairybackend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@SuppressWarnings("all")
@Entity
@Table(name = "orders")
public class Order {

    @Id
    private String id;

    private String customerName;
    private String customerPhone;
    private String deliveryAddress;
    private Double totalAmount;
    private String status;
    private String paymentStatus;
    private String paymentMethod;
    private String transactionId;
    private LocalDateTime createdAt;

    public Order() {
    }

    @PrePersist
    public void ensureIdAndCreatedAt() {
        if (this.id == null || this.id.trim().isEmpty()) {
            this.id = "ORD-" + System.currentTimeMillis();
        }
        if (this.createdAt == null) {
            this.createdAt = LocalDateTime.now();
        }
        if (this.status == null || this.status.trim().isEmpty()) {
            this.status = "PLACED";
        }
        if (this.paymentStatus == null || this.paymentStatus.trim().isEmpty()) {
            this.paymentStatus = "PENDING";
        }
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public String getDeliveryAddress() {
        return deliveryAddress;
    }

    public void setDeliveryAddress(String deliveryAddress) {
        this.deliveryAddress = deliveryAddress;
    }

    public Double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(Double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    // Helper compatibility methods
    public String getPhone() {
        return customerPhone;
    }

    public void setPhone(String phone) {
        this.customerPhone = phone;
    }

    public String getAddress() {
        return deliveryAddress;
    }

    public void setAddress(String address) {
        this.deliveryAddress = address;
    }

    public String getOrderKey() {
        return customerPhone != null ? customerPhone : id;
    }

    public void setOrderKey(String orderKey) {
        if (this.customerPhone == null) {
            this.customerPhone = orderKey;
        }
    }

    public LocalDateTime getOrderDate() {
        return createdAt;
    }

    public void setOrderDate(LocalDateTime orderDate) {
        this.createdAt = orderDate;
    }
}

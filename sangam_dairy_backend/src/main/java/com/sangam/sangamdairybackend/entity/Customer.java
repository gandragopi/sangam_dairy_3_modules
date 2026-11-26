package com.sangam.sangamdairybackend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@SuppressWarnings("all")
@Entity
@Table(name = "customers")
public class Customer {

    @Id
    private String id;

    private String name;
    private String email;

    @Column(nullable = false, unique = true)
    private String phone;

    private String city;
    private Integer totalOrders = 0;
    private Double totalSpent = 0.0;
    private LocalDateTime joinedDate = LocalDateTime.now();
    private Boolean active = true;

    private String password;

    public Customer() {
    }

    @PrePersist
    public void prePersist() {
        if (this.id == null || this.id.trim().isEmpty()) {
            this.id = "CUST-" + java.util.UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        }
        if (this.joinedDate == null) {
            this.joinedDate = LocalDateTime.now();
        }
        if (this.active == null) {
            this.active = true;
        }
        if (this.totalOrders == null) {
            this.totalOrders = 0;
        }
        if (this.totalSpent == null) {
            this.totalSpent = 0.0;
        }
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public Integer getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(Integer totalOrders) {
        this.totalOrders = totalOrders;
    }

    public Double getTotalSpent() {
        return totalSpent;
    }

    public void setTotalSpent(Double totalSpent) {
        this.totalSpent = totalSpent;
    }

    public LocalDateTime getJoinedDate() {
        return joinedDate;
    }

    public void setJoinedDate(LocalDateTime joinedDate) {
        this.joinedDate = joinedDate;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }

    public boolean isActive() {
        return active != null ? active : true;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public LocalDateTime getCreatedAt() {
        return joinedDate;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.joinedDate = createdAt;
    }
}

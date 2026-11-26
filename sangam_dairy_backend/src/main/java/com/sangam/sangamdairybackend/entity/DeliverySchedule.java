package com.sangam.sangamdairybackend.entity;

import jakarta.persistence.*;
import java.time.LocalDate;

@SuppressWarnings("all")
@Entity
@Table(name = "delivery_schedules")
public class DeliverySchedule {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String customerKey;

    @Column(nullable = false)
    private LocalDate deliveryDate;

    @Column(nullable = false)
    private String itemName;

    @Column(nullable = false)
    private int quantity;

    @Column(nullable = false)
    private String status; // SCHEDULED, DELIVERED, SKIPPED

    public DeliverySchedule() {}

    public Long getId() { return id; }
    public String getCustomerKey() { return customerKey; } public void setCustomerKey(String v) { customerKey = v; }
    public LocalDate getDeliveryDate() { return deliveryDate; } public void setDeliveryDate(LocalDate v) { deliveryDate = v; }
    public String getItemName() { return itemName; } public void setItemName(String v) { itemName = v; }
    public int getQuantity() { return quantity; } public void setQuantity(int v) { quantity = v; }
    public String getStatus() { return status; } public void setStatus(String v) { status = v; }
}

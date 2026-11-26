package com.sangam.sangamdairybackend.entity;

import jakarta.persistence.*;

@SuppressWarnings("all")
@Entity
@Table(name = "addresses")
public class Address {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String customerKey;

    @Column(nullable = false)
    private String fullName;

    @Column(nullable = false)
    private String phone;

    @Column(nullable = false, length = 500)
    private String addressLine;

    private String city;
    private String pincode;
    private boolean defaultAddress = false;

    public Address() {}

    public Long getId() { return id; }
    public String getCustomerKey() { return customerKey; } public void setCustomerKey(String v) { customerKey = v; }
    public String getFullName() { return fullName; } public void setFullName(String v) { fullName = v; }
    public String getPhone() { return phone; } public void setPhone(String v) { phone = v; }
    public String getAddressLine() { return addressLine; } public void setAddressLine(String v) { addressLine = v; }
    public String getCity() { return city; } public void setCity(String v) { city = v; }
    public String getPincode() { return pincode; } public void setPincode(String v) { pincode = v; }
    public boolean isDefaultAddress() { return defaultAddress; } public void setDefaultAddress(boolean v) { defaultAddress = v; }
}

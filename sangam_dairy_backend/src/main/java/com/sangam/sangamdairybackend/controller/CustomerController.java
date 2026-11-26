package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.Customer;
import com.sangam.sangamdairybackend.repository.CustomerRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/customers")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class CustomerController {

    private final CustomerRepository customerRepository;

    public CustomerController(CustomerRepository customerRepository) {
        this.customerRepository = customerRepository;
    }

    @GetMapping
    public List<Customer> getAllCustomers() {
        return customerRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Customer> getCustomerById(@PathVariable String id) {
        return customerRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Customer createCustomer(@RequestBody Customer customer) {
        if (customer.getId() == null || customer.getId().trim().isEmpty()) {
            customer.setId("CUST-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        }
        if (customer.getJoinedDate() == null) {
            customer.setJoinedDate(LocalDateTime.now());
        }
        if (customer.getActive() == null) {
            customer.setActive(true);
        }
        if (customer.getTotalOrders() == null) {
            customer.setTotalOrders(0);
        }
        if (customer.getTotalSpent() == null) {
            customer.setTotalSpent(0.0);
        }
        return customerRepository.save(customer);
    }
}

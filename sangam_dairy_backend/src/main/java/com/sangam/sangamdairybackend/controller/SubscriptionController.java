package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.Subscription;
import com.sangam.sangamdairybackend.repository.SubscriptionRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/subscriptions")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class SubscriptionController {

    private final SubscriptionRepository subscriptionRepository;

    public SubscriptionController(SubscriptionRepository subscriptionRepository) {
        this.subscriptionRepository = subscriptionRepository;
    }

    @GetMapping
    public List<Subscription> getSubscriptions(@RequestParam(required = false) String customerKey) {
        if (customerKey == null || customerKey.trim().isEmpty()) {
            return List.of();
        }
        return subscriptionRepository.findByCustomerKey(customerKey.trim());
    }

    @PostMapping
    public Subscription createSubscription(@RequestBody Subscription subscription) {
        return subscriptionRepository.save(subscription);
    }

    @DeleteMapping("/{id}")
    public void cancelSubscription(@PathVariable Long id) {
        subscriptionRepository.deleteById(id);
    }
}

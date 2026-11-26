package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.DeliverySchedule;
import com.sangam.sangamdairybackend.repository.DeliveryScheduleRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/deliveries")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class DeliveryController {

    private final DeliveryScheduleRepository deliveryScheduleRepository;

    public DeliveryController(DeliveryScheduleRepository deliveryScheduleRepository) {
        this.deliveryScheduleRepository = deliveryScheduleRepository;
    }

    @GetMapping
    public List<DeliverySchedule> getDeliveries(@RequestParam(required = false) String customerKey) {
        if (customerKey == null || customerKey.trim().isEmpty()) {
            return List.of();
        }
        return deliveryScheduleRepository.findByCustomerKey(customerKey.trim());
    }

    @PostMapping
    public DeliverySchedule scheduleDelivery(@RequestBody DeliverySchedule schedule) {
        return deliveryScheduleRepository.save(schedule);
    }
}

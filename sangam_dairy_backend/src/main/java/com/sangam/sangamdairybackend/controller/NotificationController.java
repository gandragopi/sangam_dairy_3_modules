package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.Notification;
import com.sangam.sangamdairybackend.repository.NotificationRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class NotificationController {

    private final NotificationRepository notificationRepository;

    public NotificationController(NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    @GetMapping
    public List<Notification> getNotifications(@RequestParam(required = false) String customerKey) {
        if (customerKey == null || customerKey.trim().isEmpty()) {
            return List.of();
        }
        return notificationRepository.findByCustomerKey(customerKey.trim());
    }

    @PostMapping
    public Notification createNotification(@RequestBody Notification notification) {
        return notificationRepository.save(notification);
    }

    @DeleteMapping("/{id}")
    public void deleteNotification(@PathVariable Long id) {
        notificationRepository.deleteById(id);
    }
}

package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.Banner;
import com.sangam.sangamdairybackend.repository.BannerRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/banners")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class BannerController {

    private final BannerRepository bannerRepository;

    public BannerController(BannerRepository bannerRepository) {
        this.bannerRepository = bannerRepository;
    }

    @GetMapping
    public List<Banner> getAllBanners() {
        return bannerRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Banner> getBannerById(@PathVariable String id) {
        return bannerRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Banner createBanner(@RequestBody Banner banner) {
        if (banner.getId() == null || banner.getId().trim().isEmpty()) {
            banner.setId("BAN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        }
        if (banner.getActive() == null) {
            banner.setActive(true);
        }
        return bannerRepository.save(banner);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBanner(@PathVariable String id) {
        if (bannerRepository.existsById(id)) {
            bannerRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}

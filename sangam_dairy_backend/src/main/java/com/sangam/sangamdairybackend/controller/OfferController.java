package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.Offer;
import com.sangam.sangamdairybackend.repository.OfferRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/offers")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class OfferController {

    private final OfferRepository offerRepository;

    public OfferController(OfferRepository offerRepository) {
        this.offerRepository = offerRepository;
    }

    @GetMapping
    public List<Offer> getAllOffers() {
        return offerRepository.findAll();
    }

    @PostMapping
    public Offer createOffer(@RequestBody Offer offer) {
        return offerRepository.save(offer);
    }

    @GetMapping("/verify/{code}")
    public Offer verifyOffer(@PathVariable String code) {
        return offerRepository.findByCode(code).orElseThrow(() -> new RuntimeException("Invalid offer code"));
    }
}

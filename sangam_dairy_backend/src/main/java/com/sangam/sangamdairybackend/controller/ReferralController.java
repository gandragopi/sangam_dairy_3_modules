package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.Referral;
import com.sangam.sangamdairybackend.repository.ReferralRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/referrals")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class ReferralController {

    private final ReferralRepository referralRepository;

    public ReferralController(ReferralRepository referralRepository) {
        this.referralRepository = referralRepository;
    }

    @GetMapping
    public List<Referral> getReferrals(@RequestParam(required = false) String referrerKey) {
        if (referrerKey == null || referrerKey.trim().isEmpty()) {
            return List.of();
        }
        return referralRepository.findByReferrerKey(referrerKey.trim());
    }

    @PostMapping
    public Referral createReferral(@RequestBody Referral referral) {
        return referralRepository.save(referral);
    }
}

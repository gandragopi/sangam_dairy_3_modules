package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.WalletTransaction;
import com.sangam.sangamdairybackend.repository.WalletTransactionRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/wallet")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class WalletController {

    private final WalletTransactionRepository walletTransactionRepository;

    public WalletController(WalletTransactionRepository walletTransactionRepository) {
        this.walletTransactionRepository = walletTransactionRepository;
    }

    @GetMapping
    public List<WalletTransaction> getTransactions(@RequestParam(required = false) String customerKey) {
        if (customerKey == null || customerKey.trim().isEmpty()) {
            return List.of();
        }
        return walletTransactionRepository.findByCustomerKey(customerKey.trim());
    }

    @PostMapping
    public WalletTransaction addTransaction(@RequestBody WalletTransaction transaction) {
        return walletTransactionRepository.save(transaction);
    }
}

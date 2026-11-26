package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.Address;
import com.sangam.sangamdairybackend.repository.AddressRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/addresses")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class ProfileController {

    private final AddressRepository addressRepository;

    public ProfileController(AddressRepository addressRepository) {
        this.addressRepository = addressRepository;
    }

    @GetMapping
    public List<Address> getAddresses(@RequestParam(required = false) String customerKey) {
        if (customerKey == null || customerKey.trim().isEmpty()) {
            return List.of();
        }
        return addressRepository.findByCustomerKey(customerKey.trim());
    }

    @PostMapping
    public Address addAddress(@RequestBody Address address) {
        return addressRepository.save(address);
    }

    @DeleteMapping("/{id}")
    public void deleteAddress(@PathVariable Long id) {
        addressRepository.deleteById(id);
    }
}

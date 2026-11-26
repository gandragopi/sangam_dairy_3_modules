package com.sangam.sangamdairybackend.repository;

import com.sangam.sangamdairybackend.entity.Banner;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

@SuppressWarnings("all")
public interface BannerRepository extends JpaRepository<Banner, String> {
    List<Banner> findByActiveTrue();
}

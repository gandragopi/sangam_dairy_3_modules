package com.sangam.sangamdairybackend.entity;

import jakarta.persistence.*;

@SuppressWarnings("all")
@Entity
@Table(name = "banners")
public class Banner {

    @Id
    private String id;

    private String title;
    private String subtitle;
    private String tag;
    private String imageUrl;
    private Boolean active = true;

    public Banner() {
    }

    @PrePersist
    public void prePersist() {
        if (this.id == null || this.id.trim().isEmpty()) {
            this.id = "BAN-" + java.util.UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        }
        if (this.active == null) {
            this.active = true;
        }
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getSubtitle() {
        return subtitle;
    }

    public void setSubtitle(String subtitle) {
        this.subtitle = subtitle;
    }

    public String getTag() {
        return tag;
    }

    public void setTag(String tag) {
        this.tag = tag;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }
}

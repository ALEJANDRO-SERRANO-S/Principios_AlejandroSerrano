package com.ajedrez.api.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Entity
@Table(name = "champions")
public class Champion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(nullable = false, length = 120)
    private String name;

    @NotBlank
    @Column(nullable = false, length = 120)
    private String birthCountry;

    @NotBlank
    @Column(nullable = false, length = 120)
    private String representedCountry;

    @Min(0)
    @Column(nullable = false)
    private int ageAtFirstWin;

    @NotBlank
    @Column(nullable = false, length = 120)
    private String period;

    @Size(max = 1000)
    @Column(length = 1000)
    private String imageUrl;

    @Size(max = 1000)
    @Column(length = 1000)
    private String bio;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "posted_by", referencedColumnName = "id")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private User postedBy;

    public Champion() {}

    public Champion(String name, String birthCountry, String representedCountry,
                    int ageAtFirstWin, String period, String imageUrl, String bio) {
        this.name = name;
        this.birthCountry = birthCountry;
        this.representedCountry = representedCountry;
        this.ageAtFirstWin = ageAtFirstWin;
        this.period = period;
        this.imageUrl = imageUrl;
        this.bio = bio;
    }

    // --- GETTERS Y SETTERS ---
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getBirthCountry() { return birthCountry; }
    public void setBirthCountry(String birthCountry) { this.birthCountry = birthCountry; }

    public String getRepresentedCountry() { return representedCountry; }
    public void setRepresentedCountry(String representedCountry) { this.representedCountry = representedCountry; }

    public int getAgeAtFirstWin() { return ageAtFirstWin; }
    public void setAgeAtFirstWin(int ageAtFirstWin) { this.ageAtFirstWin = ageAtFirstWin; }

    public String getPeriod() { return period; }
    public void setPeriod(String period) { this.period = period; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public User getPostedBy() { return postedBy; }
    public void setPostedBy(User postedBy) { this.postedBy = postedBy; }
}
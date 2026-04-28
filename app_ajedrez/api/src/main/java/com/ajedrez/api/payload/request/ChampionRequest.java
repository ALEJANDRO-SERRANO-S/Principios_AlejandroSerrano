package com.ajedrez.api.payload.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ChampionRequest(
        @NotBlank @Size(max = 120) String name,
        @NotBlank @Size(max = 120) String birthCountry,
        @NotBlank @Size(max = 120) String representedCountry,
        @Min(0) @Max(150) int ageAtFirstWin,
        @NotBlank @Size(max = 120) String period,
        @Size(max = 1000) String imageUrl,
        @Size(max = 1000) String bio) {
}


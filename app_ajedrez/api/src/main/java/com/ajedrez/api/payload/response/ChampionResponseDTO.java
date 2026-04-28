package com.ajedrez.api.payload.response;

public record ChampionResponseDTO(
        Long id,
        String name,
        String birthCountry,
        String representedCountry,
        int ageAtFirstWin,
        String period,
        String imageUrl,
        String bio,
        UserResponseDTO postedBy) {
}


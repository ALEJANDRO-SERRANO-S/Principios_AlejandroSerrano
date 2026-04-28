package com.ajedrez.api.services;

import org.springframework.stereotype.Component;

import com.ajedrez.api.models.Champion;
import com.ajedrez.api.models.User;
import com.ajedrez.api.payload.request.ChampionRequest;
import com.ajedrez.api.payload.response.ChampionResponseDTO;
import com.ajedrez.api.payload.response.UserResponseDTO;

@Component
public class ChampionMapper {

    public Champion toEntity(ChampionRequest request) {
        Champion champion = new Champion();
        apply(request, champion);
        return champion;
    }

    public void apply(ChampionRequest request, Champion champion) {
        champion.setName(request.name());
        champion.setBirthCountry(request.birthCountry());
        champion.setRepresentedCountry(request.representedCountry());
        champion.setAgeAtFirstWin(request.ageAtFirstWin());
        champion.setPeriod(request.period());
        champion.setImageUrl(request.imageUrl());
        champion.setBio(request.bio());
    }

    public ChampionResponseDTO toResponse(Champion champion) {
        return new ChampionResponseDTO(
                champion.getId(),
                champion.getName(),
                champion.getBirthCountry(),
                champion.getRepresentedCountry(),
                champion.getAgeAtFirstWin(),
                champion.getPeriod(),
                champion.getImageUrl(),
                champion.getBio(),
                toUserResponse(champion.getPostedBy()));
    }

    private UserResponseDTO toUserResponse(User user) {
        if (user == null) {
            return null;
        }
        return new UserResponseDTO(user);
    }
}



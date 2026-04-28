package com.ajedrez.api.controllers;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

import com.ajedrez.api.payload.request.ChampionRequest;
import com.ajedrez.api.payload.response.ChampionResponseDTO;
import com.ajedrez.api.payload.response.MessageResponse;
import com.ajedrez.api.security.services.UserDetailsImpl;
import com.ajedrez.api.services.ChampionService;

@RestController
@RequestMapping("/api/champions")
@CrossOrigin(origins = "*")
public class ChampionController {

    private final ChampionService championService;

    public ChampionController(ChampionService championService) {
        this.championService = championService;
    }

    @GetMapping
    public ResponseEntity<List<ChampionResponseDTO>> getAllChampions() {
        return ResponseEntity.ok(championService.findAll());
    }

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ChampionResponseDTO> createChampion(@Valid @RequestBody ChampionRequest champion,
                                                              @AuthenticationPrincipal UserDetailsImpl userDetails) {
        ChampionResponseDTO createdChampion = championService.create(champion, userDetails.getUsername());
        return ResponseEntity.status(HttpStatus.CREATED).body(createdChampion);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<MessageResponse> deleteChampion(@PathVariable Long id,
                                                          @AuthenticationPrincipal UserDetailsImpl userDetails) {
        championService.delete(id, userDetails.getUsername());
        return ResponseEntity.ok(new MessageResponse("Champion deleted successfully"));
    }

    @PutMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ChampionResponseDTO> updateChampion(@PathVariable Long id,
                                                              @Valid @RequestBody ChampionRequest details,
                                                              @AuthenticationPrincipal UserDetailsImpl userDetails) {
        return ResponseEntity.ok(championService.update(id, details, userDetails.getUsername()));
    }
}
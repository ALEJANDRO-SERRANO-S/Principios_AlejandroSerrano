package com.ajedrez.api.services;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ajedrez.api.exception.ForbiddenOperationException;
import com.ajedrez.api.exception.ResourceNotFoundException;
import com.ajedrez.api.models.Champion;
import com.ajedrez.api.models.ERole;
import com.ajedrez.api.models.Role;
import com.ajedrez.api.models.User;
import com.ajedrez.api.payload.request.ChampionRequest;
import com.ajedrez.api.payload.response.ChampionResponseDTO;
import com.ajedrez.api.repository.ChampionRepository;
import com.ajedrez.api.repository.UserRepository;

@Service
@Transactional
public class ChampionService {

    private final ChampionRepository championRepository;
    private final UserRepository userRepository;
    private final ChampionMapper championMapper;

    public ChampionService(ChampionRepository championRepository,
                           UserRepository userRepository,
                           ChampionMapper championMapper) {
        this.championRepository = championRepository;
        this.userRepository = userRepository;
        this.championMapper = championMapper;
    }

    @Transactional(readOnly = true)
    public List<ChampionResponseDTO> findAll() {
        return championRepository.findAll().stream()
                .map(championMapper::toResponse)
                .toList();
    }

    public ChampionResponseDTO create(ChampionRequest request, String username) {
        User currentUser = getCurrentUser(username);
        Champion champion = championMapper.toEntity(request);
        champion.setPostedBy(currentUser);
        return championMapper.toResponse(championRepository.save(champion));
    }

    public ChampionResponseDTO update(Long id, ChampionRequest request, String username) {
        Champion champion = getChampionOrThrow(id);
        User currentUser = getCurrentUser(username);
        assertOwnershipOrAdmin(champion, currentUser);
        championMapper.apply(request, champion);
        return championMapper.toResponse(championRepository.save(champion));
    }

    public void delete(Long id, String username) {
        Champion champion = getChampionOrThrow(id);
        User currentUser = getCurrentUser(username);
        assertOwnershipOrAdmin(champion, currentUser);
        championRepository.delete(champion);
    }

    private Champion getChampionOrThrow(Long id) {
        return championRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Champion not found with id: " + id));
    }

    private User getCurrentUser(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with username: " + username));
    }

    private void assertOwnershipOrAdmin(Champion champion, User currentUser) {
        boolean isAdmin = currentUser.getRoles().stream()
                .map(Role::getName)
                .anyMatch(ERole.ROLE_ADMIN::equals);

        boolean isOwner = champion.getPostedBy() != null
                && champion.getPostedBy().getUsername().equals(currentUser.getUsername());

        if (!isAdmin && !isOwner) {
            throw new ForbiddenOperationException("You do not have permission to modify this champion.");
        }
    }
}


package com.ajedrez.api.services;

import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ajedrez.api.exception.DuplicateResourceException;
import com.ajedrez.api.models.ERole;
import com.ajedrez.api.models.Role;
import com.ajedrez.api.models.User;
import com.ajedrez.api.payload.request.LoginRequest;
import com.ajedrez.api.payload.request.SignupRequest;
import com.ajedrez.api.payload.response.JwtResponse;
import com.ajedrez.api.payload.response.MessageResponse;
import com.ajedrez.api.repository.RoleRepository;
import com.ajedrez.api.repository.UserRepository;
import com.ajedrez.api.security.jwt.JwtUtils;
import com.ajedrez.api.security.services.UserDetailsImpl;

@Service
@Transactional
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;

    public AuthService(AuthenticationManager authenticationManager,
                       UserRepository userRepository,
                       RoleRepository roleRepository,
                       PasswordEncoder passwordEncoder,
                       JwtUtils jwtUtils) {
        this.authenticationManager = authenticationManager;
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtils = jwtUtils;
    }

    public JwtResponse authenticate(LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getUsername(), loginRequest.getPassword()));

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateJwtToken(authentication);

        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        List<String> roles = userDetails.getAuthorities().stream()
                .map(authority -> authority.getAuthority())
                .collect(Collectors.toList());

        return new JwtResponse(jwt, userDetails.getId(), userDetails.getUsername(), userDetails.getEmail(), roles);
    }

    public MessageResponse register(SignupRequest signUpRequest) {
        if (Boolean.TRUE.equals(userRepository.existsByUsername(signUpRequest.getUsername()))) {
            throw new DuplicateResourceException("Username is already in use.");
        }

        if (Boolean.TRUE.equals(userRepository.existsByEmail(signUpRequest.getEmail()))) {
            throw new DuplicateResourceException("Email is already in use.");
        }

        User user = new User(signUpRequest.getUsername(), signUpRequest.getEmail(),
                passwordEncoder.encode(signUpRequest.getPassword()));
        user.setRoles(resolveRoles(signUpRequest.getRole()));
        userRepository.save(user);

        return new MessageResponse("User registered successfully.");
    }

    private Set<Role> resolveRoles(Set<String> requestedRoles) {
        Set<Role> roles = new HashSet<>();

        if (requestedRoles == null || requestedRoles.isEmpty()) {
            roles.add(getRole(ERole.ROLE_USER));
            return roles;
        }

        for (String requestedRole : requestedRoles) {
            String normalizedRole = requestedRole == null ? "" : requestedRole.trim().toLowerCase(Locale.ROOT);
            switch (normalizedRole) {
                case "admin" -> roles.add(getRole(ERole.ROLE_ADMIN));
                case "moderator" -> roles.add(getRole(ERole.ROLE_MODERATOR));
                case "user" -> roles.add(getRole(ERole.ROLE_USER));
                default -> throw new IllegalArgumentException("Unsupported role: " + requestedRole);
            }
        }

        return roles;
    }

    private Role getRole(ERole roleName) {
        return roleRepository.findByName(roleName)
                .orElseThrow(() -> new com.ajedrez.api.exception.ResourceNotFoundException("Role not found: " + roleName));
    }
}


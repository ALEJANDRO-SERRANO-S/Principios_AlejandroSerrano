package com.ajedrez.api;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import com.ajedrez.api.models.ERole;
import com.ajedrez.api.models.Role;
import com.ajedrez.api.repository.RoleRepository;

@SpringBootApplication
public class ApiApplication {

	public static void main(String[] args) {
		SpringApplication.run(ApiApplication.class, args);
	}

	@Bean
	CommandLineRunner initRoles(RoleRepository roleRepository) {
		return args -> {
			ensureRole(roleRepository, ERole.ROLE_USER);
			ensureRole(roleRepository, ERole.ROLE_ADMIN);
			ensureRole(roleRepository, ERole.ROLE_MODERATOR);
		};
	}

	private void ensureRole(RoleRepository roleRepository, ERole roleName) {
		if (roleRepository.findByName(roleName).isEmpty()) {
			roleRepository.save(new Role(roleName));
		}
	}
}
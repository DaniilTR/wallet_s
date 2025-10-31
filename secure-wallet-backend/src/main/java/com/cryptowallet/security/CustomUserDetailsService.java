package com.cryptowallet.security;

import com.cryptowallet.repository.UserRepository;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    public CustomUserDetailsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String subject) throws UsernameNotFoundException {
        // Совместимость: пытаемся по id, если не найден — пробуем по email
        com.cryptowallet.entity.User user = userRepository.findById(subject)
                .orElseGet(() -> userRepository.findByEmail(subject)
                        .orElseThrow(() -> new UsernameNotFoundException("User not found by id/email: " + subject)));
        // username в контексте безопасности будет равен userId для совместимости с контроллерами
        return new org.springframework.security.core.userdetails.User(user.getId(), user.getPassword(), new ArrayList<>());
    }
}

#!/bin/bash

generate_security_config() {
    local package=""
    local auth_type="jwt" # jwt ou basic

    # Parse argumentos
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--package)
                package="$2"
                shift 2
                ;;
            -t|--type)
                auth_type="$2"
                shift 2
                ;;
            *)
                echo -e "${CYBER_RED}✘ Opção inválida: $1${RESET}"
                return 1
                ;;
        esac
    done

    # Validações
    if [[ -z "$package" ]]; then
        package=$(get_default_package "config")
    fi

    echo -e "${CYBER_BLUE}▶ Gerando configuração de segurança (${auth_type})...${RESET}"

    # Cria estrutura de diretórios
    local package_dir="src/main/java/${package//./\/}"
    mkdir -p "$package_dir"

    # Gera o código de configuração
    local file_path="$package_dir/SecurityConfig.java"
    
    {
        echo "package $package;"
        echo
        echo "import org.springframework.context.annotation.Bean;"
        echo "import org.springframework.context.annotation.Configuration;"
        echo "import org.springframework.security.config.annotation.web.builders.HttpSecurity;"
        echo "import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;"
        echo "import org.springframework.security.web.SecurityFilterChain;"
        echo "import org.springframework.security.config.http.SessionCreationPolicy;"
        
        if [[ "$auth_type" == "jwt" ]]; then
            echo "import org.springframework.security.authentication.AuthenticationProvider;"
            echo "import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;"
        fi
        
        echo
        echo "@Configuration"
        echo "@EnableWebSecurity"
        echo "public class SecurityConfig {"
        echo
        
        if [[ "$auth_type" == "jwt" ]]; then
            echo "    private final JwtAuthFilter jwtAuthFilter;"
            echo "    private final AuthenticationProvider authenticationProvider;"
            echo
            echo "    public SecurityConfig(JwtAuthFilter jwtAuthFilter, AuthenticationProvider authenticationProvider) {"
            echo "        this.jwtAuthFilter = jwtAuthFilter;"
            echo "        this.authenticationProvider = authenticationProvider;"
            echo "    }"
            echo
        fi
        
        echo "    @Bean"
        echo "    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {"
        echo "        http"
        echo "            .csrf(csrf -> csrf.disable())"
        echo "            .authorizeHttpRequests(auth -> auth"
        echo "                .requestMatchers(\"/api/v1/auth/**\").permitAll()"
        echo "                .anyRequest().authenticated()"
        echo "            )"
        
        if [[ "$auth_type" == "jwt" ]]; then
            echo "            .sessionManagement(session -> session"
            echo "                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)"
            echo "            )"
            echo "            .authenticationProvider(authenticationProvider)"
            echo "            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);"
        fi
        
        echo
        echo "        return http.build();"
        echo "    }"
        echo "}"
    } > "$file_path"

    # Se for JWT, gera também o filtro JWT
    if [[ "$auth_type" == "jwt" ]]; then
        generate_jwt_filter "$package"
    fi

    echo -e "${CYBER_GREEN}✔ Configuração de segurança gerada em: ${CYBER_CYAN}$file_path${RESET}"
}

generate_jwt_filter() {
    local package="$1"
    local file_path="$package_dir/JwtAuthFilter.java"

    {
        echo "package $package;"
        echo
        echo "import jakarta.servlet.FilterChain;"
        echo "import jakarta.servlet.ServletException;"
        echo "import jakarta.servlet.http.HttpServletRequest;"
        echo "import jakarta.servlet.http.HttpServletResponse;"
        echo "import org.springframework.lang.NonNull;"
        echo "import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;"
        echo "import org.springframework.security.core.context.SecurityContextHolder;"
        echo "import org.springframework.security.core.userdetails.UserDetails;"
        echo "import org.springframework.security.core.userdetails.UserDetailsService;"
        echo "import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;"
        echo "import org.springframework.stereotype.Component;"
        echo "import org.springframework.web.filter.OncePerRequestFilter;"
        echo
        echo "@Component"
        echo "public class JwtAuthFilter extends OncePerRequestFilter {"
        echo
        echo "    private final JwtService jwtService;"
        echo "    private final UserDetailsService userDetailsService;"
        echo
        echo "    public JwtAuthFilter(JwtService jwtService, UserDetailsService userDetailsService) {"
        echo "        this.jwtService = jwtService;"
        echo "        this.userDetailsService = userDetailsService;"
        echo "    }"
        echo
        echo "    @Override"
        echo "    protected void doFilterInternal("
        echo "            @NonNull HttpServletRequest request,"
        echo "            @NonNull HttpServletResponse response,"
        echo "            @NonNull FilterChain filterChain"
        echo "    ) throws ServletException, IOException {"
        echo "        final String authHeader = request.getHeader(\"Authorization\");"
        echo "        final String jwt;"
        echo "        final String userEmail;"
        echo
        echo "        if (authHeader == null || !authHeader.startsWith(\"Bearer \")) {"
        echo "            filterChain.doFilter(request, response);"
        echo "            return;"
        echo "        }"
        echo
        echo "        jwt = authHeader.substring(7);"
        echo "        userEmail = jwtService.extractUsername(jwt);"
        echo
        echo "        if (userEmail != null && SecurityContextHolder.getContext().getAuthentication() == null) {"
        echo "            UserDetails userDetails = this.userDetailsService.loadUserByUsername(userEmail);"
        echo "            if (jwtService.isTokenValid(jwt, userDetails)) {"
        echo "                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken("
        echo "                    userDetails,"
        echo "                    null,"
        echo "                    userDetails.getAuthorities()"
        echo "                );"
        echo "                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));"
        echo "                SecurityContextHolder.getContext().setAuthentication(authToken);"
        echo "            }"
        echo "        }"
        echo "        filterChain.doFilter(request, response);"
        echo "    }"
        echo "}"
    } > "$file_path"

    echo -e "${CYBER_GREEN}✔ Filtro JWT gerado em: ${CYBER_CYAN}$file_path${RESET}"
}

generate_auth_service() {
    local package="$1"
    local file_path="$package_dir/AuthenticationService.java"

    {
        echo "package $package;"
        echo
        echo "import lombok.RequiredArgsConstructor;"
        echo "import org.springframework.security.authentication.AuthenticationManager;"
        echo "import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;"
        echo "import org.springframework.security.crypto.password.PasswordEncoder;"
        echo "import org.springframework.stereotype.Service;"
        echo
        echo "@Service"
        echo "@RequiredArgsConstructor"
        echo "public class AuthenticationService {"
        echo
        echo "    private final UserRepository repository;"
        echo "    private final PasswordEncoder passwordEncoder;"
        echo "    private final JwtService jwtService;"
        echo "    private final AuthenticationManager authenticationManager;"
        echo
        echo "    public AuthenticationResponse register(RegisterRequest request) {"
        echo "        var user = User.builder()"
        echo "                .firstname(request.getFirstname())"
        echo "                .lastname(request.getLastname())"
        echo "                .email(request.getEmail())"
        echo "                .password(passwordEncoder.encode(request.getPassword()))"
        echo "                .role(Role.USER)"
        echo "                .build();"
        echo "        repository.save(user);"
        echo "        var jwtToken = jwtService.generateToken(user);"
        echo "        return AuthenticationResponse.builder()"
        echo "                .token(jwtToken)"
        echo "                .build();"
        echo "    }"
        echo
        echo "    public AuthenticationResponse authenticate(AuthenticationRequest request) {"
        echo "        authenticationManager.authenticate("
        echo "                new UsernamePasswordAuthenticationToken("
        echo "                        request.getEmail(),"
        echo "                        request.getPassword()"
        echo "                )"
        echo "        );"
        echo "        var user = repository.findByEmail(request.getEmail())"
        echo "                .orElseThrow();"
        echo "        var jwtToken = jwtService.generateToken(user);"
        echo "        return AuthenticationResponse.builder()"
        echo "                .token(jwtToken)"
        echo "                .build();"
        echo "    }"
        echo "}"
    } > "$file_path"

    echo -e "${CYBER_GREEN}✔ Serviço de autenticação gerado em: ${CYBER_CYAN}$file_path${RESET}"
}

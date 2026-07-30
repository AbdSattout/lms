package app.lms.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service
public class JwtService {

    public static final String TOKEN_TYPE_CLAIM =
            "token_type";

    @Value("${jwt.secret}")
    private String secretKey;

    public String extractUsername(String token) {
        return extractClaim(token , Claims::getSubject) ;
    }

    public AuthPrincipalType extractPrincipalType(
            String token
    ) {

        String value =
                extractClaim(
                        token,
                        claims -> claims.get(
                                TOKEN_TYPE_CLAIM,
                                String.class
                        )
                );

        return AuthPrincipalType.from(value);
    }

    public <T> T extractClaim(String token , Function<Claims ,T > claimsResolver){
        final Claims claims =extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    private Claims extractAllClaims(String token){
        return Jwts
                .parserBuilder()
                .setSigningKey(getSignKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    private Key getSignKey() {
        byte[] keyByte = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(keyByte);
    }

    public String generateToken(Map<String , Object> extraClaims , UserDetails userDetails){
        Map<String, Object> claims =
                new HashMap<>(extraClaims);

        claims.putIfAbsent(
                TOKEN_TYPE_CLAIM,
                AuthPrincipalType.USER.name()
        );

        return Jwts
                .builder()
                .setClaims(claims)
                .setSubject(userDetails.getUsername())
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + 1000L * 60 * 60 * 24 * 7))
                .signWith(getSignKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public String generateToken(UserDetails userDetails){
        return generateToken(new HashMap<>(),userDetails);
    }

    public boolean isTokenValid(String token , UserDetails userDetails){
        final String username = extractUsername(token);
        return (
                username.equals(userDetails.getUsername()) &&
                        !isTokenExpired(token) &&
                        userDetails.isEnabled() &&
                        userDetails.isAccountNonExpired() &&
                        userDetails.isAccountNonLocked() &&
                        userDetails.isCredentialsNonExpired()
        );
    }

    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    private Date extractExpiration(String token) {
        return extractClaim(token,Claims::getExpiration);
    }
}


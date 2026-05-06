package app.lms;

import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Encoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class LmsApplication {

	static void main(String[] args) {
		SpringApplication.run(LmsApplication.class, args);
		System.out.println(
				Encoders.BASE64.encode(
						Keys.secretKeyFor(SignatureAlgorithm.HS256)
								.getEncoded()
				)
		);
	}

}

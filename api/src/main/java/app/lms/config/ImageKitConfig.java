package app.lms.config;

import io.imagekit.client.ImageKitClient;
import io.imagekit.client.okhttp.ImageKitOkHttpClient;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@RequiredArgsConstructor
public class ImageKitConfig {
    private final ImageKitProperties properties;

    @Bean
    public ImageKitClient imageKitClient() {

        return ImageKitOkHttpClient.builder()
                .privateKey(properties.getPrivateKey())
                .build();
    }
}
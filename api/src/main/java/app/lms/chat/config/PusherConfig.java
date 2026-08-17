package app.lms.chat.config;

import com.google.gson.GsonBuilder;
import com.google.gson.Gson;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;
import com.pusher.rest.Pusher;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Instant;
import java.time.LocalDateTime;

@Configuration
public class PusherConfig {

    @Bean
    public Pusher pusher(
            @Value("${pusher.app-id}") String appId,
            @Value("${pusher.key}") String key,
            @Value("${pusher.secret}") String secret,
            @Value("${pusher.cluster}") String cluster
    ) {

        Pusher pusher =
                new Pusher(
                        appId,
                        key,
                        secret
                );

        pusher.setCluster(cluster);
        pusher.setGsonSerialiser(pusherGson());

        return pusher;
    }

    private static Gson pusherGson() {

        return new GsonBuilder()
                .disableHtmlEscaping()
                .registerTypeAdapter(
                        Instant.class,
                        (JsonSerializer<Instant>) (
                                value,
                                type,
                                context
                        ) -> new JsonPrimitive(
                                value.toString()
                        )
                )
                .registerTypeAdapter(
                        LocalDateTime.class,
                        (JsonSerializer<LocalDateTime>) (
                                value,
                                type,
                                context
                        ) -> new JsonPrimitive(
                                value.toString()
                        )
                )
                .create();
    }
}

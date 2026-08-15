package app.lms.chat.config;

import com.pusher.rest.Pusher;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

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

        return pusher;
    }
}
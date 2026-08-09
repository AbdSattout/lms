package app.lms.notification.config;


import java.io.IOException;
import java.io.InputStream;

@Configuration
public class FirebaseConfig {

    @PostConstruct
    public void initialize() throws IOException {

        if (!FirebaseApp.getApps().isEmpty()) {
            return;
        }

        InputStream serviceAccount =
                getClass()
                        .getClassLoader()
                        .getResourceAsStream(
                                "firebase/service-account.json"
                        );

        if (serviceAccount == null) {
            throw new IllegalStateException(
                    "Firebase service account file not found"
            );
        }

        FirebaseOptions options =
                FirebaseOptions.builder()
                        .setCredentials(
                                GoogleCredentials.fromStream(
                                        serviceAccount
                                )
                        )
                        .build();

        FirebaseApp.initializeApp(options);
    }
}
package app.lms.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

@Component
public class WebAppProperties {

    private static final String DEFAULT_BASE_URL =
            "https://lmscenter.vercel.app";

    private final String baseUrl;

    public WebAppProperties(
            @Value("${app.web-app.base-url:}")
            String baseUrl
    ) {
        this.baseUrl =
                StringUtils.hasText(baseUrl)
                        ? stripTrailingSlash(baseUrl)
                        : DEFAULT_BASE_URL;
    }

    public String baseUrl() {
        return baseUrl;
    }

    public String url(
            String path
    ) {
        return baseUrl + path;
    }

    private static String stripTrailingSlash(
            String url
    ) {
        return url.replaceAll("/+$", "");
    }
}
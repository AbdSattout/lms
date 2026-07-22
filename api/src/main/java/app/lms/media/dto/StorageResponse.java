package app.lms.media.dto;

import lombok.Builder;

@Builder
public record StorageResponse(

        long usedBytes,

        long availableBytes,

        long totalBytes,

        double usagePercentage,

        boolean unlimited

) {}

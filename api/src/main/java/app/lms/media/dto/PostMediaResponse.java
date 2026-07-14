package app.lms.media.dto;

import app.lms.media.enums.FileType;

public record PostMediaResponse(

        Long id,

        String name,

        String url,

        FileType type,

        Long courseId
) {
}

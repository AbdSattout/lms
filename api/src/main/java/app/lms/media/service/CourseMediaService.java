package app.lms.media.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.media.dto.CourseMediaResponse;
import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
import app.lms.media.exception.ImageUploadException;
import app.lms.media.mapper.CourseMediaMapper;
import app.lms.media.model.CourseMedia;
import app.lms.media.repository.CourseMediaRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class CourseMediaService {

    private final CourseMediaRepository
            courseMediaRepository;

    private final CourseAccessService
            courseAccessService;

    private final CourseMediaAccessService
            courseMediaAccessService;

    private final MediaService mediaService;

    private final CourseMediaMapper
            courseMediaMapper;

    @Transactional
    public CourseMediaResponse create(

            Long courseId,
            MultipartFile file,
            User user
    ) {

        Course course =
                courseAccessService
                        .getEditableCourse(
                                courseId,
                                user
                        );

        String mediaName =
                generateAvailableMediaName(
                        course.getId(),
                        getOriginalFileName(file)
                );

        FileType type =
                detectFileType(file);

        UploadedFile uploaded =
                mediaService.upload(
                        file,
                        "/courses/" + courseId,
                        type
                );

        CourseMedia media =
                buildMedia(
                        mediaName,
                        uploaded,
                        type,
                        course
                );

        courseMediaRepository.save(
                media
        );

        return courseMediaMapper
                .toResponse(media);
    }

    @Transactional
    public CourseMediaResponse update(

            Long mediaId,
            MultipartFile file,
            String name,
            User user
    ) {

        CourseMedia media =
                courseMediaAccessService
                        .getEditableMedia(
                                mediaId,
                                user
                        );

        if (file == null && name == null) {
            throw new BadRequestException(
                    "File or name is required"
            );
        }

        if (name != null) {

            String newName =
                    normalizeMediaName(
                            name
                    );

            if (
                    courseMediaRepository
                            .existsByCourseIdAndNameIgnoreCaseAndIdNot(
                                    media.getCourse().getId(),
                                    newName,
                                    media.getId()
                            )
            ) {
                throw new ConflictException(
                        "Media name already exists in this course"
                );
            }

            media.setName(
                    newName
            );
        }

        if (file != null) {

            String oldFileId =
                    media.getFileId();

            FileType type =
                    detectFileType(file);

            UploadedFile uploaded =
                    mediaService.upload(
                            file,
                            "/courses/" +
                                    media.getCourse().getId(),
                            type
                    );

            media.setUrl(
                    uploaded.url()
            );

            media.setFileId(
                    uploaded.fileId()
            );

            media.setType(
                    type
            );

            if (oldFileId != null) {

                try {
                    mediaService.delete(
                            oldFileId
                    );
                } catch (Exception ignored) {
                }
            }
        }

        return courseMediaMapper
                .toResponse(media);
    }

    @Transactional
    public void delete(

            Long mediaId,
            User user
    ) {

        CourseMedia media =
                courseMediaAccessService
                        .getEditableMedia(
                                mediaId,
                                user
                        );

        if (media.getFileId() != null) {

            mediaService.delete(
                    media.getFileId()
            );
        }

        courseMediaRepository.delete(
                media
        );
    }

    private String normalizeMediaName(
            String name
    ) {

        if (name == null || name.isBlank()) {
            throw new BadRequestException(
                    "Media name is required"
            );
        }

        return name.trim();
    }
    private String getOriginalFileName(
            MultipartFile file
    ) {

        if (
                file == null ||
                        file.getOriginalFilename() == null ||
                        file.getOriginalFilename().isBlank()
        ) {
            throw new ImageUploadException(
                    "File name is required"
            );
        }

        return file.getOriginalFilename()
                .trim();
    }

    private CourseMedia buildMedia(

            String name,
            UploadedFile uploaded,
            FileType type,
            Course course
    ) {

        return CourseMedia.builder()
                .name(name)
                .url(uploaded.url())
                .fileId(uploaded.fileId())
                .type(type)
                .course(course)
                .build();
    }

    public Page<CourseMediaResponse> list(

            Long courseId,
            Pageable pageable,
            User user
    ) {

        Course course =
                courseAccessService
                        .getManageableCourse(
                                courseId,
                                user
                        );

        return courseMediaRepository
                .findAllByCourseIdOrderByCreatedAtDesc(
                        course.getId(),
                        pageable
                )
                .map(
                        courseMediaMapper::toResponse
                );
    }

    public CourseMediaResponse getById(

            Long mediaId,
            User user
    ) {

        CourseMedia media =
                courseMediaAccessService
                        .getAccessibleMedia(
                                mediaId,
                                user
                        );

        return courseMediaMapper
                .toResponse(
                        media
                );
    }
    private FileType detectFileType(
            MultipartFile file
    ) {

        if (file == null) {

            throw new ImageUploadException(
                    "File is required"
            );
        }

        String contentType =
                file.getContentType();

        if (
                contentType != null
                        &&
                        contentType.startsWith(
                                "image/"
                        )
        ) {

            return FileType.IMAGE;
        }

        if (
                contentType != null
                        &&
                        contentType.startsWith(
                                "video/"
                        )
        ) {

            return FileType.VIDEO;
        }

        return FileType.FILE;
    }


    private String extractBaseName(
            String fileName
    ) {

        int dotIndex =
                fileName.lastIndexOf(".");

        if (dotIndex <= 0) {
            return fileName;
        }

        return fileName.substring(
                0,
                dotIndex
        );
    }

    private String extractExtension(
            String fileName
    ) {

        int dotIndex =
                fileName.lastIndexOf(".");

        if (dotIndex <= 0) {
            return "";
        }

        return fileName.substring(
                dotIndex
        );
    }
    private String generateAvailableMediaName(
            Long courseId,
            String originalName
    ) {

        String cleanName =
                originalName.trim();

        if (
                !courseMediaRepository
                        .existsByCourseIdAndNameIgnoreCase(
                                courseId,
                                cleanName
                        )
        ) {
            return cleanName;
        }

        String baseName =
                extractBaseName(cleanName);

        String extension =
                extractExtension(cleanName);

        int counter = 1;

        String candidate;

        do {
            candidate =
                    baseName +
                            " (" +
                            counter +
                            ")" +
                            extension;

            counter++;

        } while (
                courseMediaRepository
                        .existsByCourseIdAndNameIgnoreCase(
                                courseId,
                                candidate
                        )
        );

        return candidate;
    }
}

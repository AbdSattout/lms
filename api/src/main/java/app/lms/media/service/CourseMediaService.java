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
import app.lms.media.model.OrganizationMedia;
import app.lms.media.repository.CourseMediaRepository;
import app.lms.media.repository.OrganizationMediaRepository;
import app.lms.media.repository.PostMediaRepository;
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

    private final OrganizationMediaRepository organizationMediaRepository;

    private final PostMediaRepository postMediaRepository;

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
                        course.getOrganization().getId(),
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
                        file.getSize(),
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

            Long courseId,
            Long mediaId,
            MultipartFile file,
            String name,
            User user
    ) {

        CourseMedia media =
                courseMediaAccessService
                        .getEditableMedia(
                                courseId,
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
                    media.getOrganizationMedia() != null &&
                            organizationMediaRepository
                                    .existsByOrganizationIdAndNameIgnoreCaseAndIdNot(
                                            media.getCourse()
                                                    .getOrganization()
                                                    .getId(),
                                            newName,
                                            media.getOrganizationMedia()
                                                    .getId()
                                    )
            ) {
                throw new ConflictException(
                        "Media name already exists in this course"
                );
            }

            if (media.getOrganizationMedia() != null) {
                media.getOrganizationMedia()
                        .setName(newName);
            }
        }

        if (file != null) {

            String oldFileId =
                    media.getOrganizationMedia() != null
                            ? media.getOrganizationMedia().getFileId()
                            : null;

            FileType type =
                    detectFileType(file);

            UploadedFile uploaded =
                    mediaService.upload(
                            file,
                            "/courses/" +
                                    media.getCourse().getId(),
                            type
                    );

            if (media.getOrganizationMedia() != null) {
                media.getOrganizationMedia()
                        .setUrl(uploaded.url());
                media.getOrganizationMedia()
                        .setFileId(uploaded.fileId());
                media.getOrganizationMedia()
                        .setType(type);
                media.getOrganizationMedia()
                        .setSizeBytes(file.getSize());
            }

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

            Long courseId,
            Long mediaId,
            User user
    ) {

        CourseMedia media =
                courseMediaAccessService
                        .getEditableMedia(
                                courseId,
                                mediaId,
                                user
                        );

        OrganizationMedia organizationMedia =
                media.getOrganizationMedia();

        String fileId =
                organizationMedia != null
                        ? organizationMedia.getFileId()
                        : null;

        boolean removeSharedFile =
                organizationMedia != null &&
                        courseMediaRepository.countByOrganizationMediaId(
                                organizationMedia.getId()
                        ) <= 1 &&
                        postMediaRepository.countByOrganizationMediaId(
                                organizationMedia.getId()
                        ) == 0;

        if (fileId != null && removeSharedFile) {

            mediaService.delete(
                    fileId
            );
        }

        courseMediaRepository.delete(
                media
        );

        if (removeSharedFile) {
            organizationMediaRepository.delete(
                    organizationMedia
            );
        }
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
            Long sizeBytes,
            Course course
    ) {

        OrganizationMedia organizationMedia =
                organizationMediaRepository.save(
                        OrganizationMedia.builder()
                                .name(name)
                                .url(uploaded.url())
                                .fileId(uploaded.fileId())
                                .type(type)
                                .sizeBytes(sizeBytes)
                                .organization(course.getOrganization())
                                .build()
                );

        return CourseMedia.builder()
                .course(course)
                .organizationMedia(organizationMedia)
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

            Long courseId,
            Long mediaId,
            User user
    ) {

        CourseMedia media =
                courseMediaAccessService
                        .getAccessibleMedia(
                                courseId,
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
            Long organizationId,
            String originalName
    ) {

        String cleanName =
                originalName.trim();

        if (
                !organizationMediaRepository
                        .existsByOrganizationIdAndNameIgnoreCase(
                                organizationId,
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
                organizationMediaRepository
                        .existsByOrganizationIdAndNameIgnoreCase(
                                organizationId,
                                candidate
                        )
        );

        return candidate;
    }
}

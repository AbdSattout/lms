package app.lms.media.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.media.dto.PostMediaResponse;
import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
import app.lms.media.exception.ImageUploadException;
import app.lms.media.mapper.PostMediaMapper;
import app.lms.media.model.OrganizationMedia;
import app.lms.media.model.PostMedia;
import app.lms.media.repository.CourseMediaRepository;
import app.lms.media.repository.OrganizationMediaRepository;
import app.lms.media.repository.PostMediaRepository;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class DashboardPostMediaService {

    private final PostMediaRepository postMediaRepository;
    private final PostMediaAccessService postMediaAccessService;
    private final MediaService mediaService;
    private final PostMediaMapper postMediaMapper;
    private final OrganizationAccessService organizationAccessService;
    private final OrganizationMediaRepository organizationMediaRepository;
    private final CourseMediaRepository courseMediaRepository;

    @Transactional
    public PostMediaResponse create(
            String slug,
            MultipartFile file,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                slug,
                                user
                        );

        String mediaName =
                generateAvailableMediaName(
                        organization.getId(),
                        getOriginalFileName(file)
                );

        FileType type =
                detectFileType(file);

        UploadedFile uploaded =
                mediaService.upload(
                        file,
                        "/posts/" + slug,
                        type
                );

        PostMedia media =
                buildMedia(
                        mediaName,
                        uploaded,
                        type,
                        file.getSize(),
                        organization
                );

        postMediaRepository.save(media);

        return postMediaMapper.toResponse(media);
    }

    @Transactional
    public PostMediaResponse update(
            String slug,
            Long mediaId,
            MultipartFile file,
            String name,
            User user
    ) {

        PostMedia media =
                postMediaAccessService
                        .getEditableMedia(
                                slug,
                                mediaId,
                                user
                        );

        if (file == null && name == null) {
            throw new BadRequestException(
                    "File or name is required"
            );
        }

        if (name != null) {
            updateName(
                    media,
                    name
            );
        }

        if (file != null) {
            updateFile(
                    media,
                    file
            );
        }

        return postMediaMapper.toResponse(media);
    }

    @Transactional
    public void delete(
            String slug,
            Long mediaId,
            User user
    ) {

        PostMedia media =
                postMediaAccessService
                        .getEditableMedia(
                                slug,
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
                        postMediaRepository.countByOrganizationMediaId(
                                organizationMedia.getId()
                        ) <= 1 &&
                        courseMediaRepository.countByOrganizationMediaId(
                                organizationMedia.getId()
                        ) == 0;

        if (fileId != null && removeSharedFile) {
            mediaService.delete(fileId);
        }

        postMediaRepository.delete(media);

        if (removeSharedFile) {
            organizationMediaRepository.delete(organizationMedia);
        }
    }

    public PostMediaResponse getById(
            String slug,
            Long mediaId,
            User user
    ) {

        PostMedia media =
                postMediaAccessService
                        .getEditableMedia(
                                slug,
                                mediaId,
                                user
                        );

        return postMediaMapper.toResponse(media);
    }

    public Page<PostMediaResponse> list(
            String slug,
            Pageable pageable,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                slug,
                                user
                        );

        return postMediaRepository
                .findAllByOrganizationIdOrderByCreatedAtDesc(
                        organization.getId(),
                        pageable
                )
                .map(postMediaMapper::toResponse);
    }

    private void updateName(
            PostMedia media,
            String name
    ) {

        String newName =
                normalizeMediaName(name);

        if (
                media.getOrganizationMedia() != null &&
                        organizationMediaRepository
                                .existsByOrganizationIdAndNameIgnoreCaseAndIdNot(
                                        media.getOrganization().getId(),
                                        newName,
                                        media.getOrganizationMedia().getId()
                                )
        ) {
            throw new ConflictException(
                    "Media name already exists in this organization"
            );
        }

        if (media.getOrganizationMedia() != null) {
            media.getOrganizationMedia()
                    .setName(newName);
        }
    }

    private void updateFile(
            PostMedia media,
            MultipartFile file
    ) {

        String oldFileId =
                media.getOrganizationMedia() != null
                        ? media.getOrganizationMedia().getFileId()
                        : null;

        FileType type =
                detectFileType(file);

        UploadedFile uploaded =
                mediaService.upload(
                        file,
                        "/posts/" + media.getOrganization().getId(),
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
                mediaService.delete(oldFileId);
            } catch (Exception ignored) {
            }
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

        return file.getOriginalFilename().trim();
    }

    private PostMedia buildMedia(
            String name,
            UploadedFile uploaded,
            FileType type,
            Long sizeBytes,
            Organization organization
    ) {

        OrganizationMedia organizationMedia =
                organizationMediaRepository.save(
                        OrganizationMedia.builder()
                                .name(name)
                                .url(uploaded.url())
                                .fileId(uploaded.fileId())
                                .type(type)
                                .sizeBytes(sizeBytes)
                                .organization(organization)
                                .build()
                );

        return PostMedia.builder()
                .organization(organization)
                .organizationMedia(organizationMedia)
                .build();
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

        if (contentType != null && contentType.startsWith("image/")) {
            return FileType.IMAGE;
        }

        if (contentType != null && contentType.startsWith("video/")) {
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

        return fileName.substring(0, dotIndex);
    }

    private String extractExtension(
            String fileName
    ) {

        int dotIndex =
                fileName.lastIndexOf(".");

        if (dotIndex <= 0) {
            return "";
        }

        return fileName.substring(dotIndex);
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

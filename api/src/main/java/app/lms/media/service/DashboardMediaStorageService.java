package app.lms.media.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
import app.lms.media.exception.ImageUploadException;
import app.lms.media.model.OrganizationMedia;
import app.lms.media.repository.CourseMediaRepository;
import app.lms.media.repository.OrganizationMediaRepository;
import app.lms.media.repository.PostMediaRepository;
import app.lms.organization.model.Organization;
import app.lms.plan.service.PlanQuotaService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class DashboardMediaStorageService {

    private final OrganizationMediaRepository organizationMediaRepository;
    private final CourseMediaRepository courseMediaRepository;
    private final PostMediaRepository postMediaRepository;
    private final MediaService mediaService;
    private final PlanQuotaService planQuotaService;

    public OrganizationMedia upload(
            Organization organization,
            MultipartFile file,
            String folder
    ) {

        validateStorageAllowed(
                organization,
                file.getSize()
        );

        FileType type =
                detectFileType(file);

        UploadedFile uploaded =
                mediaService.upload(
                        file,
                        folder,
                        type
                );

        return organizationMediaRepository.save(
                OrganizationMedia.builder()
                        .name(
                                availableName(
                                        organization.getId(),
                                        file
                                )
                        )
                        .url(uploaded.url())
                        .fileId(uploaded.fileId())
                        .type(type)
                        .sizeBytes(file.getSize())
                        .organization(organization)
                        .build()
        );
    }

    public void replaceFile(
            Organization organization,
            OrganizationMedia media,
            MultipartFile file,
            String folder
    ) {

        String oldFileId =
                media != null
                        ? media.getFileId()
                        : null;

        validateStorageAllowed(
                organization,
                storageDelta(
                        media,
                        file
                )
        );

        FileType type =
                detectFileType(file);

        UploadedFile uploaded =
                mediaService.upload(
                        file,
                        folder,
                        type
                );

        if (media != null) {
            media.setUrl(uploaded.url());
            media.setFileId(uploaded.fileId());
            media.setType(type);
            media.setSizeBytes(file.getSize());
        }

        deleteIgnoringFailure(oldFileId);
    }

    public void rename(
            OrganizationMedia media,
            Long organizationId,
            String name,
            String conflictMessage
    ) {

        String newName =
                normalizeName(name);

        if (
                media != null &&
                        organizationMediaRepository
                                .existsByOrganizationIdAndNameIgnoreCaseAndIdNot(
                                        organizationId,
                                        newName,
                                        media.getId()
                                )
        ) {
            throw new ConflictException(
                    conflictMessage
            );
        }

        if (media != null) {
            media.setName(newName);
        }
    }

    public void validateUpdateRequest(
            MultipartFile file,
            String name
    ) {

        if (file == null && name == null) {
            throw new BadRequestException(
                    "File or name is required"
            );
        }
    }

    public void deleteCourseMediaFileIfUnused(
            OrganizationMedia media
    ) {

        if (media == null) {
            return;
        }

        boolean removeSharedFile =
                courseMediaRepository.countByOrganizationMediaId(
                        media.getId()
                ) <= 1 &&
                        postMediaRepository.countByOrganizationMediaId(
                                media.getId()
                        ) == 0;

        deleteMediaIfUnused(
                media,
                removeSharedFile
        );
    }

    public void deletePostMediaFileIfUnused(
            OrganizationMedia media
    ) {

        if (media == null) {
            return;
        }

        boolean removeSharedFile =
                postMediaRepository.countByOrganizationMediaId(
                        media.getId()
                ) <= 1 &&
                        courseMediaRepository.countByOrganizationMediaId(
                                media.getId()
                        ) == 0;

        deleteMediaIfUnused(
                media,
                removeSharedFile
        );
    }

    private String availableName(
            Long organizationId,
            MultipartFile file
    ) {

        String cleanName =
                originalFileName(file);

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
                baseName(cleanName);

        String extension =
                extension(cleanName);

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

    private String normalizeName(
            String name
    ) {

        if (name == null || name.isBlank()) {
            throw new BadRequestException(
                    "Media name is required"
            );
        }

        return name.trim();
    }

    public FileType detectFileType(
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

    private void deleteMediaIfUnused(
            OrganizationMedia media,
            boolean removeSharedFile
    ) {

        if (!removeSharedFile) {
            return;
        }

        deleteIgnoringFailure(
                media.getFileId()
        );

        organizationMediaRepository.delete(media);
    }

    private void deleteIgnoringFailure(
            String fileId
    ) {

        if (fileId == null) {
            return;
        }

        try {
            mediaService.delete(fileId);
        } catch (Exception ignored) {
        }
    }

    private void validateStorageAllowed(
            Organization organization,
            long storageDeltaBytes
    ) {

        planQuotaService.validateOrganizationStorageAllowed(
                organization.getOwner(),
                () -> organizationMediaRepository.sumSizeBytesByOrganizationId(
                        organization.getId()
                ),
                storageDeltaBytes
        );
    }

    private long storageDelta(
            OrganizationMedia media,
            MultipartFile file
    ) {

        long oldSize =
                media != null && media.getSizeBytes() != null
                        ? media.getSizeBytes()
                        : 0;

        return file.getSize() - oldSize;
    }

    private String originalFileName(
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

    private String baseName(
            String fileName
    ) {

        int dotIndex =
                fileName.lastIndexOf(".");

        if (dotIndex <= 0) {
            return fileName;
        }

        return fileName.substring(0, dotIndex);
    }

    private String extension(
            String fileName
    ) {

        int dotIndex =
                fileName.lastIndexOf(".");

        if (dotIndex <= 0) {
            return "";
        }

        return fileName.substring(dotIndex);
    }
}

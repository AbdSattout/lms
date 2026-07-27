package app.lms.media.service;

import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
import app.lms.media.exception.ImageDeleteException;
import app.lms.media.exception.ImageUploadException;
import io.imagekit.client.ImageKitClient;
import io.imagekit.models.files.FileDeleteParams;
import io.imagekit.models.files.FileUploadParams;
import io.imagekit.models.files.FileUploadResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class MediaService {

    private final ImageKitClient imageKitClient;

    private static final long MAX_IMAGE_SIZE =
            5L * 1024 * 1024;

    private static final long MAX_VIDEO_SIZE =
            100L * 1024 * 1024;

    private static final long MAX_FILE_SIZE =
            100L * 1024 * 1024;


    // UPLOAD FILE
    public UploadedFile upload(
            MultipartFile file,
            String folder,
            FileType fileType
    ) {
        validateFile(file, fileType);

        try {

            FileUploadParams params =
                    FileUploadParams.builder()
                            .file(file.getBytes())
                            .fileName(
                                    UUID.randomUUID().toString()
                            )
                            .folder(folder)
                            .useUniqueFileName(true)
                            .build();

            FileUploadResponse response =
                    imageKitClient.files().upload(params);

            return new UploadedFile(
                    response.url().orElseThrow(),
                    response.fileId().orElseThrow()
            );

        } catch (Exception e) {

            log.error(
                    "ImageKit upload failed. folder={}, fileType={}, originalFilename={}, contentType={}, size={}",
                    folder,
                    fileType,
                    file.getOriginalFilename(),
                    file.getContentType(),
                    file.getSize(),
                    e
            );

            throw new ImageUploadException(
                    "File upload failed",
                    e
            );
        }
    }

    //DELETE FILE
    public void delete(String fileId) {

        try {

            FileDeleteParams params =
                    FileDeleteParams.builder()
                            .fileId(fileId)
                            .build();

            imageKitClient.files().delete(params);

        } catch (Exception e) {

            log.error(
                    "ImageKit delete failed. fileId={}",
                    fileId,
                    e
            );

            throw new ImageDeleteException(
                    "File delete failed",
                    e
            );
        }
    }


    //VALIDATE FILE
    private void validateFile(
            MultipartFile file,
            FileType fileType
    ) {
        if (file.isEmpty()) {

            throw new ImageUploadException(
                    "File is empty"
            );
        }
        String contentType = file.getContentType();

        switch (fileType) {

            case IMAGE -> {

                if (
                        contentType == null ||
                                !contentType.startsWith("image/")
                ) {

                    throw new ImageUploadException(
                            "Invalid image type"
                    );
                }

                if (file.getSize() > MAX_IMAGE_SIZE) {

                    throw new ImageUploadException(
                            "Image size exceeded"
                    );
                }
            }

            case VIDEO -> {

                if (
                        contentType == null ||
                                !contentType.startsWith("video/")
                ) {

                    throw new ImageUploadException(
                            "Invalid video type"
                    );
                }

                if (file.getSize() > MAX_VIDEO_SIZE) {

                    throw new ImageUploadException(
                            "Video size exceeded"
                    );
                }
            }
            case FILE -> {

                if (contentType == null) {
                    throw new ImageUploadException(
                            "Invalid file type"
                    );
                }

                if (file.getSize() > MAX_FILE_SIZE) {
                    throw new ImageUploadException(
                            "File size exceeded"
                    );
                }
            }
        }
    }
}

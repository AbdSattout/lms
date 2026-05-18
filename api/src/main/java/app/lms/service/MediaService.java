package app.lms.service;

import app.lms.dto.UploadedFile;
import app.lms.enums.FileType;
import app.lms.exception.ImageDeleteException;
import app.lms.exception.ImageUploadException;
import io.imagekit.client.ImageKitClient;
import io.imagekit.models.files.FileDeleteParams;
import io.imagekit.models.files.FileUploadParams;
import io.imagekit.models.files.FileUploadResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MediaService {

    private final ImageKitClient imageKitClient;

    private static final long MAX_IMAGE_SIZE =
            5L * 1024 * 1024;

    private static final long MAX_VIDEO_SIZE =
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

            throw new ImageUploadException(
                    "File upload failed"
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

            throw new ImageDeleteException(
                    "File delete failed"
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
        }
    }
}
package app.lms.media.service;

import app.lms.common.exception.BadRequestException;
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

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
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
        return upload(
                file,
                folder,
                fileType,
                false
        );
    }

    public UploadedFile upload(
            MultipartFile file,
            String folder,
            FileType fileType,
            boolean gifAllowed
    ) {
        validateFile(
                file,
                fileType,
                gifAllowed
        );

        Path stagedFile = null;

        try {

            stagedFile =
                    stageUploadFile(file);

            try (InputStream uploadStream = Files.newInputStream(stagedFile)) {

                FileUploadParams params =
                        FileUploadParams.builder()
                                .file(uploadStream)
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
            }

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
        } finally {
            deleteStagedFile(stagedFile);
        }
    }

    private Path stageUploadFile(
            MultipartFile file
    ) throws IOException {

        Path stagedFile =
                Files.createTempFile(
                        "lms-upload-",
                        ".tmp"
                );

        try (InputStream inputStream = file.getInputStream()) {
            Files.copy(
                    inputStream,
                    stagedFile,
                    StandardCopyOption.REPLACE_EXISTING
            );

            return stagedFile;
        } catch (IOException | RuntimeException ex) {
            deleteStagedFile(stagedFile);
            throw ex;
        }
    }

    private void deleteStagedFile(
            Path stagedFile
    ) {

        if (stagedFile == null) {
            return;
        }

        try {
            Files.deleteIfExists(stagedFile);
        } catch (IOException ex) {
            log.warn(
                    "Could not delete staged upload file. path={}",
                    stagedFile,
                    ex
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
            FileType fileType,
            boolean gifAllowed
    ) {
        if (file.isEmpty()) {

            throw new BadRequestException(
                    "File is empty"
            );
        }
        String contentType = file.getContentType();

        switch (fileType) {

            case IMAGE -> {

                if (file.getSize() > MAX_IMAGE_SIZE) {

                    throw new BadRequestException(
                            "Image size exceeded"
                    );
                }

                if (!isImage(file)) {

                    throw new BadRequestException(
                            "Invalid image type"
                    );
                }

                if (!gifAllowed && isGif(file)) {

                    throw new BadRequestException(
                            "GIF uploads require premium"
                    );
                }
            }

            case VIDEO -> {

                if (
                        contentType == null ||
                                !contentType.startsWith("video/")
                ) {

                    throw new BadRequestException(
                            "Invalid video type"
                    );
                }

                if (file.getSize() > MAX_VIDEO_SIZE) {

                    throw new BadRequestException(
                            "Video size exceeded"
                    );
                }
            }
            case FILE -> {

                if (contentType == null) {
                    throw new BadRequestException(
                            "Invalid file type"
                    );
                }

                if (file.getSize() > MAX_FILE_SIZE) {
                    throw new BadRequestException(
                            "File size exceeded"
                    );
                }
            }
        }
    }

    public boolean isGif(
            MultipartFile file
    ) {

        if (file == null || file.isEmpty()) {
            return false;
        }

        return isGifHeader(
                header(
                        file,
                        6
                )
        );
    }

    public boolean isImage(
            MultipartFile file
    ) {

        byte[] header =
                header(
                        file,
                        12
                );

        return isJpeg(header)
                || isPng(header)
                || isWebp(header)
                || isGifHeader(header);
    }

    private byte[] header(
            MultipartFile file,
            int size
    ) {

        try (InputStream inputStream = file.getInputStream()) {
            return inputStream.readNBytes(size);
        } catch (IOException ex) {
            throw new ImageUploadException(
                    "File read failed",
                    ex
            );
        }
    }

    private boolean isJpeg(
            byte[] header
    ) {

        return hasBytes(
                header,
                0xFF,
                0xD8,
                0xFF
        );
    }

    private boolean isPng(
            byte[] header
    ) {

        return hasBytes(
                header,
                0x89,
                0x50,
                0x4E,
                0x47,
                0x0D,
                0x0A,
                0x1A,
                0x0A
        );
    }

    private boolean isWebp(
            byte[] header
    ) {

        return hasBytes(
                header,
                0x52,
                0x49,
                0x46,
                0x46
        )
                && header.length >= 12
                && new String(
                        header,
                        8,
                        4,
                        StandardCharsets.US_ASCII
                )
                .equals("WEBP");
    }

    private boolean isGifHeader(
            byte[] header
    ) {

        return hasBytes(
                header,
                0x47,
                0x49,
                0x46,
                0x38,
                0x37,
                0x61
        )
                || hasBytes(
                        header,
                        0x47,
                        0x49,
                        0x46,
                        0x38,
                        0x39,
                        0x61
                );
    }

    private boolean hasBytes(
            byte[] header,
            int... expected
    ) {

        if (header.length < expected.length) {
            return false;
        }

        for (int i = 0; i < expected.length; i++) {
            if ((header[i] & 0xFF) != expected[i]) {
                return false;
            }
        }

        return true;
    }
}

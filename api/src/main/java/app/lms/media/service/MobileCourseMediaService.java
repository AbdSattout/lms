package app.lms.media.service;

import app.lms.media.dto.CourseMediaResponse;
import app.lms.media.mapper.CourseMediaMapper;
import app.lms.media.model.CourseMedia;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MobileCourseMediaService {

    private final CourseMediaAccessService courseMediaAccessService;
    private final CourseMediaMapper courseMediaMapper;
    private final OrganizationAccessService organizationAccessService;

    public CourseMediaResponse getById(
            String organizationSlug,
            String courseSlug,
            Long mediaId,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getBySlug(
                                organizationSlug
                        );

        CourseMedia media =
                courseMediaAccessService
                        .getAccessibleMedia(
                                organization.getId(),
                                courseSlug,
                                mediaId,
                                user
                        );

        return courseMediaMapper.toResponse(media);
    }
}

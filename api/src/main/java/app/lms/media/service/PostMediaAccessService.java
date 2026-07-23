package app.lms.media.service;

import app.lms.common.exception.NotFoundException;
import app.lms.media.model.PostMedia;
import app.lms.media.repository.PostMediaRepository;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.organization.service.OrganizationMemberAccessService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;


@Service
@RequiredArgsConstructor
public class PostMediaAccessService {

    private final PostMediaRepository
            postMediaRepository;

    private final OrganizationAccessService
            organizationAccessService;
    private final OrganizationMemberAccessService
            organizationMemberAccessService;

    public PostMedia getById(
            Long mediaId
    ) {

        return postMediaRepository
                .findById(
                        mediaId
                )
                .orElseThrow(
                        () -> new NotFoundException(
                                "Media not found"
                        )
                );
    }

    public PostMedia getEditableMedia(
            Long organizationId,
            Long mediaId,
            User user
    ) {

        organizationAccessService
                .getManageableOrganization(
                        organizationId,
                        user
                );

        return getByIdAndOrganizationId(
                mediaId,
                organizationId
        );
    }

    public PostMedia getAccessibleMedia(
            Long organizationId,
            Long mediaId,
            User user
    ) {

        organizationAccessService
                .getById(
                        organizationId
                );

        organizationMemberAccessService
                .getMember(
                        organizationId,
                        user.getId()
                );

        return getByIdAndOrganizationId(
                mediaId,
                organizationId
        );
    }

    private PostMedia getByIdAndOrganizationId(
            Long mediaId,
            Long organizationId
    ) {

        return postMediaRepository
                .findByIdAndOrganizationId(
                        mediaId,
                        organizationId
                )
                .orElseThrow(
                        () -> new NotFoundException(
                                "Media not found"
                        )
                );
    }
}

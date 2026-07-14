package app.lms.media.service;

import app.lms.common.exception.NotFoundException;
import app.lms.media.model.PostMedia;
import app.lms.media.repository.PostMediaRepository;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.organization.service.OrganizationMemberAccessService;
import app.lms.post.service.PostAccessService;
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
            Long mediaId,
            User user
    ) {

        PostMedia media =
                getById(mediaId);

        organizationAccessService
                .getManageableOrganization(
                        media.getOrganization().getSlug(),
                        user
                );

        return media;
    }

    public PostMedia getAccessibleMedia(
            Long mediaId,
            User user
    ) {

        PostMedia media =
                getById(mediaId);

        organizationMemberAccessService
                .getMember(
                        media.getOrganization().getId(),
                        user.getId()
                );

        return media;
    }
}

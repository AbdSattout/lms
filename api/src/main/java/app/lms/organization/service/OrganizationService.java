package app.lms.organization.service;

import app.lms.organization.dto.OrganizationResponse;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OrganizationService {


    private final OrganizationRepository organizationRepository;
    private final OrganizationMapper organizationMapper;
    private final OrganizationAccessService organizationAccessService;
    private final OrganizationMemberRepository memberRepository;

    @Value("${app.search.organization-similarity-threshold:0.2}")
    private double organizationSearchSimilarityThreshold;


    public OrganizationResponse getBySlug(String slug) {

        Organization organization =
                organizationAccessService.getBySlug(slug);

        return organizationMapper.ToResponse(
                organization
        );
    }

    public List<OrganizationResponse> getAll(
            String q
    ) {

        List<Organization> organizations =
                StringUtils.hasText(q)
                        ? organizationRepository.search(
                                q.trim(),
                                organizationSearchSimilarityThreshold
                        )
                        : organizationRepository.findAll();

        return organizations
                .stream()
                .map(organizationMapper::ToResponse)
                .toList();
    }

    public List<OrganizationResponse> getMyOrganizations(
            User user
    ) {

        return memberRepository
                .findAllByUserId(user.getId())
                .stream()
                .map(OrganizationMember::getOrganization)
                .map(organizationMapper::ToResponse)
                .toList();
    }

}

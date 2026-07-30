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
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrganizationService {


    private final OrganizationRepository organizationRepository;
    private final OrganizationMapper organizationMapper;
    private final OrganizationAccessService organizationAccessService;
    private final OrganizationMemberRepository memberRepository;

    @Value("${app.search.organization-similarity-threshold:0.2}")
    private double organizationSearchSimilarityThreshold;


    public OrganizationResponse getBySlug(
            String slug,
            User user
    ) {

        Organization organization =
                organizationAccessService.getBySlug(slug);

        Optional<OrganizationMember> member =
                memberRepository.findByOrganizationIdAndUserId(
                        organization.getId(),
                        user.getId()
                );

        return organizationMapper.ToResponse(
                organization,
                member.orElse(null)
        );
    }

    public List<OrganizationResponse> getAll(
            String q,
            User user
    ) {

        List<Organization> organizations =
                StringUtils.hasText(q)
                        ? organizationRepository.search(
                                q.trim(),
                                organizationSearchSimilarityThreshold
                        )
                        : organizationRepository.findAll();

        Map<Long, OrganizationMember> membersByOrganizationId =
                membersByOrganizationId(user);

        return organizations
                .stream()
                .map(organization ->
                        organizationMapper.ToResponse(
                                organization,
                                membersByOrganizationId.get(
                                        organization.getId()
                                )
                        )
                )
                .toList();
    }

    public List<OrganizationResponse> getMyOrganizations(
            User user
    ) {

        return memberRepository
                .findAllByUserId(user.getId())
                .stream()
                .map(member ->
                        organizationMapper.ToResponse(
                                member.getOrganization(),
                                member
                        )
                )
                .toList();
    }

    private Map<Long, OrganizationMember> membersByOrganizationId(
            User user
    ) {

        return memberRepository
                .findAllByUserId(user.getId())
                .stream()
                .collect(
                        Collectors.toMap(
                                member -> member.getOrganization()
                                        .getId(),
                                Function.identity()
                        )
                );
    }

}

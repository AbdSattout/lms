package app.lms.plan.service;

import app.lms.plan.exception.PlanLimitExceededException;
import app.lms.plan.model.Plan;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.function.LongSupplier;

@Service
@RequiredArgsConstructor
public class PlanQuotaService {

    private final UserPlanService userPlanService;

    @Transactional
    public void validateActiveRoadmapFollowAllowed(
            User user,
            LongSupplier activeRoadmapFollowCount
    ) {

        Plan plan =
                userPlanService.getOrCreateCurrentPlanForUpdate(user);

        Integer limit =
                plan.getActiveRoadmapFollowLimit();

        if (isUnlimited(limit)) {
            return;
        }

        if (activeRoadmapFollowCount.getAsLong() >= limit) {
            throw new PlanLimitExceededException(
                    "Active roadmap follow limit reached"
            );
        }
    }

    @Transactional
    public void validateOrganizationCreationAllowed(
            User user,
            LongSupplier ownedOrganizationCount
    ) {

        Plan plan =
                userPlanService.getOrCreateCurrentPlanForUpdate(user);

        Integer limit =
                plan.getOrganizationLimit();

        if (isUnlimited(limit)) {
            return;
        }

        if (ownedOrganizationCount.getAsLong() >= limit) {
            throw new PlanLimitExceededException(
                    "Organization limit reached"
            );
        }
    }

    @Transactional
    public void validateOrganizationStorageAllowed(
            User planOwner,
            LongSupplier currentStorageBytes,
            long storageDeltaBytes
    ) {

        if (storageDeltaBytes <= 0) {
            return;
        }

        Plan plan =
                userPlanService.getOrCreateCurrentPlanForUpdate(planOwner);

        Long limit =
                plan.getOrganizationStorageLimitBytes();

        if (isUnlimited(limit)) {
            return;
        }

        if (currentStorageBytes.getAsLong() + storageDeltaBytes > limit) {
            throw new PlanLimitExceededException(
                    "Organization storage limit reached"
            );
        }
    }

    @Transactional
    public void validateOrganizationCourseCreationAllowed(
            User planOwner,
            LongSupplier organizationCourseCount
    ) {

        Plan plan =
                userPlanService.getOrCreateCurrentPlanForUpdate(planOwner);

        Integer limit =
                plan.getOrganizationCourseLimit();

        if (isUnlimited(limit)) {
            return;
        }

        if (organizationCourseCount.getAsLong() >= limit) {
            throw new PlanLimitExceededException(
                    "Organization course limit reached"
            );
        }
    }

    private boolean isUnlimited(
            Integer limit
    ) {

        return limit == null;
    }

    private boolean isUnlimited(
            Long limit
    ) {

        return limit == null;
    }
}

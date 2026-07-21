package app.lms.plan.aspect;

import app.lms.plan.annotation.ConsumesPlanUsage;
import app.lms.plan.service.PlanLimitService;
import app.lms.security.UserPrincipal;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.security.authentication.AuthenticationCredentialsNotFoundException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Aspect
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
@RequiredArgsConstructor
public class PlanUsageAspect {

    private final PlanLimitService planLimitService;

    @Around("@annotation(consumesPlanUsage)")
    public Object consume(
            ProceedingJoinPoint joinPoint,
            ConsumesPlanUsage consumesPlanUsage
    ) throws Throwable {

        User user =
                currentUser();

        boolean reserved =
                planLimitService.reserve(
                        user,
                        consumesPlanUsage.value()
                );

        try {
            return joinPoint.proceed();
        } catch (Throwable ex) {
            if (reserved) {
                planLimitService.release(
                        user,
                        consumesPlanUsage.value()
                );
            }

            throw ex;
        }
    }

    private User currentUser() {

        Authentication authentication =
                SecurityContextHolder.getContext()
                        .getAuthentication();

        if (
                authentication == null ||
                        !authentication.isAuthenticated()
        ) {
            throw new AuthenticationCredentialsNotFoundException(
                    "@ConsumesPlanUsage requires an authenticated user"
            );
        }

        Object principal =
                authentication.getPrincipal();

        if (principal instanceof UserPrincipal userPrincipal) {
            return userPrincipal.user();
        }

        if (principal instanceof User user) {
            return user;
        }

        throw new AuthenticationCredentialsNotFoundException(
                "@ConsumesPlanUsage requires an authenticated user"
        );
    }
}

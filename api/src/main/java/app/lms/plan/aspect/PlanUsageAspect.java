package app.lms.plan.aspect;

import app.lms.plan.annotation.ConsumesPlanUsage;
import app.lms.plan.service.PlanLimitService;
import app.lms.security.UserPrincipal;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.security.authentication.AuthenticationCredentialsNotFoundException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;

@Aspect
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
@RequiredArgsConstructor
public class PlanUsageAspect {

    private final PlanLimitService planLimitService;

    @Around("@annotation(app.lms.plan.annotation.ConsumesPlanUsage)")
    public Object consume(
            ProceedingJoinPoint joinPoint
    ) throws Throwable {

        ConsumesPlanUsage consumesPlanUsage =
                consumesPlanUsage(
                        joinPoint
                );

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

    private ConsumesPlanUsage consumesPlanUsage(
            ProceedingJoinPoint joinPoint
    ) throws NoSuchMethodException {

        MethodSignature signature =
                (MethodSignature) joinPoint.getSignature();

        Method method =
                signature.getMethod();

        ConsumesPlanUsage annotation =
                method.getAnnotation(
                        ConsumesPlanUsage.class
                );

        if (annotation != null) {
            return annotation;
        }

        Method targetMethod =
                joinPoint.getTarget()
                        .getClass()
                        .getMethod(
                                method.getName(),
                                method.getParameterTypes()
                        );

        return targetMethod.getAnnotation(
                ConsumesPlanUsage.class
        );
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

        if (principal instanceof UserPrincipal(User user1)) {
            return user1;
        }

        if (principal instanceof User user) {
            return user;
        }

        throw new AuthenticationCredentialsNotFoundException(
                "@ConsumesPlanUsage requires an authenticated user"
        );
    }
}

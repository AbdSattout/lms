package app.lms.plan.aspect;

import app.lms.plan.annotation.ConsumesPlanUsage;
import app.lms.plan.service.PlanLimitService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Arrays;

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
                extractUser(
                        joinPoint
                );

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

    private User extractUser(
            ProceedingJoinPoint joinPoint
    ) {

        return Arrays.stream(
                        joinPoint.getArgs()
                )
                .filter(User.class::isInstance)
                .map(User.class::cast)
                .findFirst()
                .orElseThrow(() ->
                        new IllegalStateException(
                                "@ConsumesPlanUsage requires a User method argument"
                        )
                );
    }
}

package app.lms.plan.annotation;

import app.lms.plan.enums.PlanUsageType;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface ConsumesPlanUsage {

    PlanUsageType value();

    int courseIdArgumentIndex() default -1;
}

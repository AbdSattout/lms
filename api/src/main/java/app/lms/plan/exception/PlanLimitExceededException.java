package app.lms.plan.exception;

public class PlanLimitExceededException extends RuntimeException {

    public PlanLimitExceededException(
            String message
    ) {
        super(message);
    }
}

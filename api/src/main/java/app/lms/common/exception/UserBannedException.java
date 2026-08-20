package app.lms.common.exception;

public class UserBannedException extends RuntimeException {

    public UserBannedException() {
        super("User is banned");
    }
}
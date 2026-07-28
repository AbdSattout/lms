package app.lms.user.repository.projection;

import app.lms.user.model.Profile;
import app.lms.user.model.User;

public interface UserSearchRow {

    User getUser();

    Profile getProfile();
}

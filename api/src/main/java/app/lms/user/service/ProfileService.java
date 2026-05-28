package app.lms.user.service;

import app.lms.user.dto.CreateProfileRequest;
import app.lms.user.dto.ProfileResponse;
import app.lms.user.dto.UpdateProfile;
import app.lms.user.mapper.UserMapper;
import app.lms.user.model.Profile;
import app.lms.user.model.User;
import app.lms.user.repository.ProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final ProfileRepository profileRepository;
    private final UserMapper userMapper;

    @Transactional
    public ProfileResponse createProfile(
            CreateProfileRequest request,
            User user
    ) {

        if( profileRepository
                .findByUserId(user.getId())
                .isPresent() )
        {
            throw new IllegalStateException("Profile already exists");
        }

        Profile profile = new Profile();

        profile.setUser(user);
        profile.setEmail(request.getEmail());
        profile.setPhone(request.getPhone());
        profile.setUniversity(request.getUniversity());

        profileRepository.save(profile);

        return userMapper.toProfileResponse(user ,profile);
    }

    public ProfileResponse getMyProfile(User user) {

        Profile profile = profileRepository
                .findByUserId(user.getId())
                .orElseThrow(() -> new UsernameNotFoundException("Profile Not Found"));

        return userMapper.toProfileResponse(user, profile);
    }

    @Transactional
    public ProfileResponse updateProfile(UpdateProfile request , User user) {


        Profile profile = profileRepository
                .findByUserId(user.getId())
                .orElseThrow(() -> new UsernameNotFoundException("Profile Not Found"));

        if (request.getEmail() != null) {
            profile.setEmail(request.getEmail());
        }

        if (request.getPhone() != null) {
            profile.setPhone(request.getPhone());
        }

        if (request.getUniversity() != null) {
            profile.setUniversity(request.getUniversity());
        }

        profileRepository.save(profile);

        return userMapper.toProfileResponse(user, profile);
    }

    @Transactional
    public void deleteProfile(User user ) {

        profileRepository.findByUserId(user.getId())
                .ifPresent(profileRepository::delete);
    }

}

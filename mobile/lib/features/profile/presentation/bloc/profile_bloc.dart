import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_account_email_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/request_account_email_otp_usecase.dart';
import '../../domain/usecases/update_profile_params.dart';
import '../../domain/usecases/update_profile_picture_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/verify_account_email_otp_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

String describeProfileError(Object error) {
  final raw = error.toString();
  if (!raw.startsWith('Instance of')) return raw;

  try {
    final dynamic e = error;
    final dynamic model = e.errorModel;
    if (model != null) {
      final dynamic msg = model.errorMessage;
      if (msg != null) return msg.toString();
    }
  } catch (_) {}

  try {
    final dynamic e = error;
    final dynamic msg = e.errorMessage;
    if (msg != null) return msg.toString();
  } catch (_) {}

  try {
    final dynamic e = error;
    final dynamic msg = e.message;
    if (msg != null) return msg.toString();
  } catch (_) {}

  return 'حدث خطأ غير متوقع، حاول مرة أخرى (${error.runtimeType})';
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final GetCurrentAccountEmailUseCase getCurrentAccountEmailUseCase;
  final UpdateProfilePictureUseCase updatePictureUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final RequestAccountEmailOtpUseCase requestAccountEmailOtpUseCase;
  final VerifyAccountEmailOtpUseCase verifyAccountEmailOtpUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.getCurrentAccountEmailUseCase,
    required this.updatePictureUseCase,
    required this.updateProfileUseCase,
    required this.requestAccountEmailOtpUseCase,
    required this.verifyAccountEmailOtpUseCase,
  }) : super(ProfileInitial()) {
    on<GetProfileEvent>(_getProfile);

    on<UpdateProfilePictureEvent>(_updatePicture);
    on<UpdateProfileEvent>(_updateProfile);

    on<RequestAccountEmailOtpEvent>(_requestAccountEmailOtp);

    on<VerifyAccountEmailOtpEvent>(_verifyAccountEmailOtp);

    on<CancelAccountEmailOtpEvent>(_cancelAccountEmailOtp);
  }

  Future<void> _getProfile(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());

      emit(await _loadProfile());
    } catch (e) {
      emit(ProfileError(describeProfileError(e)));
    }
  }

  Future<void> _updatePicture(
    UpdateProfilePictureEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await updatePictureUseCase(event.imagePath);

      emit(ProfilePictureUpdated());

      emit(await _loadProfile());
    } catch (e) {
      emit(ProfileError(describeProfileError(e)));
    }
  }

  Future<void> _updateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await updateProfileUseCase(
        UpdateProfileParams(
          email: event.email,
          phone: event.phone,
          university: event.university,
        ),
      );

      emit(ProfileUpdated());

      emit(await _loadProfile());
    } catch (e) {
      emit(ProfileError(describeProfileError(e)));
    }
  }

  Future<void> _requestAccountEmailOtp(
    RequestAccountEmailOtpEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final loaded = state is ProfileLoaded ? state as ProfileLoaded : null;
    if (loaded == null) return;

    emit(
      ProfileLoaded(
        loaded.profile,
        accountEmail: loaded.accountEmail,
        pendingAccountEmail: event.email,
        isRequestingAccountEmailOtp: true,
      ),
    );

    try {
      await requestAccountEmailOtpUseCase(event.email);

      emit(
        ProfileLoaded(
          loaded.profile,
          accountEmail: loaded.accountEmail,
          pendingAccountEmail: event.email,
          accountEmailMessage: 'تم إرسال رمز التحقق إلى البريد الإلكتروني',
        ),
      );
    } catch (e) {
      emit(
        ProfileLoaded(
          loaded.profile,
          accountEmail: loaded.accountEmail,
          accountEmailError: describeProfileError(e),
        ),
      );
    }
  }

  Future<void> _verifyAccountEmailOtp(
    VerifyAccountEmailOtpEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final loaded = state is ProfileLoaded ? state as ProfileLoaded : null;
    if (loaded == null) return;

    emit(
      ProfileLoaded(
        loaded.profile,
        accountEmail: loaded.accountEmail,
        pendingAccountEmail: event.email,
        isVerifyingAccountEmailOtp: true,
      ),
    );

    try {
      final accountEmail = await verifyAccountEmailOtpUseCase(
        email: event.email,
        otp: event.otp,
      );

      emit(
        ProfileLoaded(
          loaded.profile,
          accountEmail: accountEmail ?? event.email,
          accountEmailMessage: 'تم ربط بريد تسجيل الدخول بنجاح',
        ),
      );
    } catch (e) {
      emit(
        ProfileLoaded(
          loaded.profile,
          accountEmail: loaded.accountEmail,
          pendingAccountEmail: event.email,
          accountEmailError: describeProfileError(e),
        ),
      );
    }
  }

  void _cancelAccountEmailOtp(
    CancelAccountEmailOtpEvent event,
    Emitter<ProfileState> emit,
  ) {
    final loaded = state is ProfileLoaded ? state as ProfileLoaded : null;
    if (loaded == null) return;

    emit(ProfileLoaded(loaded.profile, accountEmail: loaded.accountEmail));
  }

  Future<ProfileLoaded> _loadProfile() async {
    final profile = await getProfileUseCase();
    final accountEmail = await getCurrentAccountEmailUseCase();

    return ProfileLoaded(profile, accountEmail: accountEmail);
  }
}

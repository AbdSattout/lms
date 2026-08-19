import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_my_certificates_usecase.dart';
import 'certificate_event.dart';
import 'certificate_state.dart';

class CertificateBloc extends Bloc<CertificateEvent, CertificateState> {
  final GetMyCertificatesUseCase getMyCertificates;

  CertificateBloc({required this.getMyCertificates}) : super(CertificateInitial()) {
    on<LoadMyCertificates>(_onLoad);
    on<RefreshMyCertificates>(_onRefresh);
  }

  Future<void> _onLoad(
      LoadMyCertificates event,
      Emitter<CertificateState> emit,
      ) async {
    emit(CertificateLoading());

    final result = await getMyCertificates();

    result.fold(
          (failure) => emit(CertificateFailed(failure.errMessage)),
          (data) {
        if (data.content.isEmpty) {
          emit(CertificateEmpty());
        } else {
          emit(CertificateLoaded(data.content));
        }
      },
    );
  }

  Future<void> _onRefresh(
      RefreshMyCertificates event,
      Emitter<CertificateState> emit,
      ) async {
    final result = await getMyCertificates();

    result.fold(
          (failure) => emit(CertificateFailed(failure.errMessage)),
          (data) {
        if (data.content.isEmpty) {
          emit(CertificateEmpty());
        } else {
          emit(CertificateLoaded(data.content));
        }
      },
    );
  }
}
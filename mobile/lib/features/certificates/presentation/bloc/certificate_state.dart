import '../../domain/entities/certificate_entity.dart';

sealed class CertificateState {}

class CertificateInitial extends CertificateState {}

class CertificateLoading extends CertificateState {}

class CertificateLoaded extends CertificateState {
  final List<CertificateEntity> certificates;
  CertificateLoaded(this.certificates);
}

class CertificateEmpty extends CertificateState {}

class CertificateFailed extends CertificateState {
  final String message;
  CertificateFailed(this.message);
}
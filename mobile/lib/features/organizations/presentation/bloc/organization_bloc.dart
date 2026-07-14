import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/get_all_organizations_usecase.dart';
import 'organization_event.dart';
import 'organization_state.dart';

class OrganizationBloc
    extends Bloc<OrganizationEvent, OrganizationState> {

  final GetAllOrganizationsUseCase getAllOrganizationsUseCase;

  OrganizationBloc({
    required this.getAllOrganizationsUseCase,
  }) : super(OrganizationInitial()) {

    on<GetAllOrganizationsEvent>(
      _getAllOrganizations,
    );
  }

  Future<void> _getAllOrganizations(
      GetAllOrganizationsEvent event,
      Emitter<OrganizationState> emit,
      ) async {
    try {
      emit(OrganizationLoading());

      final organizations =
      await getAllOrganizationsUseCase();

      emit(
        OrganizationLoaded(organizations),
      );
    } catch (e) {
      emit(
        OrganizationError(
          resolveApiErrorMessage(e),
        ),
      );
    }
  }
}
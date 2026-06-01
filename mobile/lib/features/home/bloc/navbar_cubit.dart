import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavbarCubit extends Cubit<int> {
  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }

  final PageController controller = PageController();
  NavbarCubit() : super(0);

  void update(int value) {
    emit(value);
  }
}

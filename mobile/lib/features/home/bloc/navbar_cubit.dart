import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavbarCubit extends Cubit<int> {
  final PageController controller = PageController();
  NavbarCubit() : super(0);

  void update(int value) {
    emit(value);
  }
}
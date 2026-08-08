import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<Locale> {
  static const supportedLocales = [Locale('en'), Locale('ar')];

  LocaleCubit() : super(const Locale('en'));

  void toggle() {
    final next = state.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    emit(next);
  }
}

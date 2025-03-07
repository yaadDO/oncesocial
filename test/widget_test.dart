import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oncesocial/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:oncesocial/themes/themes_cubit.dart';

class MockThemeCubit extends Mock implements ThemeCubit {}
class MockAuthCubit extends Mock implements AuthCubit {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {

}
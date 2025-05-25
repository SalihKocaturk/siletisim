import 'package:bbtproje/domain/cubits/activity_cubit.dart';
import 'package:bbtproje/domain/cubits/auth_cubit.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void setupLocators() {
  getIt.registerSingleton(AuthCubit());
  getIt.registerSingleton(ActivityCubit());
}

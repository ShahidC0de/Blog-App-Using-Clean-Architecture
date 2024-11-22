part of 'app_user_cubit.dart';

@immutable
sealed class AppUserState {}

final class AppUserInitial extends AppUserState {}

final class AppUserLoggedIn extends AppUserState {
  final User user;
  AppUserLoggedIn({required this.user});
}

// core cannot depend on any feature
// but other features can depend on core...  THATS PRINCIPLE

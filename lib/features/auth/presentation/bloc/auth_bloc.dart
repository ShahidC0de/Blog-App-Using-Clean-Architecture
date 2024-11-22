import 'package:blog_app/core/common/app_user/cubit/app_user_cubit.dart';
import 'package:blog_app/core/usecase/usecase.dart';
import 'package:blog_app/core/common/entities/user.dart';
import 'package:blog_app/features/auth/domain/usecase/current_user.dart';
import 'package:blog_app/features/auth/domain/usecase/sign_up.dart';
import 'package:blog_app/features/auth/domain/usecase/user_signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserSignIn _userSignIn;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  AuthBloc({
    required UserSignUp usersignup,
    required UserSignIn userSignIn,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
  })  : _userSignUp = usersignup,
        _userSignIn = userSignIn,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(
        AuthLoading())); // on every AuthEvent the loading state is emitted, automatically...
    // and its called refactoring.
    on<AuthSignupEvent>(_onAuthSignUp);
    on<AuthSignInEvent>(_onAuthSignIn);
    on<AuthIsUserLoggedIn>(_onCurrentUser);
  }

  void _onAuthSignUp(
    AuthSignupEvent event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _userSignUp(
      UserSignUpParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );
    res.fold(
      (l) {
        debugPrint(l.message);
        emit(AuthFailure(l.message));
      },
      (r) => onEmitAuthSuccess(r, emit),
    );
  }

  void _onCurrentUser(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _currentUser(NoParams());
    res.fold((failure) => emit(AuthFailure(failure.message)), (r) {
      debugPrint(r.email);
      debugPrint(r.name);

      return onEmitAuthSuccess(r, emit);
    });
  }

  void _onAuthSignIn(
    AuthSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _userSignIn(
      UserSignInParams(
        email: event.email,
        password: event.password,
      ),
    );
    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => onEmitAuthSuccess(user, emit),
    );
  }

  void onEmitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}

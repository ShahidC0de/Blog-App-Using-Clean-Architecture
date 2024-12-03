import 'package:blog_app/core/common/app_user/cubit/app_user_cubit.dart';
import 'package:blog_app/core/secrets/app_secrets.dart';
import 'package:blog_app/features/auth/data/auth/data_sources/auth_remote_datasource.dart';
import 'package:blog_app/features/auth/data/auth/data_sources/repositories/auth_repository_imp.dart';
import 'package:blog_app/features/auth/domain/repository/auth_repository.dart';
import 'package:blog_app/features/auth/domain/usecase/current_user.dart';
import 'package:blog_app/features/auth/domain/usecase/sign_up.dart';
import 'package:blog_app/features/auth/domain/usecase/user_signup.dart';
import 'package:blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_app/features/blog/data/models/blog_remote_datasource.dart';
import 'package:blog_app/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:blog_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:blog_app/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:blog_app/features/blog/domain/usecases/uploade_blog.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();
  final supabase = await Supabase.initialize(
    anonKey: AppSecrets.annonKey,
    url: AppSecrets.url,
  );
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerLazySingleton(() => supabase.client);
}

void _initAuth() {
  serviceLocator.registerFactory<AuthRemoteDatasource>(
    () => AuthRemoteDataSourceImpl(
      // so it requires the supaseClient, and we already registered it in initDependenies function..
      // it will automatically check what type of instance it want, and its actually wants a supaseclient,
      // so it will locate it automatically and assign it.
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImp(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => UserSignUp(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => UserSignIn(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => CurrentUser(
      authRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      usersignup: serviceLocator(),
      userSignIn: serviceLocator(),
      currentUser: serviceLocator(),
      appUserCubit: serviceLocator(),
    ),
  );
}

// note that the initDependencies function is called in main function so then it will run initAuth function,
// now that all the dependencies are registered then in multiproviderbloc we should give the Authbloc dependency,
// and then it will go from last step to first step....
void _initBlog() {
  serviceLocator
    ..registerFactory<BlogRemoteDatasource>(
        () => BlogRemoteDatasourceImpl(supabaseClient: serviceLocator()))
    ..registerFactory<BlogRepository>(
        () => BlogRepositoryImpl(serviceLocator()))
    ..registerFactory<UploadBlog>(
        () => UploadBlog(blogRepository: serviceLocator()))
    ..registerFactory(() => GetAllBlogs(blogRepository: serviceLocator()))
    ..registerLazySingleton(() => BlogBloc(
          uploadBlog: serviceLocator(),
          getAllBlogs: serviceLocator(),
        ));
  ;
}

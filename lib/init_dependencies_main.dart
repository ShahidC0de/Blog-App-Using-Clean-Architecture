part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();
  final supabase = await Supabase.initialize(
    anonKey: AppSecrets.annonKey,
    url: AppSecrets.url,
  );

  serviceLocator.registerFactory(() => InternetConnection());
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerLazySingleton(() => supabase.client);
  serviceLocator.registerFactory<ConnectionChecker>(
      () => ConnectionCheckerImpl(serviceLocator()));
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  final blogBox = await Hive.openBox('blogs');
  serviceLocator.registerLazySingleton(() => blogBox);
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
      serviceLocator(), // authremotedatasource
      serviceLocator(), // ConnectionChecker
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
    ..registerFactory<BlogLocalDatasource>(
        () => BlogLocalDatasourceImpl(serviceLocator()))
    ..registerFactory<BlogRepository>(() => BlogRepositoryImpl(
          serviceLocator(),
          serviceLocator(),
          serviceLocator(),
        ))
    ..registerFactory<UploadBlog>(
        () => UploadBlog(blogRepository: serviceLocator()))
    ..registerFactory(() => GetAllBlogs(blogRepository: serviceLocator()))
    ..registerLazySingleton(() => BlogBloc(
          uploadBlog: serviceLocator(),
          getAllBlogs: serviceLocator(),
        ));
}

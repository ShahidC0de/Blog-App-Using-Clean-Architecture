import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/features/auth/data/auth/data_sources/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDatasource {
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Session?
      get userSession; // this is a getter, different from function, where function requires parameters, the getter don't
  // it is used when u want to access some type of data from a class, in our example we are getting the session, so its already defined,
  // we will just need to access it using this getter.
  Future<UserModel?> getUserData();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDatasource {
  final SupabaseClient supabaseClient;
  // and this is dependency injection;
  const AuthRemoteDataSourceImpl(this.supabaseClient);
  // this is helpful, when we call the function which belongs to this class, it will create an instance and it is also for testing;
  @override
  @override
  Future<UserModel> signUpWithEmailAndPassword(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final response = await supabaseClient.auth
          .signUp(password: password, email: email, data: {
        'name': name,
      });
      if (response.user == null) {
        throw ServerException('the user is null!');
      }
      return UserModel.fromJson(
        response.user!.toJson(),
      ).copyWith(
        email: userSession!.user.email,
      );
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      return UserModel.fromJson(response.user!.toJson()).copyWith(
        email: userSession!.user.email,
      );
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Session? get userSession => supabaseClient.auth.currentSession;
  // see we are accessing the currentsession using supabaseClient,
  // now supabaseAuth will have only an email and id of the user, but what if we need the other details like name of the user,
  // for that case we need to get the data of user using the id of current user,
  // so the function is below which will access the database and take the data of user...

  @override
  Future<UserModel?> getUserData() async {
    try {
      // selecting the database that is 'profiles' and the column i select is 'id' and which user data? "current user";
      if (userSession != null) {
        final userData = await supabaseClient.from('profiles').select().eq(
            'id',
            userSession!.user
                .id); // if in profiles one of the id is matched currentsession user id
        return UserModel.fromJson(userData.first).copyWith(
          // return that user model as we know the auth already have an id and email of the user but we need name,
          // so we are grabbing the email of the user or maybe name
          email: userSession!.user.email,
        ); // first means that return the first element of the data, because the upper sentence is returning a List<Map>...
      }
      return null; // else don't need to specify...
    } on ServerException catch (e) {
      throw ServerException(e.toString());
    }
  }
}

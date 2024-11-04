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
  Session? get userSession;
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
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Session? get userSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel?> getUserData() async {
    try {
      // selecting the database that is 'profiles' and the column i select is 'id' and which user data? "current user";
      if (userSession != null) {
        final userData = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', userSession!.user.id);
        return UserModel.fromJson(userData.first).copyWith(
          email: userSession!.user.email,
        ); // first means that return the first element of the data, because the upper sentence is returning a List<Map>...
      }
      return null; // else don't need to specify...
    } on ServerException catch (e) {
      throw ServerException(e.toString());
    }
  }
}

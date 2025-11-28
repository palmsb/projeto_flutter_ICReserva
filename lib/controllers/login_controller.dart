import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/login_state.dart';

final loginControllerProvider =
    NotifierProvider<LoginController, LoginState>(() => LoginController());

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() {
    return const LoginState();
  }

  final supabase = Supabase.instance.client;

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.session != null) {
        state = state.copyWith(isLoading: false, isLogged: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Credenciais inválidas",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

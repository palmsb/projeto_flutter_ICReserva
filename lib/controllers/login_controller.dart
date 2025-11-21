import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/login_state.dart';

// PROVIDER DO CONTROLLER
final loginControllerProvider =
    NotifierProvider<LoginController, LoginState>(() => LoginController());

// CONTROLLER
class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() {
    return const LoginState(); // estado inicial
  }

  final supabase = Supabase.instance.client;

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
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

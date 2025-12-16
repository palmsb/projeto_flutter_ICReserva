import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart'; 
import 'user_controller.dart';

class LogoutState {
  final bool isLoading;
  final String? errorMessage;
  const LogoutState({this.isLoading = false, this.errorMessage});
  LogoutState copyWith({bool? isLoading, String? errorMessage}) {
    return LogoutState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final logoutControllerProvider =
    NotifierProvider<LogoutController, LogoutState>(() => LogoutController());

class LogoutController extends Notifier<LogoutState> {
  late final SupabaseClient _supabase;

  @override
  LogoutState build() {
    _supabase = ref.read(supabaseClientProvider);
    return const LogoutState();
  }

  /// Faz logout no Supabase e atualiza o perfil local (userProvider).
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Sign out (ajuste se sua versão do client exigir outro método)
      await _supabase.auth.signOut();

      await ref.read(userProvider.notifier).refreshProfile();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

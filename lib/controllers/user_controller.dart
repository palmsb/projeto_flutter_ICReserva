import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;

final userProvider =
    AsyncNotifierProvider<UserController, app_user.User?>(() => UserController());

class UserController extends AsyncNotifier<app_user.User?> {
  late final SupabaseClient _supabase;

  @override
  FutureOr<app_user.User?> build() {
    _supabase = Supabase.instance.client;
    return _fetchCurrentProfile();
  }

  Future<app_user.User?> _fetchCurrentProfile() async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) return null;
      final data = await _supabase.from('profiles').select().eq('id', authUser.id).maybeSingle();
      if (data == null) return null;
      return app_user.User.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('Erro ao buscar perfil do usuário: $e');
    }
  }

  Future<void> refreshProfile() async {
    state = await AsyncValue.guard(() => _fetchCurrentProfile());
  }

  Future<app_user.User> createProfile(Map<String, dynamic> payload) async {
    try {
      // payload deve conter id = auth user id, name, role (opcional)
      final data = await _supabase.from('profiles').insert(payload).select().single();
      final user = app_user.User.fromJson(Map<String, dynamic>.from(data));
      state = AsyncValue.data(user);
      return user;
    } catch (e) {
      throw Exception('Erro ao criar perfil: $e');
    }
  }

  Future<app_user.User?> ensureProfile({String? name, String role = 'estudante'}) async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) return null;
      // já existe?
      final existing = await _fetchCurrentProfile();
      if (existing != null) return existing;
      // cria profile usando id do auth
      final payload = <String, dynamic>{
        'id': authUser.id,
        'name': name ?? (authUser.email?.split('@').first ?? ''),
        'role': role,
      };
      return await createProfile(payload);
    } catch (e) {
      throw Exception('Erro ao garantir/criar perfil: $e');
    }
  }
  Future<app_user.User> updateProfile(String id, Map<String, dynamic> changes) async {
    try {
      final data = await _supabase.from('profiles').update(changes).eq('id', id).select().single();
      final user = app_user.User.fromJson(Map<String, dynamic>.from(data));
      state = AsyncValue.data(user);
      return user;
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  Future<void> deleteProfile(String id) async {
    try {
      await _supabase.from('profiles').delete().eq('id', id);
      state = const AsyncValue.data(null);
    } catch (e) {
      throw Exception('Erro ao deletar perfil: $e');
    }
  }

  Future<void> createAuthUser({
    required String email,
    required String password,
    Map<String, dynamic>? profilePayload,
  }) async {
    try {
      final res = await _supabase.auth.signUp(email: email, password: password);
      final authUser = res.user ?? _supabase.auth.currentUser;
      if (authUser == null) throw Exception('Falha ao criar credenciais');
      if (profilePayload != null) {
        profilePayload['id'] = authUser.id;
        await createProfile(profilePayload);
      }
      await refreshProfile();
    } catch (e) {
      throw Exception('Erro ao criar usuário de autenticação: $e');
    }
  }
}

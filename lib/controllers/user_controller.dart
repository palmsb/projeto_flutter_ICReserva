import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as AppUser;

final userProvider =
    AsyncNotifierProvider<UserController, AppUser.User?>(() => UserController());

class UserController extends AsyncNotifier<AppUser.User?> {
  late final SupabaseClient _supabase;

  @override
  FutureOr<AppUser.User?> build() {
    _supabase = Supabase.instance.client;
    return _fetchCurrentProfile();
  }

  Future<AppUser.User?> _fetchCurrentProfile() async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) return null;
      
      final data = await _supabase.from('profiles').select().eq('id', authUser.id).maybeSingle();
      if (data == null) return null;
      
      // Garante valores padrão para campos que podem estar faltando no banco
      final profileData = <String, dynamic>{
        'id': data['id'] ?? authUser.id,
        'email': data['email'] ?? authUser.email ?? '',
        'name': data['name'] ?? data['full_name'] ?? authUser.email?.split('@').first ?? '',
        'phone': data['phone'] ?? '',
        'photo_url': data['photo_url'] ?? data['avatar_url'] ?? '',
        'department': data['department'] ?? data['role'] ?? '',
        'created_at': data['created_at'] ?? DateTime.now().toIso8601String(),
        'updated_at': data['updated_at'] ?? DateTime.now().toIso8601String(),
      };
      
      return AppUser.User.fromJson(profileData);
    } catch (e) {
      throw Exception('Erro ao buscar perfil do usuário: $e');
    }
  }

  Future<void> refreshProfile() async {
    state = await AsyncValue.guard(() => _fetchCurrentProfile());
  }

  Future<AppUser.User> createProfile(Map<String, dynamic> payload) async {
    try {
      // payload deve conter id = auth user id, name, role (opcional)
      final data = await _supabase.from('profiles').insert(payload).select().single();
      final user = AppUser.User.fromJson(Map<String, dynamic>.from(data));
      state = AsyncValue.data(user);
      return user;
    } catch (e) {
      throw Exception('Erro ao criar perfil: $e');
    }
  }

  Future<AppUser.User?> ensureProfile({String? name, String role = 'estudante'}) async {
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
  Future<AppUser.User> updateProfile(String id, Map<String, dynamic> changes) async {
    try {
      final data = await _supabase.from('profiles').update(changes).eq('id', id).select().single();
      final user = AppUser.User.fromJson(Map<String, dynamic>.from(data));
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

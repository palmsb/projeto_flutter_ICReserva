import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room.dart';
import '../repositories/auth_repository.dart';

final roomsProvider = AsyncNotifierProvider<RoomController, List<Room>>(
  () => RoomController(),
);

class RoomController extends AsyncNotifier<List<Room>> {
  late final SupabaseClient _supabase;

  @override
  FutureOr<List<Room>> build() {
    _supabase = ref.read(supabaseClientProvider);
    return _fetchRooms();
  }

  Future<List<Room>> _fetchRooms() async {
    try {
      final data =
          await _supabase.from('rooms').select().order('name') as List<dynamic>;
      return data
          .map((e) => Room.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar salas: $e');
    }
  }

  Future<Room?> fetchById(String id) async {
    try {
      final data = await _supabase
          .from('rooms')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (data == null) return null;
      return Room.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('Erro ao buscar sala $id: $e');
    }
  }

  Future<void> refreshRooms() async {
    state = await AsyncValue.guard(() => _fetchRooms());
  }

  Future<Room> createRoom(Map<String, dynamic> payload) async {
    try {
      final data = await _supabase
          .from('rooms')
          .insert(payload)
          .select()
          .single();
      await refreshRooms();
      return Room.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('Erro ao criar sala: $e');
    }
  }

  Future<Room> updateRoom(String id, Map<String, dynamic> changes) async {
    try {
      final data = await _supabase
          .from('rooms')
          .update(changes)
          .eq('id', id)
          .select()
          .single();
      await refreshRooms();
      return Room.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('Erro ao atualizar sala: $e');
    }
  }

  Future<void> deleteRoom(String id) async {
    try {
      await _supabase.from('rooms').delete().eq('id', id);
      await refreshRooms();
    } catch (e) {
      throw Exception('Erro ao deletar sala: $e');
    }
  }
}

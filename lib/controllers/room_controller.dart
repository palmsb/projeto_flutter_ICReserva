import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room.dart';
import '../repositories/auth_repository.dart';

final roomsProvider = AsyncNotifierProvider<RoomController, List<Room>>(
  () => RoomController(),
);

class RoomController extends AsyncNotifier<List<Room>> {
  SupabaseClient get _supabase => ref.read(supabaseClientProvider);

  @override
  FutureOr<List<Room>> build() {
    return _fetchRooms();
  }

  Future<List<Room>> _fetchRooms() async {
    try {
      // Fetch rooms (availability relies solely on rooms.available column)
      final roomsData =
          await _supabase.from('rooms').select().order('name');

      return roomsData
          .map((e) => Room.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar salas: $e');
    }
  }

  Future<void> refreshRooms() async {
    state = await AsyncValue.guard(_fetchRooms);
  }
}

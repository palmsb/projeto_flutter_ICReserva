import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room.dart';
import '../repositories/auth_repository.dart';

final roomsProvider =
    AsyncNotifierProvider<RoomController, List<Room>>(
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
      final roomsData =
          await _supabase.from('rooms').select().order('name');

      return roomsData
          .map((e) => Room.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar salas: $e');
    }
  }

  // 🔄 Refresh
  Future<void> refreshRooms() async {
    state = await AsyncValue.guard(_fetchRooms);
  }


  Future<void> deleteRoom(String roomId) async {
    try {
      // 1 Excluir reservas da sala
      await _supabase
          .from('bookings')
          .delete()
          .eq('room_id', roomId);

      // 2 Excluir a sala
      await _supabase
          .from('rooms')
          .delete()
          .eq('id', roomId);

      // 3️ Atualiza o provider
      await refreshRooms();
    } catch (e) {
      throw Exception('Erro ao excluir sala: $e');
    }
  }

  Future<void> createRoom(Room room) async {
  try {
    await _supabase.from('rooms').insert({
      'name': room.name,
      'location': room.location,
      'capacity': room.capacity,
      'description': room.description,
      'available': room.available,
    });

    await refreshRooms();
  } catch (e) {
    throw Exception('Erro ao criar sala: $e');
  }
}

}

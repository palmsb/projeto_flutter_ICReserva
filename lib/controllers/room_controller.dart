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
      // Fetch rooms
      final roomsData =
          await _supabase.from('rooms').select().order('name');

      final rooms = roomsData
          .map((e) => Room.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Fetch all bookings (current OR future)
      final bookingsData = await _supabase
          .from('bookings')
          .select('room_id, status, start_time, end_time');

      // Determine which rooms are booked
      final reservedRoomIds = <String>{};

      for (final b in bookingsData) {
        final status = b['status'];
        final start = DateTime.parse(b['start_time']);
        final end = DateTime.parse(b['end_time']);

        // ❗ Agora: qualquer reserva confirmed torna indisponível
        final isReserved = status == 'confirmed';

        if (isReserved) {
          reservedRoomIds.add(b['room_id']);
        }
      }

      // Apply availability
      final updatedRooms = rooms.map((room) {
        final isAvailable = !reservedRoomIds.contains(room.id);
        return room.copyWith(available: isAvailable);
      }).toList();

      return updatedRooms;
    } catch (e) {
      throw Exception('Erro ao buscar salas: $e');
    }
  }

  Future<void> refreshRooms() async {
    state = await AsyncValue.guard(_fetchRooms);
  }
}

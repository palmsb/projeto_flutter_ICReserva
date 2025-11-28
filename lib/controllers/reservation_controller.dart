import 'dart:async';
import 'package:flutter_icreserva/models/room.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reservation.dart';

final reservationsProvider =
    AsyncNotifierProvider<ReservationController, List<Reservation>>(() => ReservationController());

class ReservationController extends AsyncNotifier<List<Reservation>> {
  late final SupabaseClient _supabase;

  @override
  FutureOr<List<Reservation>> build() {
    _supabase = Supabase.instance.client;
    return _fetchAll();
  }

  Future<List<Reservation>> _fetchAll() async {
    try {
      final data = await _supabase.from('bookings').select().order('start_time') as List<dynamic>;
      return data.map((e) => Reservation.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      throw Exception('Erro ao buscar reservas: $e');
    }
  }

  Future<void> refreshReservations() async {
    state = await AsyncValue.guard(() => _fetchAll());
  }

  Future<Reservation> createReservation(Map<String, dynamic> payload) async {
    try {
      // payload deve conter: room_id, user_id, start_time, end_time, status (opcional)
      final data = await _supabase.from('bookings').insert(payload).select().single();
      await refreshReservations();
      return Reservation.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('Erro ao criar reserva: $e');
    }
  }

  Future<List<Room>> fetchAvailable() async {
    try {
     final data = await _supabase.from('rooms').select().eq('available', true).order('name') as List<dynamic>;
      return data.map((e) => Room.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      throw Exception('Erro ao buscar salas disponíveis: $e');
    }
  }

  Future<Reservation> updateReservation(String id, Map<String, dynamic> changes) async {
    try {
      final data = await _supabase.from('bookings').update(changes).eq('id', id).select().single();
      await refreshReservations();
      return Reservation.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('Erro ao atualizar reserva: $e');
    }
  }

  Future<void> cancelReservation(String id) async {
    try {
      await _supabase.from('bookings').update({'status': 'cancelled'}).eq('id', id);
      await refreshReservations();
    } catch (e) {
      throw Exception('Erro ao cancelar reserva: $e');
    }
  }

  Future<void> deleteReservation(String id) async {
    try {
      await _supabase.from('bookings').delete().eq('id', id);
      await refreshReservations();
    } catch (e) {
      throw Exception('Erro ao deletar reserva: $e');
    }
  }

  Future<List<Reservation>> fetchByRoom(String roomId) async {
    try {
      final data = await _supabase
          .from('bookings')
          .select()
          .eq('room_id', roomId)
          .order('start_time') as List<dynamic>;
      return data.map((e) => Reservation.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      throw Exception('Erro ao buscar reservas da sala $roomId: $e');
    }
  }
}

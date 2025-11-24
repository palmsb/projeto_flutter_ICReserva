import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reservation.dart';

class ReservationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'reservations';

  /// Cria uma nova reserva
  Future<Reservation> create(Reservation reservation) async {
    try {
      final data = reservation.toJson();
      // Remove campos que não devem ser enviados no create
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      return Reservation.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar reserva: $e');
    }
  }

  /// Busca uma reserva por ID
  Future<Reservation?> getById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Reservation.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar reserva: $e');
    }
  }

  /// Lista todas as reservas
  Future<List<Reservation>> getAll() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('start_date', ascending: false);

      return (response as List)
          .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar reservas: $e');
    }
  }

  /// Lista reservas de uma sala específica (relação 1:N)
  Future<List<Reservation>> getByRoomId(String roomId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('room_id', roomId)
          .order('start_date', ascending: true);

      return (response as List)
          .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar reservas da sala: $e');
    }
  }

  /// Lista reservas futuras de uma sala específica
  Future<List<Reservation>> getFutureReservationsByRoomId(String roomId) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('room_id', roomId)
          .gte('start_date', now)
          .order('start_date', ascending: true);

      return (response as List)
          .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar reservas futuras da sala: $e');
    }
  }

  /// Lista reservas de um usuário específico
  Future<List<Reservation>> getByUserId(String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('start_date', ascending: false);

      return (response as List)
          .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar reservas do usuário: $e');
    }
  }

  /// Verifica se há conflito de horário para uma sala
  /// Retorna true se houver conflito, false caso contrário
  Future<bool> hasTimeConflict({
    required String roomId,
    required DateTime startDate,
    required DateTime endDate,
    String? excludeReservationId,
  }) async {
    try {
      // Busca todas as reservas da sala que não estão canceladas
      var query = _supabase
          .from(_tableName)
          .select('id,start_date,end_date')
          .eq('room_id', roomId)
          .neq('status', 'cancelled');

      if (excludeReservationId != null) {
        query = query.neq('id', excludeReservationId);
      }

      final response = await query;
      final reservations = response as List;

      // Verifica se há sobreposição de horários
      for (var reservation in reservations) {
        final resStart = DateTime.parse(reservation['start_date'] as String);
        final resEnd = DateTime.parse(reservation['end_date'] as String);

        // Verifica se há sobreposição
        if ((startDate.isBefore(resEnd) && endDate.isAfter(resStart))) {
          return true;
        }
      }

      return false;
    } catch (e) {
      throw Exception('Erro ao verificar conflito de horário: $e');
    }
  }

  /// Atualiza uma reserva existente
  Future<Reservation> update(Reservation reservation) async {
    try {
      final data = reservation.toJson();
      // Remove campos que não devem ser atualizados
      data.remove('id');
      data.remove('created_at');
      // Atualiza o updated_at
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', reservation.id)
          .select()
          .single();

      return Reservation.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar reserva: $e');
    }
  }

  /// Deleta uma reserva
  Future<void> delete(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar reserva: $e');
    }
  }

  /// Cancela uma reserva (muda status para cancelled)
  Future<Reservation> cancel(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return Reservation.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao cancelar reserva: $e');
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room.dart';

class RoomRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'rooms';

  /// Cria uma nova sala
  Future<Room> create(Room room) async {
    try {
      final data = room.toJson();
      // Remove campos que não devem ser enviados no create
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      return Room.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar sala: $e');
    }
  }

  /// Busca uma sala por ID
  Future<Room?> getById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Room.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar sala: $e');
    }
  }

  /// Lista todas as salas ativas
  Future<List<Room>> getAll({bool onlyActive = true}) async {
    try {
      var query = _supabase.from(_tableName).select();

      if (onlyActive) {
        query = query.eq('is_active', true);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => Room.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar salas: $e');
    }
  }

  /// Atualiza uma sala existente
  Future<Room> update(Room room) async {
    try {
      final data = room.toJson();
      // Remove campos que não devem ser atualizados
      data.remove('id');
      data.remove('created_at');
      // Atualiza o updated_at
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', room.id)
          .select()
          .single();

      return Room.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar sala: $e');
    }
  }

  /// Deleta uma sala (soft delete - marca como inativa)
  Future<void> delete(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar sala: $e');
    }
  }

  /// Deleta uma sala permanentemente do banco
  Future<void> deletePermanently(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar sala permanentemente: $e');
    }
  }
}

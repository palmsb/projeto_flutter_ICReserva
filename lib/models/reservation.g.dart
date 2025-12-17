// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReservationImpl _$$ReservationImplFromJson(Map<String, dynamic> json) =>
    _$ReservationImpl(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      userId: json['user_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status:
          $enumDecodeNullable(_$ReservationStatusEnumMap, json['status']) ??
          ReservationStatus.pending,
      createdAt: DateTime.parse(json['created_at'] as String),
      responsavel: json['responsavel'] as String? ?? '',
      observacoes: json['observacoes'] as String? ?? '',
    );

Map<String, dynamic> _$$ReservationImplToJson(_$ReservationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'room_id': instance.roomId,
      'user_id': instance.userId,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'status': _$ReservationStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'responsavel': instance.responsavel,
      'observacoes': instance.observacoes,
    };

const _$ReservationStatusEnumMap = {
  ReservationStatus.pending: 'pending',
  ReservationStatus.confirmed: 'confirmed',
  ReservationStatus.cancelled: 'cancelled',
  ReservationStatus.completed: 'completed',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReservationImpl _$$ReservationImplFromJson(Map<String, dynamic> json) =>
    _$ReservationImpl(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      userId: json['userId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      attendees: (json['attendees'] as num).toInt(),
      purpose: json['purpose'] as String,
      status:
          $enumDecodeNullable(_$ReservationStatusEnumMap, json['status']) ??
          ReservationStatus.pending,
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ReservationImplToJson(_$ReservationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'userId': instance.userId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'attendees': instance.attendees,
      'purpose': instance.purpose,
      'status': _$ReservationStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ReservationStatusEnumMap = {
  ReservationStatus.pending: 'pending',
  ReservationStatus.confirmed: 'confirmed',
  ReservationStatus.cancelled: 'cancelled',
  ReservationStatus.completed: 'completed',
};

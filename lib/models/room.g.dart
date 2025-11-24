// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomImpl _$$RoomImplFromJson(Map<String, dynamic> json) => _$RoomImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  capacity: (json['capacity'] as num).toInt(),
  location: json['location'] as String,
  photoUrl: json['photoUrl'] as String? ?? '',
  amenities:
      (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$RoomImplToJson(_$RoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'capacity': instance.capacity,
      'location': instance.location,
      'photoUrl': instance.photoUrl,
      'amenities': instance.amenities,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

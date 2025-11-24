// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Reservation _$ReservationFromJson(Map<String, dynamic> json) {
  return _Reservation.fromJson(json);
}

/// @nodoc
mixin _$Reservation {
  String get id => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  int get attendees => throw _privateConstructorUsedError;
  String get purpose => throw _privateConstructorUsedError;
  ReservationStatus get status => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Reservation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReservationCopyWith<Reservation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReservationCopyWith<$Res> {
  factory $ReservationCopyWith(
    Reservation value,
    $Res Function(Reservation) then,
  ) = _$ReservationCopyWithImpl<$Res, Reservation>;
  @useResult
  $Res call({
    String id,
    String roomId,
    String userId,
    DateTime startDate,
    DateTime endDate,
    int attendees,
    String purpose,
    ReservationStatus status,
    String notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$ReservationCopyWithImpl<$Res, $Val extends Reservation>
    implements $ReservationCopyWith<$Res> {
  _$ReservationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? userId = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? attendees = null,
    Object? purpose = null,
    Object? status = null,
    Object? notes = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            roomId: null == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            attendees: null == attendees
                ? _value.attendees
                : attendees // ignore: cast_nullable_to_non_nullable
                      as int,
            purpose: null == purpose
                ? _value.purpose
                : purpose // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ReservationStatus,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReservationImplCopyWith<$Res>
    implements $ReservationCopyWith<$Res> {
  factory _$$ReservationImplCopyWith(
    _$ReservationImpl value,
    $Res Function(_$ReservationImpl) then,
  ) = __$$ReservationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String roomId,
    String userId,
    DateTime startDate,
    DateTime endDate,
    int attendees,
    String purpose,
    ReservationStatus status,
    String notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$ReservationImplCopyWithImpl<$Res>
    extends _$ReservationCopyWithImpl<$Res, _$ReservationImpl>
    implements _$$ReservationImplCopyWith<$Res> {
  __$$ReservationImplCopyWithImpl(
    _$ReservationImpl _value,
    $Res Function(_$ReservationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? userId = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? attendees = null,
    Object? purpose = null,
    Object? status = null,
    Object? notes = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ReservationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        roomId: null == roomId
            ? _value.roomId
            : roomId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        attendees: null == attendees
            ? _value.attendees
            : attendees // ignore: cast_nullable_to_non_nullable
                  as int,
        purpose: null == purpose
            ? _value.purpose
            : purpose // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ReservationStatus,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReservationImpl implements _Reservation {
  const _$ReservationImpl({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.attendees,
    required this.purpose,
    this.status = ReservationStatus.pending,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$ReservationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReservationImplFromJson(json);

  @override
  final String id;
  @override
  final String roomId;
  @override
  final String userId;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final int attendees;
  @override
  final String purpose;
  @override
  @JsonKey()
  final ReservationStatus status;
  @override
  @JsonKey()
  final String notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Reservation(id: $id, roomId: $roomId, userId: $userId, startDate: $startDate, endDate: $endDate, attendees: $attendees, purpose: $purpose, status: $status, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReservationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.attendees, attendees) ||
                other.attendees == attendees) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    roomId,
    userId,
    startDate,
    endDate,
    attendees,
    purpose,
    status,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReservationImplCopyWith<_$ReservationImpl> get copyWith =>
      __$$ReservationImplCopyWithImpl<_$ReservationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReservationImplToJson(this);
  }
}

abstract class _Reservation implements Reservation {
  const factory _Reservation({
    required final String id,
    required final String roomId,
    required final String userId,
    required final DateTime startDate,
    required final DateTime endDate,
    required final int attendees,
    required final String purpose,
    final ReservationStatus status,
    final String notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ReservationImpl;

  factory _Reservation.fromJson(Map<String, dynamic> json) =
      _$ReservationImpl.fromJson;

  @override
  String get id;
  @override
  String get roomId;
  @override
  String get userId;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  int get attendees;
  @override
  String get purpose;
  @override
  ReservationStatus get status;
  @override
  String get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReservationImplCopyWith<_$ReservationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

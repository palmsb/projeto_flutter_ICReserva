import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

enum ReservationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('completed')
  completed,
}

@freezed
@Assert(
  'startTime.isBefore(endTime)',
  'Start time must be before end time',
)
class Reservation with _$Reservation {
  const factory Reservation({
    required String id,

    @JsonKey(name: 'room_id')
    required String roomId,

    @JsonKey(name: 'user_id')
    required String userId,

    @JsonKey(name: 'start_time')
    required DateTime startTime,

    @JsonKey(name: 'end_time')
    required DateTime endTime,

    @Default(ReservationStatus.pending)
    ReservationStatus status,

    @JsonKey(name: 'created_at')
    required DateTime createdAt,

    @Default('')
    String responsavel,

    @Default('')
    String observacoes,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
}

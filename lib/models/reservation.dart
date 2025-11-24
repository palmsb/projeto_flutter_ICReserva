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
class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    required String roomId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required int attendees,
    required String purpose,
    @Default(ReservationStatus.pending) ReservationStatus status,
    @Default('') String notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
}

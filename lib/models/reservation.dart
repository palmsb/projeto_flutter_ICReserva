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
    @JsonKey(name: 'room_id') required String roomId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'end_date')
    @Assert('startDate.isBefore(endDate)', 'Start date must be before end date')
    required DateTime endDate,
    @Assert('attendees > 0', 'Attendees must be greater than 0')
    required int attendees,
    required String purpose,
    @Default(ReservationStatus.pending) ReservationStatus status,
    @Default('') String notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
}

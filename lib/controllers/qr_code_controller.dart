import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room.dart';

/// Notifier para a sala selecionada
class SelectedRoomNotifier extends Notifier<Room?> {
  @override
  Room? build() => null;

  void selectRoom(Room room) {
    state = room;
  }

  void clearSelection() {
    state = null;
  }
}

/// Provider para a sala selecionada na tela de QR Code
final selectedRoomProvider = NotifierProvider<SelectedRoomNotifier, Room?>(
  () => SelectedRoomNotifier(),
);

/// Gera o conteúdo do QR Code para uma sala
/// O QR Code contém o ID da sala em formato JSON
String generateQrData(Room room) {
  return '{"room_id":"${room.id}","room_name":"${room.name}"}';
}


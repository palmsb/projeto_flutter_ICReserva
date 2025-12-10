import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room.dart';
import 'room_controller.dart';

/// Provider para a sala selecionada na tela de QR Code
final selectedRoomProvider = StateProvider<Room?>((ref) => null);

/// Provider para controlar o estado de exibição do QR Code
final showQrCodeProvider = StateProvider<bool>((ref) => false);

/// Controller para gerenciar a lógica da tela de QR Code
class QrCodeController {
  final Ref ref;

  QrCodeController(this.ref);

  /// Seleciona uma sala e exibe seu QR Code
  void selectRoom(Room room) {
    ref.read(selectedRoomProvider.notifier).state = room;
    ref.read(showQrCodeProvider.notifier).state = true;
  }

  /// Limpa a seleção e esconde o QR Code
  void clearSelection() {
    ref.read(selectedRoomProvider.notifier).state = null;
    ref.read(showQrCodeProvider.notifier).state = false;
  }

  /// Obtém a lista de salas ativas
  AsyncValue<List<Room>> getRooms() {
    return ref.watch(roomsProvider);
  }

  /// Gera o conteúdo do QR Code para uma sala
  /// O QR Code contém o ID da sala em formato JSON
  String generateQrData(Room room) {
    return '{"room_id":"${room.id}","room_name":"${room.name}"}';
  }
}

/// Provider do controller de QR Code
final qrCodeControllerProvider = Provider<QrCodeController>((ref) {
  return QrCodeController(ref);
});

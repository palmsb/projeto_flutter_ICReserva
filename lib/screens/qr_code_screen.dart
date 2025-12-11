import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/qr_code_controller.dart';
import '../controllers/room_controller.dart';
import '../models/room.dart';

class QrCodeScreen extends ConsumerWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);
    final selectedRoom = ref.watch(selectedRoomProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'QR Code das Salas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Lista de salas (lado esquerdo)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: roomsAsync.when(
                data: (rooms) {
                  if (rooms.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma sala cadastrada',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: rooms.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      final isSelected = selectedRoom?.id == room.id;

                      return _RoomCard(
                        room: room,
                        isSelected: isSelected,
                        onTap: () => ref.read(selectedRoomProvider.notifier).selectRoom(room),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar salas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Área de QR Code (lado direito)
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: selectedRoom != null
                  ? _QrCodeDisplay(
                      room: selectedRoom,
                      qrData: generateQrData(selectedRoom),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Selecione uma sala para gerar o QR Code',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para exibir um card de sala
class _RoomCard extends StatelessWidget {
  final Room room;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoomCard({
    required this.room,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Ícone da sala
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.meeting_room,
                color: isSelected ? Colors.black : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Informações da sala
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.location,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Capacidade: ${room.capacity}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Indicador de seleção
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget para exibir o QR Code
class _QrCodeDisplay extends StatelessWidget {
  final Room room;
  final String qrData;

  const _QrCodeDisplay({
    required this.room,
    required this.qrData,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Text(
              room.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              room.location,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 2,
                ),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 300,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            ),

            const SizedBox(height: 32),

            // Informações adicionais
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.people_outline,
                    label: 'Capacidade',
                    value: '${room.capacity} pessoas',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.description_outlined,
                    label: 'Descrição',
                    value: room.description,
                  ),
                  if (room.amenities.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.star_outline,
                      label: 'Comodidades',
                      value: room.amenities.join(', '),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botão para baixar/compartilhar (placeholder)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implementar download do QR Code
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funcionalidade em desenvolvimento'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Baixar QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para exibir uma linha de informação
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.black54,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

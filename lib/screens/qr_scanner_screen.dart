import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/room_controller.dart';
import '../controllers/reservation_controller.dart';
import '../models/room.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      // Busca a sala pelo ID do QR code
      final rooms = await ref.read(roomsProvider.future);
      final room = rooms.firstWhere(
        (r) => r.id == code,
        orElse: () => throw Exception('Sala não encontrada'),
      );

      // Busca reservas da sala
      final reservations = await ref
          .read(reservationsProvider.notifier)
          .fetchByRoom(room.id);

      // Verifica se há alguma reserva ativa no momento atual
      final now = DateTime.now();
      final activeReservation = reservations.where((r) {
        return r.startTime.isBefore(now) && 
               r.endTime.isAfter(now) &&
               r.status.toString().contains('confirmed');
      }).firstOrNull;

      final isReserved = activeReservation != null;

      if (mounted) {
        await cameraController.stop();
        
        // Mostra o resultado
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _RoomStatusDialog(
            room: room,
            isReserved: isReserved,
            reservation: activeReservation,
          ),
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        await cameraController.stop();
        
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erro'),
            content: Text('QR Code inválido ou sala não encontrada.\n\n$e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  cameraController.start();
                  setState(() => _isProcessing = false);
                },
                child: const Text('Tentar Novamente'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      }
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Escanear QR Code',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
          // Overlay com instruções
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Aponte a câmera para o QR Code da sala',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomStatusDialog extends StatelessWidget {
  final Room room;
  final bool isReserved;
  final dynamic reservation;

  const _RoomStatusDialog({
    required this.room,
    required this.isReserved,
    this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isReserved ? Icons.event_busy : Icons.event_available,
            color: isReserved ? Colors.red : Colors.green,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              room.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isReserved ? Colors.red.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isReserved ? Icons.lock : Icons.lock_open,
                  size: 20,
                  color: isReserved ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  isReserved ? 'RESERVADA' : 'DISPONÍVEL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isReserved ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Informações da sala
          _InfoRow(
            icon: Icons.location_on,
            label: 'Localização',
            value: room.location,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.people,
            label: 'Capacidade',
            value: '${room.capacity} pessoas',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.description,
            label: 'Descrição',
            value: room.description,
          ),
          
          // Se estiver reservada, mostra informações da reserva
          if (isReserved && reservation != null) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Reserva Ativa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.access_time,
              label: 'Horário',
              value: '${_formatTime(reservation.startTime)} - ${_formatTime(reservation.endTime)}',
            ),
            if (reservation.responsavel.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.person,
                label: 'Responsável',
                value: reservation.responsavel,
              ),
            ],
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

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
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 12),
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

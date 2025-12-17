import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/reservation_controller.dart';
import '../controllers/room_controller.dart';
import '../models/reservation.dart';

class ReservationsListScreen extends ConsumerWidget {
  const ReservationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(reservationsProvider);
    final roomsAsync = ref.watch(roomsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Listagem de Reservas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: reservationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Center(
          child: Text(
            "Erro ao carregar reservas:\n$err",
            textAlign: TextAlign.center,
          ),
        ),
        data: (reservations) {
          if (reservations.isEmpty) {
            return const Center(
              child: Text(
                "Nenhuma reserva encontrada.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(reservationsProvider.notifier).refreshReservations();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                return roomsAsync.when(
                  loading: () => _ReservationCard(
                    reservation: reservation,
                    roomName: 'Carregando...',
                    onDelete: () => _confirmDelete(context, ref, reservation.id),
                    onEdit: () => _showEditDialog(context, ref, reservation, 'Carregando...'),
                  ),
                  error: (error, stackTrace) => _ReservationCard(
                    reservation: reservation,
                    roomName: 'Erro ao carregar',
                    onDelete: () => _confirmDelete(context, ref, reservation.id),
                    onEdit: () => _showEditDialog(context, ref, reservation, 'Erro ao carregar'),
                  ),
                  data: (rooms) {
                    final room = rooms.firstWhere(
                      (r) => r.id == reservation.roomId,
                      orElse: () => rooms.first,
                    );
                    return _ReservationCard(
                      reservation: reservation,
                      roomName: room.name,
                      onDelete: () => _confirmDelete(context, ref, reservation.id),
                      onEdit: () => _showEditDialog(context, ref, reservation, room.name),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String reservationId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir esta reserva?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(reservationsProvider.notifier)
            .deleteReservation(reservationId);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reserva excluída com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir reserva: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Reservation reservation,
    String roomName,
  ) async {
    final dateFormat = DateFormat('dd/MM/yyyy');

    final responsavelController = TextEditingController(text: reservation.responsavel);
    final observacoesController = TextEditingController(text: reservation.observacoes);
    
    DateTime selectedDate = reservation.startTime;
    TimeOfDay selectedStartTime = TimeOfDay.fromDateTime(reservation.startTime);
    TimeOfDay selectedEndTime = TimeOfDay.fromDateTime(reservation.endTime);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          title: const Text('Editar Reserva'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width - 32,
            child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sala (read-only)
                Text(
                  'Sala: $roomName',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Data
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(dateFormat.format(selectedDate)),
                  subtitle: const Text('Data'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                
                // Horário de início
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: Text(selectedStartTime.format(context)),
                  subtitle: const Text('Horário de Início'),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedStartTime,
                    );
                    if (picked != null) {
                      setState(() {
                        selectedStartTime = picked;
                      });
                    }
                  },
                ),
                
                // Horário de fim
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: Text(selectedEndTime.format(context)),
                  subtitle: const Text('Horário de Fim'),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedEndTime,
                    );
                    if (picked != null) {
                      setState(() {
                        selectedEndTime = picked;
                      });
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Responsável
                TextField(
                  controller: responsavelController,
                  decoration: const InputDecoration(
                    labelText: 'Responsável',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Observações
                TextField(
                  controller: observacoesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                ),
              ],
            ),            ),          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Combina data com horários
                final startDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedStartTime.hour,
                  selectedStartTime.minute,
                );
                
                final endDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedEndTime.hour,
                  selectedEndTime.minute,
                );
                
                Navigator.of(context).pop({
                  'start_time': startDateTime.toIso8601String(),
                  'end_time': endDateTime.toIso8601String(),
                  'responsavel': responsavelController.text,
                  'observacoes': observacoesController.text,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (result != null && context.mounted) {
      try {
        await ref
            .read(reservationsProvider.notifier)
            .updateReservation(reservation.id, result);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reserva atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar reserva: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final String roomName;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ReservationCard({
    required this.reservation,
    required this.roomName,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Dismissible(
      key: Key(reservation.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        } else if (direction == DismissDirection.startToEnd) {
          onEdit();
        }
        return false; // Não remove automaticamente, apenas mostra o dialog
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 28,
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horários (início e fim)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Início:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeFormat.format(reservation.startTime),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fim:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeFormat.format(reservation.endTime),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Sala
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sala',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roomName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Responsável
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Responsável',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reservation.responsavel.isNotEmpty
                        ? reservation.responsavel
                        : 'N/A',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Data
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(reservation.startTime),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

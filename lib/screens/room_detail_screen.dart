import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room.dart';
import '../controllers/reservation_controller.dart';
import '../screens/login_screen.dart';

class RoomDetailScreen extends ConsumerWidget {
  final Room room;
  const RoomDetailScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = room.available ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Sala'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Card principal
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome + status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            room.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: available ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: available ? Colors.green : Colors.red),
                          ),
                          child: Text(
                            available ? 'Disponível' : 'Reservada',
                            style: TextStyle(
                              color: available ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // capacidade (linha) - cada item em sua própria linha com fundo cinza claro
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.people, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${room.capacity ?? 0} pessoas',
                            style: TextStyle(color: Colors.grey.shade800, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // localização (linha separada)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.place, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              room.location ?? '—',
                              style: TextStyle(color: Colors.grey.shade800, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // descrição
                    if ((room.description ?? '').isNotEmpty)
                      Text(room.description ?? '', style: TextStyle(color: Colors.grey.shade700)),

                    const SizedBox(height: 18),

                    // Recursos (4 blocos) centralizados, borda mais grossa preta e ícone com fundo preto + ícone branco
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _resourceBlock(Icons.ac_unit, 'Ar-condicionado'),
                        _resourceBlock(Icons.tv, 'TV'),
                        _resourceBlock(Icons.videocam, 'Projetor'),
                        _resourceBlock(Icons.computer, 'Computadores'),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Botão Reservar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: available ? () => _onReserve(context, ref) : null,
                        child: const Text('Reservar Sala', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Editar / QR
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.black12),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.edit, color: Colors.black),
                            label: const Text('Editar Sala', style: TextStyle(color: Colors.black)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Editar Sala — a implementar')));
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.black12),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.qr_code, color: Colors.black),
                            label: const Text('Ver QR Code', style: TextStyle(color: Colors.black)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('QR Code'),
                                  content: Text('QR da sala: ${room.id}'),
                                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resourceBlock(IconData icon, String title) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1.4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 26, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _onReserve(BuildContext context, WidgetRef ref) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    final now = DateTime.now().toUtc();
    final payload = {
      'room_id': room.id,
      'user_id': userId,
      'start_time': now.toIso8601String(),
      'end_time': now.add(const Duration(hours: 1)).toIso8601String(),
      'status': 'confirmed',
    };

    try {
      await ref.read(reservationsProvider.notifier).createReservation(payload);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reserva criada com sucesso')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar reserva: $e')));
      }
    }
  }
}
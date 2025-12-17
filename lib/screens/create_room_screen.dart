import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/room_controller.dart';
import '../models/room.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() =>
      _CreateRoomScreenState();
}

class _CreateRoomScreenState
    extends ConsumerState<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _available = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final room = Room(
      id: '',
      name: _nameController.text,
      location: _locationController.text,
      capacity: int.parse(_capacityController.text),
      description: _descriptionController.text,
      available: _available,
      createdAt: DateTime.now(),
    );

    await ref.read(roomsProvider.notifier).createRoom(room);

    if (mounted) {
      Navigator.pop(context); // 🔙 volta para Home
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Sala'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _input(
                controller: _nameController,
                label: 'Nome da Sala',
              ),
              _input(
                controller: _locationController,
                label: 'Localização',
              ),
              _input(
                controller: _capacityController,
                label: 'Capacidade',
                keyboard: TextInputType.number,
              ),
              _input(
                controller: _descriptionController,
                label: 'Descrição',
                maxLines: 3,
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                value: _available,
                onChanged: (v) => setState(() => _available = v),
                title: const Text('Disponível'),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Criar Sala',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: (v) =>
            v == null || v.isEmpty ? 'Campo obrigatório' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

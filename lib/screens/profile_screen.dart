import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/user_controller.dart';
import '../models/user.dart' as AppUser;

/// Tela de perfil do usuário
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meu Perfil',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Card de Perfil
              userAsync.when(
                loading: () => const _ProfileHeaderPlaceholder(),
                error: (err, _) => _ProfileHeader(
                  name: 'Erro ao carregar',
                  role: '',
                ),
                data: (user) => _ProfileHeader(
                  name: user?.name ?? '',
                  role: user?.department ?? 'Usuário',
                ),
              ),

              const SizedBox(height: 24),

              // Menu de opções
              _ProfileMenuOption(
                icon: Icons.calendar_today_outlined,
                title: 'Minhas Reservas',
                subtitle: 'Visualize suas reservas ativas',
                onTap: () {
                  // Ação visual apenas - implementação futura
                },
              ),

              const SizedBox(height: 12),

              _ProfileMenuOption(
                icon: Icons.edit_outlined,
                title: 'Editar Perfil',
                subtitle: 'Atualize suas informações',
                onTap: () {
                  // Ação visual apenas - implementação futura
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget de cabeçalho do perfil com nome e role
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String role;

  const _ProfileHeader({
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.grey.shade200,
              child: Icon(
                Icons.person,
                size: 48,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 16),

            // Nome do usuário
            Text(
              name.isNotEmpty ? name : 'Carregando...',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // Role/Department
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                role.isNotEmpty ? role : 'Usuário',
                style: textTheme.labelMedium?.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder para o cabeçalho enquanto carrega
class _ProfileHeaderPlaceholder extends StatelessWidget {
  const _ProfileHeaderPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar placeholder
            CircleAvatar(
              radius: 48,
              backgroundColor: colorScheme.surfaceContainerHighest,
              child: const CircularProgressIndicator(),
            ),

            const SizedBox(height: 16),

            // Nome placeholder
            Container(
              width: 120,
              height: 24,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            const SizedBox(height: 8),

            // Role placeholder
            Container(
              width: 80,
              height: 20,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de opção de menu do perfil
class _ProfileMenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.grey.shade700,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Seta
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

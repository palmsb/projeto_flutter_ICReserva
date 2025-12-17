import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../controllers/qr_scanner_controller.dart';

/// Verifica se a plataforma suporta câmera (mobile)
bool get _isMobilePlatform {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

/// Tela de Scanner de QR Code
///
/// PERMISSÕES NECESSÁRIAS:
/// --------------------
/// Android (android/app/src/main/AndroidManifest.xml):
/// ```xml
///   uses-permission android:name="android.permission.CAMERA"
///   uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
///   uses-permission android:name="android.permission.READ_MEDIA_IMAGES"
/// ```
///
/// iOS (ios/Runner/Info.plist):
/// ```xml
///   NSCameraUsageDescription - Este app precisa de acesso à câmera para escanear QR Codes.
///   NSPhotoLibraryUsageDescription - Este app precisa de acesso à galeria para selecionar imagens com QR Code.
/// ```
class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  @override
  void initState() {
    super.initState();
    // Listener para mostrar dialog quando código é detectado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupStateListener();
    });
  }

  void _setupStateListener() {
    ref.listenManual(qrScannerControllerProvider, (previous, next) {
      // Mostrar dialog quando um código é detectado
      if (next.status == QRScannerStatus.paused && next.scannedCode != null) {
        // Evita mostrar o mesmo dialog duas vezes
        if (previous?.scannedCode != next.scannedCode) {
          _showResultDialog(next.scannedCode!);
        }
      }

      // Mostrar erro via SnackBar
      if (next.status == QRScannerStatus.error && next.errorMessage != null) {
        if (previous?.errorMessage != next.errorMessage) {
          _showErrorSnackBar(next.errorMessage!);
        }
      }
    });
  }

  /// Exibe o dialog bloqueante com o resultado do QR Code
  Future<void> _showResultDialog(String code) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // Dialog bloqueante
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.qr_code_2,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              const Text('QR Code Detectado'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Código lido:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  code,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // Retoma o scanning após fechar o dialog (apenas em mobile)
                  if (_isMobilePlatform) {
                    ref
                        .read(qrScannerControllerProvider.notifier)
                        .resumeScanning();
                  } else {
                    ref.read(qrScannerControllerProvider.notifier).resetState();
                  }
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Exibe SnackBar de erro
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    // Reseta o estado (não tenta retomar câmera em desktop)
    ref.read(qrScannerControllerProvider.notifier).resetState();
  }

  /// Abre a galeria para selecionar imagem
  Future<void> _pickFromGallery() async {
    await ref.read(qrScannerControllerProvider.notifier).pickImageAndScan();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrScannerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR Code'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Botão para abrir galeria
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: 'Selecionar da galeria',
            onPressed: state.status == QRScannerStatus.processing
                ? null
                : _pickFromGallery,
          ),
        ],
      ),
      body: _isMobilePlatform
          ? _buildMobileBody(context, state)
          : _buildDesktopBody(context, state),
    );
  }

  /// Body para plataformas mobile (com câmera)
  Widget _buildMobileBody(BuildContext context, QRScannerState state) {
    final controller =
        ref.read(qrScannerControllerProvider.notifier).scannerController;

    return Column(
      children: [
        // --------- ÁREA DA CÂMERA ----------
        Expanded(
          child: Stack(
            children: [
              // Widget da câmera
              MobileScanner(
                controller: controller,
                onDetect: (capture) {
                  ref
                      .read(qrScannerControllerProvider.notifier)
                      .onQRCodeDetected(capture);
                },
              ),

              // Overlay customizado sobre a câmera
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _getOverlayColor(state.status),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width: 250,
                  height: 250,
                ),
              ),

              // Indicador de processamento
              if (state.status == QRScannerStatus.processing)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Processando...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Instrução de posicionamento
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Posicione o QR Code dentro do quadro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // --------- BOTÃO ESCANEAR ----------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: state.status == QRScannerStatus.processing
                ? null
                : () async {
                    // Se estiver pausado ou com erro, retoma o scanning
                    if (state.status == QRScannerStatus.paused ||
                        state.status == QRScannerStatus.error) {
                      await ref
                          .read(qrScannerControllerProvider.notifier)
                          .resumeScanning();
                    }
                  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.status == QRScannerStatus.scanning
                      ? Icons.qr_code_scanner
                      : Icons.refresh,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  state.status == QRScannerStatus.scanning
                      ? 'Escanear'
                      : 'Retomar Escaneamento',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Body para plataformas desktop (sem câmera, apenas galeria)
  Widget _buildDesktopBody(BuildContext context, QRScannerState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone grande
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.qr_code_scanner,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 32),

            // Título
            const Text(
              'Scanner de QR Code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Mensagem informativa
            Text(
              'O scanner de câmera não está disponível nesta plataforma.\n'
              'Use o botão abaixo para selecionar uma imagem com QR Code da galeria.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 40),

            // Indicador de processamento
            if (state.status == QRScannerStatus.processing)
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processando imagem...'),
                  ],
                ),
              ),

            // Botão para selecionar da galeria
            SizedBox(
              width: 300,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: state.status == QRScannerStatus.processing
                    ? null
                    : _pickFromGallery,
                icon: const Icon(Icons.photo_library, size: 24),
                label: const Text(
                  'Selecionar Imagem',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retorna a cor do overlay baseado no status
  Color _getOverlayColor(QRScannerStatus status) {
    switch (status) {
      case QRScannerStatus.scanning:
        return Colors.white;
      case QRScannerStatus.processing:
        return Colors.orange;
      case QRScannerStatus.paused:
        return Colors.green;
      case QRScannerStatus.error:
        return Colors.red;
    }
  }
}

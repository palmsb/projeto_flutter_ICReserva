import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Verifica se a plataforma suporta câmera (mobile)
bool get _isMobilePlatform {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

/// Estados possíveis do scanner de QR Code
enum QRScannerStatus {
  /// Scanner pronto para escanear
  scanning,

  /// Processando um código detectado
  processing,

  /// Erro ocorreu durante a leitura
  error,

  /// Scanner pausado (após detectar um código)
  paused,
}

/// Estado do scanner de QR Code
class QRScannerState {
  final QRScannerStatus status;
  final String? scannedCode;
  final String? errorMessage;

  const QRScannerState({
    this.status = QRScannerStatus.scanning,
    this.scannedCode,
    this.errorMessage,
  });

  QRScannerState copyWith({
    QRScannerStatus? status,
    String? scannedCode,
    String? errorMessage,
  }) {
    return QRScannerState(
      status: status ?? this.status,
      scannedCode: scannedCode ?? this.scannedCode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller para gerenciar o estado do scanner de QR Code
class QRScannerController extends Notifier<QRScannerState> {
  MobileScannerController? _scannerController;
  late final ImagePicker _imagePicker;

  @override
  QRScannerState build() {
    _imagePicker = ImagePicker();

    // Só inicializa o scanner de câmera em plataformas mobile
    if (_isMobilePlatform) {
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );

      // Dispose do controller quando o provider for descartado
      ref.onDispose(() {
        _scannerController?.dispose();
      });
    }

    return const QRScannerState();
  }

  /// Retorna o controller do MobileScanner para uso na UI
  /// Só deve ser chamado em plataformas mobile
  MobileScannerController get scannerController {
    if (_scannerController == null) {
      throw StateError(
          'MobileScannerController não disponível nesta plataforma');
    }
    return _scannerController!;
  }

  /// Processa um código QR detectado pela câmera
  void onQRCodeDetected(BarcodeCapture capture) {
    // Evita processar se já estiver processando ou pausado
    if (state.status == QRScannerStatus.processing ||
        state.status == QRScannerStatus.paused) {
      return;
    }

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    // Atualiza estado para processando
    state = state.copyWith(status: QRScannerStatus.processing);

    // Pausa a câmera
    _scannerController?.stop();

    // Atualiza estado com o código lido
    state = state.copyWith(
      status: QRScannerStatus.paused,
      scannedCode: code,
    );
  }

  /// Retoma a câmera após fechar o dialog (apenas mobile)
  Future<void> resumeScanning() async {
    state = const QRScannerState(status: QRScannerStatus.scanning);
    if (_isMobilePlatform && _scannerController != null) {
      await _scannerController!.start();
    }
  }

  /// Reseta o estado sem tentar controlar a câmera (para desktop)
  void resetState() {
    state = const QRScannerState(status: QRScannerStatus.scanning);
  }

  /// Seleciona uma imagem da galeria e tenta ler o QR Code
  Future<String?> pickImageAndScan() async {
    try {
      state = state.copyWith(status: QRScannerStatus.processing);

      // Pausa a câmera enquanto seleciona imagem (apenas mobile)
      if (_isMobilePlatform && _scannerController != null) {
        await _scannerController!.stop();
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) {
        // Usuário cancelou a seleção
        if (_isMobilePlatform) {
          await resumeScanning();
        } else {
          resetState();
        }
        return null;
      }

      // Analisa a imagem em busca de QR Code
      // Em desktop, usa um scanner estático
      BarcodeCapture? result;
      if (_isMobilePlatform && _scannerController != null) {
        result = await _scannerController!.analyzeImage(image.path);
      } else {
        // Para desktop, cria um controller temporário só para análise
        final tempController = MobileScannerController();
        try {
          result = await tempController.analyzeImage(image.path);
        } finally {
          tempController.dispose();
        }
      }

      if (result == null || result.barcodes.isEmpty) {
        // Nenhum QR Code encontrado na imagem
        state = state.copyWith(
          status: QRScannerStatus.error,
          errorMessage: 'Nenhum QR Code encontrado na imagem.',
        );
        return null;
      }

      final String? code = result.barcodes.first.rawValue;
      if (code == null || code.isEmpty) {
        state = state.copyWith(
          status: QRScannerStatus.error,
          errorMessage: 'QR Code inválido ou vazio.',
        );
        return null;
      }

      // QR Code encontrado com sucesso
      state = state.copyWith(
        status: QRScannerStatus.paused,
        scannedCode: code,
      );

      return code;
    } catch (e) {
      state = state.copyWith(
        status: QRScannerStatus.error,
        errorMessage: 'Erro ao processar imagem: $e',
      );
      return null;
    }
  }

  /// Limpa mensagem de erro e retoma scanning (apenas mobile)
  Future<void> clearError() async {
    if (_isMobilePlatform) {
      await resumeScanning();
    } else {
      resetState();
    }
  }
}

/// Provider para o controller do scanner
final qrScannerControllerProvider =
    NotifierProvider<QRScannerController, QRScannerState>(
  QRScannerController.new,
);

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:alist_flutter/controllers/tv_controller.dart';

/// 仅用于显示服务器二维码的面板
class QRCodePanel extends StatelessWidget {
  const QRCodePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TVController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Obx(() {
        final isRunning = controller.isServiceRunning.value;
        final url = controller.serverUrl.value;
        final showQrCode = isRunning && url.isNotEmpty && url != '服务未启动';

        return Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: showQrCode
                  ? QrImageView(
                      data: 'http://$url',
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    )
                  : Center(
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 80,
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }
}
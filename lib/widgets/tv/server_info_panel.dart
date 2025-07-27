import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:alist_flutter/controllers/tv_controller.dart';

/// 服务器信息显示面板，包含服务器地址和二维码
class ServerInfoPanel extends StatelessWidget {
  const ServerInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TVController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          // 服务器地址
          Obx(() => Column(
            children: [
              Text(
                '服务器地址',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: SelectableText(
                  controller.serverUrl.value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )),
          
          const SizedBox(height: 24),
          
          // 二维码
          Obx(() => Column(
            children: [
              Text(
                '扫码访问',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: controller.isServiceRunning.value && 
                       controller.serverUrl.value.isNotEmpty && 
                       controller.serverUrl.value != '服务未启动'
                    ? QrImageView(
                        data: 'http://${controller.serverUrl.value}',
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        padding: const EdgeInsets.all(4), // 减小二维码本身的白边
                      )
                    : Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.qr_code,
                          size: 80,
                          color: colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
              ),
            ],
          )),

        ],
      ),
    );
  }
}



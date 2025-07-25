import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:alist_flutter/contant/native_bridge.dart';

/// 服务器信息显示面板，包含网址和二维码
class ServerInfoPanel extends StatelessWidget {
  const ServerInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServerInfoController());
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
          // 标题
          Text(
            '服务器信息',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          
          // 服务状态指示器
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: controller.isRunning.value 
                  ? colorScheme.primaryContainer 
                  : colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  controller.isRunning.value 
                      ? Icons.check_circle 
                      : Icons.error,
                  size: 16,
                  color: controller.isRunning.value 
                      ? colorScheme.primary 
                      : colorScheme.error,
                ),
                const SizedBox(width: 6),
                Text(
                  controller.isRunning.value ? '服务运行中' : '服务已停止',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: controller.isRunning.value 
                        ? colorScheme.primary 
                        : colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 20),
          
          // 服务器网址
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: controller.serverUrl.value.isNotEmpty
                    ? QrImageView(
                        data: controller.serverUrl.value,
                        version: QrVersions.auto,
                        size: 160,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      )
                    : Container(
                        width: 160,
                        height: 160,
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
          
          const SizedBox(height: 16),
          
          // 刷新按钮
          ElevatedButton.icon(
            onPressed: controller.refreshServerInfo,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('刷新'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

/// 服务器信息控制器
class ServerInfoController extends GetxController {
  final isRunning = false.obs;
  final serverUrl = ''.obs;
  final port = 5244.obs;

  @override
  void onInit() {
    super.onInit();
    refreshServerInfo();
    
    // 定期刷新服务器状态
    _startPeriodicRefresh();
  }

  /// 刷新服务器信息
  Future<void> refreshServerInfo() async {
    try {
      // 获取服务运行状态
      final running = await NativeBridge.android.isRunning();
      isRunning.value = running;
      
      // 获取端口号
      final httpPort = await NativeBridge.android.getAListHttpPort();
      port.value = httpPort;
      
      // 生成服务器URL
      if (running) {
        final localIP = await _getLocalIPAddress();
        serverUrl.value = 'http://$localIP:$httpPort';
      } else {
        serverUrl.value = '服务未启动';
      }
    } catch (e) {
      print('获取服务器信息失败: $e');
      isRunning.value = false;
      serverUrl.value = '获取信息失败';
    }
  }

  /// 获取本地IP地址
  Future<String> _getLocalIPAddress() async {
    try {
      // 获取所有网络接口
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      
      // 优先选择WiFi接口
      for (final interface in interfaces) {
        if (interface.name.toLowerCase().contains('wlan') ||
            interface.name.toLowerCase().contains('wifi')) {
          for (final addr in interface.addresses) {
            if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
              return addr.address;
            }
          }
        }
      }
      
      // 如果没有WiFi接口，选择其他非回环接口
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && 
              !addr.isLoopback && 
              !addr.address.startsWith('169.254')) {
            return addr.address;
          }
        }
      }
      
      // 如果都没有，返回localhost
      return '127.0.0.1';
    } catch (e) {
      print('获取本地IP地址失败: $e');
      return '127.0.0.1';
    }
  }

  /// 开始定期刷新
  void _startPeriodicRefresh() {
    // 每5秒刷新一次服务器状态
    Stream.periodic(const Duration(seconds: 5)).listen((_) {
      refreshServerInfo();
    });
  }

  @override
  void onClose() {
    super.onClose();
  }
}

/// 服务器信息数据模型
class ServerInfo {
  final String url;
  final int port;
  final bool isRunning;

  const ServerInfo({
    required this.url,
    required this.port,
    required this.isRunning,
  });

  @override
  String toString() {
    return 'ServerInfo{url: $url, port: $port, isRunning: $isRunning}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServerInfo &&
        other.url == url &&
        other.port == port &&
        other.isRunning == isRunning;
  }

  @override
  int get hashCode {
    return url.hashCode ^ port.hashCode ^ isRunning.hashCode;
  }
}
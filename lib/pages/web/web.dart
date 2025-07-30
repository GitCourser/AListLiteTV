import 'dart:developer';

import 'package:alist_flutter/contant/native_bridge.dart';
import 'package:alist_flutter/controllers/tv_controller.dart';
import 'package:alist_flutter/generated_api.dart';
import 'package:alist_flutter/utils/intent_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../generated/l10n.dart';

GlobalKey<WebScreenState> webGlobalKey = GlobalKey();

class WebScreen extends StatefulWidget {
  const WebScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WebScreenState();
  }
}

class WebScreenState extends State<WebScreen> {
  InAppWebViewController? _webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    allowsInlineMediaPlayback: true,
    allowBackgroundAudioPlaying: true,
    iframeAllowFullscreen: true,
    javaScriptEnabled: true,
    mediaPlaybackRequiresUserGesture: false,
    useShouldOverrideUrlLoading: true,
  );

  double _progress = 0;
  String? _url; // 不设置默认值，完全依赖配置
  bool _canGoBack = false;
  bool _isInitialized = false;

  onClickNavigationBar() {
    log("onClickNavigationBar");
    _webViewController?.reload();
  }

  @override
  void initState() {
    super.initState();
    _initializeUrl();
  }

  Future<void> _initializeUrl() async {
    try {
      final port = await Android().getAListHttpPort();
      setState(() {
        _url = "http://localhost:$port";
        _isInitialized = true;
      });
      log("WebView URL initialized from config: $_url");
    } catch (e) {
      log("Failed to get AList HTTP port: $e");
      // 如果获取配置失败，显示错误状态而不是使用默认端口
      setState(() {
        _url = null; // 设置为null表示加载失败
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _webViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Allow auto-rotation for web page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return PopScope(
        canPop: true,
        onPopInvoked: (didPop) async {
          log("onPopInvoked $didPop");
          if (didPop) return;
          // 直接返回到TV主页而不是网页的上一页
          final tvController = Get.find<TVController>();
          tvController.navigateBackToTVHome();
        },
        child: Scaffold(
          body: Column(children: <Widget>[
            SizedBox(height: MediaQuery.of(context).padding.top),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            Expanded(
              child: _isInitialized ? (_url != null ? InAppWebView(
                initialSettings: settings,
                initialUrlRequest: URLRequest(url: WebUri(_url!)),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
                onLoadStart: (InAppWebViewController controller, Uri? url) {
                  log("onLoadStart $url");
                  setState(() {
                    _progress = 0;
                  });
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  log("shouldOverrideUrlLoading ${navigationAction.request.url}");

                  var uri = navigationAction.request.url!;
                  if (![
                    "http",
                    "https",
                    "file",
                    "chrome",
                    "data",
                    "javascript",
                    "about"
                  ].contains(uri.scheme)) {
                    log("shouldOverrideUrlLoading ${uri.toString()}");
                    final silentMode =
                        await NativeBridge.appConfig.isSilentJumpAppEnabled();
                    if (silentMode) {
                      NativeCommon().startActivityFromUri(uri.toString());
                    } else {
                      Get.showSnackbar(GetSnackBar(
                          message: S.current.jumpToOtherApp,
                          duration: const Duration(seconds: 5),
                          mainButton: TextButton(
                            onPressed: () {
                              NativeCommon()
                                  .startActivityFromUri(uri.toString());
                            },
                            child: Text(S.current.goTo),
                          )));
                    }

                    return NavigationActionPolicy.CANCEL;
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onReceivedError: (controller, request, error) async {
                  if (!await Android().isRunning()) {
                    await Android().startService();

                    for (int i = 0; i < 3; i++) {
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (await Android().isRunning()) {
                        _webViewController?.reload();
                        break;
                      }
                    }
                  }
                },
                onDownloadStartRequest: (controller, url) async {
                  Get.showSnackbar(GetSnackBar(
                    title: S.of(context).downloadThisFile,
                    message: url.suggestedFilename ??
                        url.contentDisposition ??
                        url.toString(),
                    duration: const Duration(seconds: 3),
                    mainButton: Column(children: [
                      TextButton(
                        onPressed: () {
                          IntentUtils.getUrlIntent(url.url.toString())
                              .launchChooser(S.of(context).selectAppToOpen);
                        },
                        child: Text(S.of(context).selectAppToOpen),
                      ),
                      TextButton(
                        onPressed: () {
                          IntentUtils.getUrlIntent(url.url.toString()).launch();
                        },
                        child: Text(S.of(context).download),
                      ),
                    ]),
                    onTap: (_) {
                      Clipboard.setData(
                          ClipboardData(text: url.url.toString()));
                      Get.closeCurrentSnackbar();
                      Get.showSnackbar(GetSnackBar(
                        message: S.of(context).copiedToClipboard,
                        duration: const Duration(seconds: 1),
                      ));
                    },
                  ));
                },
                onLoadStop:
                    (InAppWebViewController controller, Uri? url) async {
                  setState(() {
                    _progress = 0;
                  });
                },
                onProgressChanged:
                    (InAppWebViewController controller, int progress) {
                  setState(() {
                    _progress = progress / 100;
                    if (_progress == 1) _progress = 0;
                  });
                  controller.canGoBack().then((value) => setState(() {
                        _canGoBack = value;
                      }));
                },
                onUpdateVisitedHistory: (InAppWebViewController controller,
                    WebUri? url, bool? isReload) {
                  if (url != null) {
                    _url = url.toString();
                  }
                },
              ) : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '无法获取端口配置',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '请检查AList配置或重启应用',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isInitialized = false;
                        });
                        _initializeUrl();
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              )) : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在加载端口配置...'),
                  ],
                ),
              ),
            ),
          ]),
        ));
  }
}

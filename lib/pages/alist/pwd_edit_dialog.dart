import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PwdEditDialog extends StatefulWidget {
  final ValueChanged<String> onConfirm;

  const PwdEditDialog({super.key, required this.onConfirm});

  @override
  State<PwdEditDialog> createState() {
    return _PwdEditDialogState();
  }
}

class _PwdEditDialogState extends State<PwdEditDialog> {
  final TextEditingController pwdController = TextEditingController();

  // 1. 为两个需要控制焦点的控件分别创建 FocusNode
  final FocusNode _textFieldFocusNode = FocusNode();
  final FocusNode _confirmButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 依然保留最可靠的初始对焦方法
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _textFieldFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    pwdController.dispose();
    // 3. 销毁所有创建的 FocusNode
    _textFieldFocusNode.dispose();
    _confirmButtonFocusNode.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (mounted) {
      Get.back();
      widget.onConfirm(pwdController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("修改admin密码"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: pwdController,
            focusNode: _textFieldFocusNode, // 绑定 FocusNode
            autofocus: true, // 保留
            decoration: const InputDecoration(
              labelText: "admin密码",
            ),
            // 2. 核心逻辑：当在输入框按下确定键时
            onSubmitted: (_) {
              // 不再直接提交，而是请求将焦点转移到“确定”按钮上
              _confirmButtonFocusNode.requestFocus();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("取消"),
        ),
        FilledButton(
          focusNode: _confirmButtonFocusNode, // 绑定 FocusNode
          onPressed: _handleConfirm,
          child: const Text("确定"),
        ),
      ],
    );
  }
}

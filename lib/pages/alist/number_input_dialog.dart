import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../generated/l10n.dart';

class NumberInputDialog extends StatefulWidget {
  final String title;
  final String labelText;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onConfirm;

  const NumberInputDialog({
    super.key,
    required this.title,
    required this.labelText,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onConfirm,
  });

  @override
  State<NumberInputDialog> createState() => _NumberInputDialogState();
}

class _NumberInputDialogState extends State<NumberInputDialog> {
  late TextEditingController _controller;
  String? _errorText;

  // 1. 创建 FocusNode
  final FocusNode _textFieldFocusNode = FocusNode();
  final FocusNode _confirmButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());

    // 2. 延迟请求初始焦点，这是最可靠的方式
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _textFieldFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    // 5. 销毁所有 FocusNode
    _textFieldFocusNode.dispose();
    _confirmButtonFocusNode.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    // 使用 setState 更新 UI (错误文本和按钮状态)
    setState(() {
      if (value.isEmpty) {
        _errorText = S.of(context).enterValue;
        return;
      }

      final number = int.tryParse(value);
      if (number == null) {
        _errorText = S.of(context).invalidPortNumber;
        return;
      }

      if (number < widget.minValue || number > widget.maxValue) {
        if (widget.maxValue == 65535) {
          _errorText = S.of(context).portRangeError; // 端口范围错误
        } else {
          _errorText = S.of(context).delayTimeError; // 延时范围错误
        }
        return;
      }

      _errorText = null;
    });
  }

  // 计算属性，用于判断输入是否有效
  bool get _isValid => _errorText == null && _controller.text.isNotEmpty;

  void _onConfirm() {
    // 在按下按钮时再次验证以防万一
    _validateInput(_controller.text);
    
    // 只有在验证通过时才执行确认操作
    if (_isValid) {
      final number = int.parse(_controller.text);
      Get.back();
      widget.onConfirm(number);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            focusNode: _textFieldFocusNode, // 3. 绑定 TextField 的 FocusNode
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: widget.labelText,
              errorText: _errorText,
              helperText: "${S.of(context).currentValue}: ${widget.initialValue}",
            ),
            onChanged: _validateInput,
            autofocus: true, // 保留 autofocus
            // 4. 核心：在输入框按确定时，转移焦点
            onSubmitted: (value) {
                // 在转移焦点前，先执行一次验证
                _validateInput(value);
                // 确保在 widget 树中再操作
                if(mounted) {
                    // 如果输入有效，则将焦点转移到确定按钮
                    if (_isValid) {
                        _confirmButtonFocusNode.requestFocus();
                    }
                    // 如果输入无效，则焦点保留在输入框，让用户修改
                }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(S.of(context).cancel),
        ),
        FilledButton(
          focusNode: _confirmButtonFocusNode, // 3. 绑定 Button 的 FocusNode
          // 如果输入无效，按钮将被禁用 (onPressed: null)
          onPressed: _isValid ? _onConfirm : null,
          child: Text(S.of(context).confirm),
        ),
      ],
    );
  }
}

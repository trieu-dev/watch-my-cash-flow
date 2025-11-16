import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

final formatter = NumberFormat("#,###", "vi_VN");

class VNDTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll('.', '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final number = int.parse(text);
    final newText = formatter.format(number);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
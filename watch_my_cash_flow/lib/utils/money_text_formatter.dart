import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:watch_my_cash_flow/app/services/localization_service.dart';

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

String formatAmount(double amount) {
  final loc = Get.find<LocalizationService>();
  final formattedAmount = formatter.format(amount);

  switch (loc.currentLanguageCode) {
    case 'en': return '\$$formattedAmount';
    case 'vi': return '$formattedAmount₫';
    case 'zh': return '¥$formattedAmount';
    case 'ko': return '₩$formattedAmount';
    default:
      return formattedAmount;
  }
}
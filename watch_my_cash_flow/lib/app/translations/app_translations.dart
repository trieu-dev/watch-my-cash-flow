import 'package:get/get.dart';
import 'package:watch_my_cash_flow/app/translations/en_US.dart';
import 'package:watch_my_cash_flow/app/translations/vi_VN.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'vi_VN': viVN,
  };
}

import 'package:get/get.dart';
import 'package:watch_my_cash_flow/app/translations/en_US.dart';
import 'package:watch_my_cash_flow/app/translations/ko_KR.dart';
import 'package:watch_my_cash_flow/app/translations/vi_VN.dart';
import 'package:watch_my_cash_flow/app/translations/zh_CN.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'vi_VN': viVN,
    'zh_CN': zhCN,
    'ko_KR': koKR,
  };
}

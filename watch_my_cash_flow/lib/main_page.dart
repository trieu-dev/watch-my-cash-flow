import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_my_cash_flow/add_cash_flow_entry.dart';
import 'package:watch_my_cash_flow/app/services/date_service.dart';
import 'package:watch_my_cash_flow/app/services/localization_service.dart';
import 'package:watch_my_cash_flow/calendar/calendar_controller.dart';
import 'package:watch_my_cash_flow/calendar/calendar_page.dart';
import 'package:watch_my_cash_flow/data/model/cash_flow_entry.dart';
import 'package:watch_my_cash_flow/utils/money_text_formatter.dart';

enum Language { vn, us, cn, kr, jp, th }
const Map<Language, Locale> languageToLocale = {
  Language.vn: Locale('vi', 'VN'),
  Language.us: Locale('en', 'US'),
  Language.cn: Locale('zh', 'CN'),
  Language.kr: Locale('ko', 'KR'),
  Language.jp: Locale('ja', 'JP'),
  Language.th: Locale('th', 'TH'),
};

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  bool isDarkMode = true;
  final loc = Get.find<LocalizationService>();

  final CalendarController controller = Get.find<CalendarController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SafeArea(
        child: CalendarPage()
        // PageView.builder(
        //   onPageChanged: (value) {
        //     setState(() {
        //       month = DateTime(
        //         DateTime.now().year,
        //         DateTime.now().month + (value - 5000),
        //       );
        //     });
        //   },
        //   controller: _pageController,
        //   itemBuilder: (context, index) {
        //     final month = monthFromIndex(index);
        //     return MonthCalendar(month: month, mDate2Entries: mDate2Entries, onAfterUpdated: handleAfterUpdated); // your existing month grid
        //   },
        // )
      ),
      floatingActionButton: addEntryButton(),
    );
  }

  AppBar appBar() {
    return AppBar(
      toolbarHeight: 60,
      title: Obx(() => Text(controller.currentDate.year == DateTime.now().year ? dateService.monthLong(controller.currentDate) : dateService.monthYearShort(controller.currentDate))), // Display month name
      leading: Obx(() => totalAmount()),
      leadingWidth: 120,
      actions: [ languages(), mode() ]
    );
  }

  Widget totalAmount() {
    return Center(
      child: Text("${"app.total".tr}: ${formatAmount(controller.total)}",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Get.theme.colorScheme.primary,
        ),
        textAlign: TextAlign.left,
      ).marginOnly(left: 4),
    );
  }

  Widget languages() {
    return SizedBox(
      width: 38,
      height: 28,
      child: DropdownButton<String>(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        value: loc.currentCountryCode.toLowerCase(),
        dropdownColor: Get.theme.dropdownMenuTheme.menuStyle?.backgroundColor?.resolve({}),
        icon: SizedBox.shrink(),
        items: Language.values.map((value) {
          return DropdownMenuItem<String>(
            value: value.name,
            child: SizedBox(
              width: 30,
              height: 20,
              child: CountryFlag.fromCountryCode(value.name),
            )
          );
        }).toList(),
        onChanged: (newValue) {
          loc.changeLocale(languageToLocale[Language.values.byName(newValue!)]!);
        }
      )
    );
  }

  Widget mode() {
    return Switch(
      thumbIcon: WidgetStatePropertyAll(
        isDarkMode ? Icon(Icons.dark_mode) : Icon(Icons.light_mode)
      ),
      value: isDarkMode,
      onChanged: (value) {
        Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
        setState(() { isDarkMode = value; });
      }
    );
  }

  Widget addEntryButton() {
    return FloatingActionButton(
      onPressed: () async {
        final result = await showDialog<CashFlowEntry>(
          context: context,
          builder: (context) => AddCashFlowEntryDialog(),
        );

        controller.handleSave(result);
      },
      backgroundColor: Get.theme.colorScheme.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

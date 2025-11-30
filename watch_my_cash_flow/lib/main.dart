import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:watch_my_cash_flow/app/services/localization_service.dart';
import 'package:watch_my_cash_flow/app/services/supabase_service.dart';
import 'package:watch_my_cash_flow/app/translations/app_translations.dart';
import 'package:watch_my_cash_flow/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // load .env
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
  await SupabaseService().init(url: supabaseUrl, anonKey: supabaseAnonKey);

  await initializeDateFormatting();

  // Initialize localization service
  await Get.putAsync(() => LocalizationService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: AppTranslations(),
      fallbackLocale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF181A1B),
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18)
        ),
        brightness: Brightness.dark,
        cardTheme: CardThemeData(
          color: Color(0xFF1F2123),
          margin: EdgeInsets.all(0),
          elevation: .2,
          shadowColor: Colors.black.withAlpha(20),
        ),
        datePickerTheme: DatePickerThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Color(0xFF1F2123),
        ),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF2ED6A8),
          onPrimary: Colors.black,
          secondary: const Color(0xFF2ED6A8),
          onSecondary: Colors.black,
          surface: const Color(0xFFE3E3E3),      // day in month text
          surfaceContainerHighest: const Color(0xFF777777), // day NOT in month text
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Color(0xFF181A1B),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(Color(0xFF1F2123)),
          ),
        ),
        scaffoldBackgroundColor: Color(0xFF181A1B),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStatePropertyAll(Color(0xFFFFFFFF)),
          trackColor: WidgetStatePropertyAll(Color(0xFFFFFFFF).withAlpha(100)),
          overlayColor: WidgetStatePropertyAll(Color(0xFFFFFFFF).withAlpha(50)),
          trackOutlineColor: WidgetStatePropertyAll(Color(0xFFFFFFFF).withAlpha(100)),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFE3E3E3)),
          // headlineLarge: TextStyle(color: Colors.white),
          // headlineMedium: TextStyle(color: Colors.white),
          // headlineSmall: TextStyle(color: Colors.white),
          // bodySmall: TextStyle(color: Colors.white),
          // labelMedium: TextStyle(color: Colors.white),
          // labelLarge: TextStyle(color: Colors.white),
          // displayMedium: TextStyle(color: Colors.white),
          // displayLarge: TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          centerTitle: true,
          titleTextStyle: TextStyle(color: Color(0xFF111111), fontSize: 18)
        ),
        brightness: Brightness.light,
        cardTheme: CardThemeData(
          color: Color(0xFFFFFFFF),
          margin: EdgeInsets.all(0),
          elevation: .2,
          shadowColor: Colors.grey.withAlpha(20),
        ),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF008940), // seed color
          onPrimary: Colors.white,
          secondary: const Color(0xFF009A88),
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: const Color(0xFF111111),          // day in month text
          surfaceContainerHighest: const Color(0xFFAAAAAA),     // day NOT in month text
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Color(0xFFFFFFFF),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(Color(0xFFFFFFFF)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Color(0xFF111111).withAlpha(150)),
        ),
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStatePropertyAll(Color(0xFF111111)),
          trackColor: WidgetStatePropertyAll(Color(0xFF111111).withAlpha(100)),
          overlayColor: WidgetStatePropertyAll(Color(0xFF111111).withAlpha(50)),
          trackOutlineColor: WidgetStatePropertyAll(Color(0xFF111111).withAlpha(100)),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF111111)),
          // headlineLarge: TextStyle(color: Colors.white),
          // headlineMedium: TextStyle(color: Colors.white),
          // headlineSmall: TextStyle(color: Colors.white),
          // bodySmall: TextStyle(color: Colors.white),
          // labelMedium: TextStyle(color: Colors.white),
          // labelLarge: TextStyle(color: Colors.white),
          // displayMedium: TextStyle(color: Colors.white),
          // displayLarge: TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: MainPage(),
    );
  }
}

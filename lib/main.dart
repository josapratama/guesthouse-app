import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/network/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi locale Indonesia untuk format tanggal
  await initializeDateFormatting('id_ID', null);
  runApp(
    // ProviderScope wajib untuk Riverpod
    const ProviderScope(child: GuestHouseApp()),
  );
}

class GuestHouseApp extends ConsumerWidget {
  const GuestHouseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 Pro baseline
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Guest House App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        );
      },
    );
  }
}

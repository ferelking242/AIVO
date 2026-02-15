import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aivo/providers/product_provider.dart';
import 'package:aivo/providers/theme_provider.dart';
import 'package:aivo/providers/search_provider.dart';
import 'package:aivo/providers/review_provider.dart';
import 'package:aivo/providers/notification_provider.dart';
import 'package:aivo/screens/splash/splash_screen.dart';

import 'config/supabase_config.dart';
import 'routes.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    await AuthService.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } catch (e) {
    print('Failed to initialize Supabase: $e');
    print('Make sure to update SupabaseConfig with your credentials');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize notifications after app is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await context.read<NotificationProvider>().initializeNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AIVO - E-Commerce',
          theme: themeProvider.getTheme(),
          initialRoute: SplashScreen.routeName,
          routes: routes,
        ),
      ),
    );
  }
}

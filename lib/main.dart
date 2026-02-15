import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aivo/providers/product_provider.dart';
import 'package:aivo/providers/theme_provider.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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

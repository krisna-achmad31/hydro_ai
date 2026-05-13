import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydro_ai/provider/pond_provider.dart';
import 'package:hydro_ai/screen/dashboard_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  // 1. Pastikan binding Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load environment variables dari .env
  await dotenv.load(fileName: ".env");

  // 3. Inisialisasi Firebase
  // Pastikan Mas sudah download google-services.json (Android)
  // atau GoogleService-Info.plist (iOS)
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 3. Registrasikan PondProvider di sini
        ChangeNotifierProvider(create: (_) => PondProvider()),
      ],
      child: MaterialApp(
        title: 'HydroNeo AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // Mengatur font agar mirip dengan style Smart Farm (Clean)
          fontFamily: 'Roboto',
        ),
        // 4. Set Dashboard sebagai halaman utama
        home: DashboardScreen(),
      ),
    );
  }
}
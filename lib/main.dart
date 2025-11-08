import 'package:flutter/material.dart';
import 'package:ras/screens/login_screen.dart';
import 'package:ras/screens/splash_screen.dart';
import 'package:ras/screens/upload_screen.dart';
import 'package:ras/screens/viewer_screen.dart';
import 'package:ras/utils/session_manager.dart';
import 'widgets/custom_button.dart';
import 'screens/settings_page.dart';
import 'widgets/auth_guard.dart'; // <- importar AuthGuard

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Primera App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        // Rutas privadas envueltas en AuthGuard
        '/home': (context) => const AuthGuard(child: HomePage()),
        '/upload': (context) => const AuthGuard(child: UploadScreen()),
        '/viewer': (context) => const AuthGuard(child: ViewerScreen()),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String _logoUrl = 'https://ras.webintegral.cl/backend/assets/img/logo.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Inicio'),
            const SizedBox(height: 6),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.network(
                    _logoUrl,
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // ... (DrawerHeader, etc.)
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Página Principal'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () async {
                final sessionManager = SessionManager();
                await sessionManager.deleteToken();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenido a la App de Ras! 👋',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Subir Imágenes',
              onPressed: () {
                Navigator.pushNamed(context, '/upload');
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Visualizar Imágenes',
              onPressed: () {
                Navigator.pushNamed(context, '/viewer');
              },
            ),
          ],
        ),
      ),
    );
  }
}

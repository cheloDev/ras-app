import 'package:flutter/material.dart';
import 'package:ras/screens/login_screen.dart';
import 'package:ras/screens/splash_screen.dart';
import 'package:ras/screens/upload_screen.dart';
import 'package:ras/screens/viewer_screen.dart';
import 'package:ras/utils/session_manager.dart';
import 'widgets/custom_button.dart';
import 'screens/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la cinta de "Debug"
      title: 'Mi Primera App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
        '/upload': (context) => const UploadScreen(),
        '/viewer': (context) => const ViewerScreen(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // ... (DrawerHeader, etc.)

            // Primer elemento (Página Principal)
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Página Principal'),
              onTap: () {
                // Lógica de "onTap" para la Página Principal
                Navigator.pop(context); // Solo cierra el menú
              },
            ),

            // 🎯 ESTE ES EL ELEMENTO DE CONFIGURACIÓN QUE DEBES MODIFICAR
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              // ⬇️ MÉTODOS "onTap" VACÍOS ANTES DE MODIFICAR:
              // onTap: () {
              //   // Aquí estaba vacío o con solo Navigator.pop(context);
              // },
              // ⬇️ CÓDIGO FINAL DE NAVEGACIÓN DENTRO DE "onTap":
              onTap: () {
                // 1. Cierra el menú lateral (es importante hacerlo primero)
                Navigator.pop(context);

                // 2. Ejecuta la navegación a la nueva pantalla
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Asegúrate de que SettingsPage esté importada
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),

            // ... (Otros ListTile o Divider)
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
              '¡Hola, Marcelo! 👋',
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

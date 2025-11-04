import 'package:flutter/material.dart';
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
      home: const HomePage(),
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
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¡RAS, Capturador de Fotos! 👋',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Tomar Foto',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Componente Reutilizado! 🎉')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

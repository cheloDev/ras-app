import 'package:flutter/material.dart';

class ViewerScreen extends StatefulWidget {
  const ViewerScreen({super.key});

  @override
  _ViewerScreenState createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _siniestroController = TextEditingController();
  final _patenteController = TextEditingController();
  List<String> _imageUrls = [];
  bool _isLoading = false;

  Future<void> _fetchImages() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Mock image fetching
      await Future.delayed(const Duration(seconds: 2));
      final List<String> fetchedImages = await _mockFetchImages();

      setState(() {
        _imageUrls = fetchedImages;
        _isLoading = false;
      });
    }
  }

  Future<List<String>> _mockFetchImages() async {
    // Simulate a call to an API that returns a JSON with image URLs
    // For now, we'll return a list of placeholder images.
    if (_siniestroController.text.isNotEmpty && _patenteController.text.isNotEmpty) {
      return [
        'https://via.placeholder.com/150',
        'https://via.placeholder.com/150',
        'https://via.placeholder.com/150',
        'https://via.placeholder.com/150',
        'https://via.placeholder.com/150',
      ];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar Imágenes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _siniestroController,
                decoration: const InputDecoration(labelText: 'Nro de Siniestro'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nro de siniestro';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _patenteController,
                decoration: const InputDecoration(labelText: 'Patente'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la patente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _fetchImages,
                      child: const Text('Buscar Imágenes'),
                    ),
              const SizedBox(height: 20),
              Expanded(
                child: _imageUrls.isEmpty
                    ? const Center(child: Text('No hay imágenes para mostrar.'))
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: _imageUrls.length,
                        itemBuilder: (context, index) {
                          return Image.network(_imageUrls[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

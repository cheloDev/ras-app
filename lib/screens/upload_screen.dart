// dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:ras/utils/image_resizer.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _siniestroController = TextEditingController();
  final _patenteController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  bool _isLoading = false;

  // Nuevo: controla si los botones de cámara/galería deben mostrarse
  bool _canPickImages = false;

  @override
  void initState() {
    super.initState();
    _siniestroController.addListener(_onFieldsChanged);
    _patenteController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() {
    // Llama a la comprobación (async) cada vez que cambian los campos
    _checkValidation();
  }

  Future<void> _checkValidation() async {
    final siniestro = _siniestroController.text.trim();
    final patente = _patenteController.text.trim();

    if (siniestro.isNotEmpty && patente.isNotEmpty) {
      final valid = await _mockValidateSiniestro();
      if (mounted) {
        setState(() {
          _canPickImages = valid;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _canPickImages = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes subir más de 5 imágenes.')),
      );
      return;
    }
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  Future<void> _uploadImages() async {
    if (_formKey.currentState!.validate() && _images.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      // Mock validation and upload
      await Future.delayed(const Duration(seconds: 2));
      final bool isValid = await _mockValidateSiniestro();

      if (isValid) {
        final bool isSuccess = await _mockUpload();
        if (isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imágenes subidas con éxito')),
          );
          setState(() {
            _images.clear();
            _siniestroController.clear();
            _patenteController.clear();
            _canPickImages = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir las imágenes')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Nro de siniestro o patente no válidos')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos y seleccione al menos una imagen.')),
      );
    }
  }

  Future<bool> _mockValidateSiniestro() async {
    // Simulate a call to https://ras.webintegral.cl/api/get-siniestro
    await Future.delayed(const Duration(milliseconds: 300)); // small delay para simular llamada
    return _siniestroController.text.isNotEmpty && _patenteController.text.isNotEmpty;
  }

  Future<bool> _mockUpload() async {
    // Simulate the process of resizing and converting images to binary
    try {
      final List<Uint8List> binaryImages = [];
      for (final image in _images) {
        final binaryImage = await resizeImage(File(image.path));
        binaryImages.add(binaryImage);
      }
      // In a real scenario, you would send the binaryImages to the API.
      // For now, we'll just print the size of the binary data.
      print('Total binary size of images: ${binaryImages.fold(0, (sum, item) => sum + item.length)} bytes');
      return true; // Simulate a successful upload
    } catch (e) {
      print('Error resizing images: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _siniestroController.removeListener(_onFieldsChanged);
    _patenteController.removeListener(_onFieldsChanged);
    _siniestroController.dispose();
    _patenteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Imágenes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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

                // Los botones solo aparecen si _canPickImages es true
                if (_canPickImages)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera),
                        label: const Text('Cámara'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galería'),
                      ),
                    ],
                  )
                else
                  const Text(
                    'Ingrese Nro de Siniestro y Patente válidos para activar Cámara y Galería.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),

                const SizedBox(height: 20),
                _images.isEmpty
                    ? const Text('No hay imágenes seleccionadas.')
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Image.file(File(_images[index].path));
                  },
                ),
                const SizedBox(height: 20),
                // El botón se deshabilita cuando no hay imágenes (\_images.isEmpty)
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _images.isNotEmpty ? _uploadImages : null,
                  child: const Text('Subir Imágenes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
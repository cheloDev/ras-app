//dart
// File: lib/screens/upload_screen.dart
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:ras/utils/image_resizer.dart';
import 'package:http/http.dart' as http;
import 'package:ras/services/auth_service.dart';
import 'package:mime/mime.dart';

import '../config.dart';

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
  bool _canPickImages = false;

  // Nuevo: almacenar el id real del siniestro retornado por get-by-patente
  String? _siniestroId;

  @override
  void initState() {
    super.initState();
    _siniestroController.addListener(_onFieldsChanged);
    _patenteController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() {
    setState(() {});
  }

  Future<void> _pickImage(ImageSource source) async {
    const int maxImages = 5;

    // Lógica para galería (sin cambios)
    if (source == ImageSource.gallery) {
      final remaining = maxImages - _images.length;
      if (remaining <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya alcanzaste el máximo de 5 imágenes.')),
        );
        return;
      }
      try {
        final List<XFile>? pickedFiles = await _picker.pickMultiImage();
        if (pickedFiles == null || pickedFiles.isEmpty) return;
        final toAdd = pickedFiles.take(remaining);
        setState(() {
          _images.addAll(toAdd);
        });
        if (pickedFiles.length > remaining) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Se agregaron solo $remaining imágenes (máx $maxImages).')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imágenes: $e')),
        );
      }
      return;
    }

    // Lógica para la cámara
    if (_images.length >= maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes subir más de 5 imágenes.')),
      );
      return;
    }

    // --- INICIO DE LA MODIFICACIÓN ---
    // Verificar permisos solo en Android o iOS
    if (Platform.isAndroid || Platform.isIOS) {
      final camStatus = await Permission.camera.status;
      if (!camStatus.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          if (result.isPermanentlyDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso de cámara denegado. Habilítalo en la configuración.')),
            );
            await openAppSettings();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso de cámara denegado.')),
            );
          }
          return;
        }
      }
    }
    // --- FIN DE LA MODIFICACIÓN ---

    // Abrir cámara, tomar foto, redimensionar y agregar a la grilla
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return; // El usuario canceló

      final Uint8List bytes = await resizeImage(File(image.path));

      final String dir = (await Directory.systemTemp.createTemp()).path;
      final String targetPath = p.join(dir, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      final File resizedFile = File(targetPath);
      await resizedFile.writeAsBytes(bytes);

      setState(() {
        _images.add(XFile(resizedFile.path));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la imagen: $e')),
      );
    }
  }

  Future<void> _uploadImages() async {
    if (!(_formKey.currentState?.validate() ?? false) || _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos y seleccione al menos una imagen.')),
      );
      return;
    }

    if (_images.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes subir más de 5 imágenes.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await AuthService().getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token no encontrado. Por favor inicie sesión.')),
        );
        setState(() {
          _isLoading = false;
          _canPickImages = false;
        });
        return;
      }

      final List<String> encodedImages = [];
      for (final img in _images) {
        final bytes = await resizeImage(File(img.path));
        final base64Str = base64Encode(bytes);
        final mimeType = lookupMimeType(img.path, headerBytes: bytes) ?? 'image/jpeg';
        encodedImages.add('data:$mimeType;base64,$base64Str');
      }

      final uri = ApiConfig.uri(ApiEndpoints.siniestroUpload);
      final bodyMap = {
        'siniestro_id': _siniestroId ?? _siniestroController.text.trim(),
        'images': encodedImages,
      };

      final response = await http
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyMap),
      )
          .timeout(const Duration(seconds: 20));

      String serverMessage = 'Error desconocido';
      if (response.body.isNotEmpty) {
        try {
          final parsed = jsonDecode(response.body);
          if (parsed is Map && parsed['message'] != null) {
            serverMessage = parsed['message'].toString();
          } else if (parsed is Map && parsed['msg'] != null) {
            serverMessage = parsed['msg'].toString();
          } else {
            serverMessage = response.body.toString();
          }
        } catch (_) {
          serverMessage = response.body.toString();
        }
      }

      if (response.statusCode == 200) {
        // Solo limpiar la grilla de imágenes; mantener los inputs y _siniestroId
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(serverMessage.isNotEmpty ? serverMessage : 'Imágenes subidas correctamente.')),
        );
        setState(() {
          _images.clear();
          // mantener _siniestroController.text, _patenteController.text y _siniestroId
          _canPickImages = true; // permitir seguir agregando imágenes si se desea
        });
      } else {
        setState(() {
          _canPickImages = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error (${response.statusCode}): $serverMessage')),
        );
      }
    } catch (e) {
      setState(() {
        _canPickImages = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifySiniestro() async {
    final siniestro = _siniestroController.text.trim();
    final patente = _patenteController.text.trim();

    if (siniestro.isEmpty || patente.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nro de siniestro y patente no pueden estar vacíos.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await AuthService().getToken();

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token no encontrado. Por favor inicie sesión.')),
        );
        setState(() {
          _isLoading = false;
          _canPickImages = false;
        });
        return;
      }

      final uri = ApiConfig.uri(ApiEndpoints.siniestroGetByPatente);
      final response = await http
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nro_siniestro': siniestro,
          'patente': patente,
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // intentar extraer el id desde la estructura: { "siniestro": { "id": ... }, ... }
        try {
          final body = jsonDecode(response.body);
          if (body is Map) {
            if (body['siniestro'] is Map && body['siniestro']['id'] != null) {
              _siniestroId = body['siniestro']['id'].toString();
            } else if (body['id'] != null) {
              // fallback si el backend devuelve directamente id
              _siniestroId = body['id'].toString();
            }
          }
        } catch (_) {
          _siniestroId = null;
        }

        setState(() {
          _canPickImages = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Siniestro verificado. Puedes seleccionar imágenes.')),
        );
      } else {
        setState(() {
          _canPickImages = false;
          _siniestroId = null;
        });
        String message = 'Error al verificar siniestro (${response.statusCode})';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] != null) message = body['message'].toString();
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      setState(() {
        _canPickImages = false;
        _siniestroId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _mockValidateSiniestro() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _siniestroController.text.isNotEmpty && _patenteController.text.isNotEmpty;
  }

  Future<bool> _mockUpload() async {
    try {
      final List<Uint8List> binaryImages = [];
      for (final image in _images) {
        final binaryImage = await resizeImage(File(image.path));
        binaryImages.add(binaryImage);
      }
      print('Total binary size of images: ${binaryImages.fold(0, (sum, item) => sum + item.length)} bytes');
      return true;
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

  void _clearImages() {
    if (_images.isEmpty) return;
    setState(() {
      _images.clear();
      // mantener _siniestroController.text, _patenteController.text y _siniestroId
      _canPickImages = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Grilla de imágenes limpiada.')),
    );
  }

  void _clearFields() {
    if (_siniestroController.text.trim().isEmpty &&
        _patenteController.text.trim().isEmpty &&
        _siniestroId == null) return;

    setState(() {
      _siniestroController.clear();
      _patenteController.clear();
      _siniestroId = null;
      _canPickImages = false; // desactivar selección hasta verificar de nuevo
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Campos limpiados.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool fieldsNotEmpty = _siniestroController.text.trim().isNotEmpty && _patenteController.text.trim().isNotEmpty;
    final bool canClear = _siniestroController.text.trim().isNotEmpty ||
        _patenteController.text.trim().isNotEmpty ||
        _siniestroId != null;
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
                const SizedBox(height: 12),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: fieldsNotEmpty ? _verifySiniestro : null,
                      child: const Text('Continuar'),
                    ),
                    ElevatedButton(
                      onPressed: canClear ? _clearFields : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text('Limpiar'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                    'Ingrese Nro de Siniestro y Patente y presione Continuar para activar Cámara y Galería.',
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
                _isLoading
                    ? const CircularProgressIndicator()
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _images.isNotEmpty ? _clearImages : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text('Quitar Imágenes'),
                    ),
                    ElevatedButton(
                      onPressed: _images.isNotEmpty ? _uploadImages : null,
                      child: const Text('Subir Imágenes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // Verifica si la cámara está permitida
  static Future<bool> isCameraGranted() async {
    return Permission.camera.isGranted;
  }

  // Solicita permiso de cámara; abre settings si está permanentemente denegado
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }

  // Asegura que la cámara esté disponible: si es necesario solicita permiso
  static Future<bool> ensureCamera() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    return requestCamera();
  }

  // Solicita permiso de almacenamiento/galería (manejando iOS/Android)
  static Future<bool> requestGalleryPermission() async {
    if (Platform.isAndroid) {
      // En Android usamos storage (o READ_MEDIA_IMAGES en Android 13+, manejar según targetSdk)
      final status = await Permission.storage.request();
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      return status.isGranted;
    } else {
      // iOS: photos
      final status = await Permission.photos.request();
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      return status.isGranted;
    }
  }

  // Abre la configuración de la app
  static Future<bool> openAppSettings() {
    return openAppSettings();
  }
}
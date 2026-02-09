import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  static Future<bool> requestCamera(BuildContext context) async {
    return _request(context, Permission.camera, 'Se requiere acceso a la cámara para tomar fotos.');
  }

  static Future<bool> requestMic(BuildContext context) async {
    return _request(context, Permission.microphone, 'Se requiere acceso al micrófono para grabar audio.');
  }

  static Future<bool> requestStorage(BuildContext context) async {
    return _request(context, Permission.storage, 'Se requiere acceso a almacenamiento para guardar archivos.');
  }

  static Future<bool> _request(BuildContext context, Permission permission, String message) async {
    final status = await permission.request();
    if (status.isGranted) return true;
    if (status.isDenied || status.isPermanentlyDenied) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Permiso requerido'),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
                child: const Text('Ir a ajustes'),
              ),
            ],
          ),
        );
      }
      return false;
    }
    return false;
  }
}

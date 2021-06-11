import 'package:permission_handler/permission_handler.dart';

class CheckPermissions {
  static Future<bool> requestStoragePermission() async {
    var permission = await Permission.storage.request();
    if (permission.isDenied) {
      return false;
    } else {
      return true;
    }
  }
}

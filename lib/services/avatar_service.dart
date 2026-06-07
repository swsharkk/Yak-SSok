import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarService {
  static const _prefsKey = 'local_avatar_path';

  static final _picker = ImagePicker();

  static Future<String?> pickAndSave(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/avatar.jpg');
    await File(picked.path).copy(dest.path);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, dest.path);
    return dest.path;
  }

  static Future<String?> loadLocalPath() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_prefsKey);
    if (path == null) return null;
    return File(path).existsSync() ? path : null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_prefsKey);
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    }
    await prefs.remove(_prefsKey);
  }
}

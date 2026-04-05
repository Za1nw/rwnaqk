import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rwnaqk/controllers/profile/profile_store_service.dart';

class EditProfileService {
  EditProfileService(this._store);

  final ProfileStoreService _store;
  final ImagePicker _picker = ImagePicker();

  String initialName() => _store.name.value;
  String initialEmail() => _store.email.value;
  String passwordPreview() => _store.passwordPreview.value;
  String avatarPath() => _store.avatarPath.value;
  String avatarUrl() => _store.avatarUrl.value;

  bool canSave({
    required String name,
    required String email,
  }) {
    if (name.trim().isEmpty) return false;
    if (email.trim().isEmpty) return false;
    return true;
  }

  void saveProfile({
    required String name,
    required String email,
  }) {
    _store.updateProfile(
      nextName: name.trim(),
      nextEmail: email.trim(),
    );
  }

  Future<String?> pickAvatar(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1400,
      imageQuality: 88,
    );
    if (file == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    final extension = _extensionFor(file.path);
    final targetPath =
        '${directory.path}${Platform.pathSeparator}profile_avatar$extension';
    final targetFile = File(targetPath);

    if (targetFile.existsSync()) {
      targetFile.deleteSync();
    }

    final copied = await File(file.path).copy(targetPath);
    _store.updateAvatarPath(copied.path);
    return copied.path;
  }

  String _extensionFor(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1) return '.jpg';

    final ext = path.substring(dotIndex).trim().toLowerCase();
    if (ext.isEmpty || ext.length > 5) return '.jpg';
    return ext;
  }
}

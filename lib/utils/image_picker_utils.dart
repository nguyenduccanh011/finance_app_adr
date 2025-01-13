import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerUtils {
  static final ImagePicker _picker = ImagePicker();

  // Chụp ảnh từ camera
  static Future<File?> pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Chọn ảnh từ thư viện
  static Future<File?> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  static Future<List<int>> compressImage(File imageFile) async {
    // Có thể sử dụng các thư viện nén ảnh để thay thế
    return await imageFile.readAsBytes();
  }
}

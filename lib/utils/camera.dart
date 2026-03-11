import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraUtils {
  static final ImagePicker _picker = ImagePicker();


  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
    return null;
  }
}

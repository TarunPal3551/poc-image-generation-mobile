import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_pick/Repository/fileuploader.dart';

class ImageController extends GetxController {
  final picker = ImagePicker();
  RxList<File> selectedImages = <File>[].obs;
  RxList<String> imageUrls = <String>[].obs;

  final FileUploadRepo _fileUploadRepo = FileUploadRepo();

  Future<void> pickImage() async {
    if (selectedImages.length >= 5) return;

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      selectedImages.add(imageFile);

      try {
        String imageUrl = await _fileUploadRepo.uploadFile(imageFile);
        if (imageUrl.isNotEmpty) {
          imageUrls.add(imageUrl);
          print("Uploaded URL: $imageUrl");
        } else {
          print("Failed to get image URL");
        }
      } catch (e) {
        print("Upload failed: $e");
      }
    }
  }
}

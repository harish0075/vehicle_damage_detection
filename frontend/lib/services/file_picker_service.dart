import 'dart:io';
import 'package:file_picker/file_picker.dart';

class FilePickerService {
  /// Pick PDF file
  Future<File?> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw 'Error picking PDF: $e';
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Plugin-free result so widget tests can supply a fake without a camera.
class PickedDocument {
  const PickedDocument({required this.path, required this.name});

  final String path;
  final String name;
}

enum PickSource { camera, gallery }

abstract class DocumentPicker {
  const DocumentPicker();

  Future<PickedDocument?> pick(PickSource source);
}

class ImagePickerDocumentPicker implements DocumentPicker {
  const ImagePickerDocumentPicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<PickedDocument?> pick(PickSource source) async {
    final file = await _picker.pickImage(
      source: source == PickSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (file == null) return null;
    return PickedDocument(path: file.path, name: file.name);
  }
}

final documentPickerProvider = Provider<DocumentPicker>((ref) {
  return ImagePickerDocumentPicker(ImagePicker());
});

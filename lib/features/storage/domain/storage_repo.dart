import 'dart:typed_data';

abstract class StorageRepo {
  Future<String?> uploadProfileImageMobile(String path, String fileName);

  Future<String?>  uploadProfileImageWeb(Uint8List fileBytes, String fileName);

  Future<String?> uploadPostImageMobile(String path, String fileName);

  Future<String?>  uploadPostImageWeb(Uint8List fileBytes, String fileName);
}
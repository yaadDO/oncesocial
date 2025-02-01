//FirebaseStorageRepo class is an implementation of the StorageRepo interface, designed to handle file uploads to Firebase Storage

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import '../domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo {

  //Singleton instance of FirebaseStorage
  final FirebaseStorage storage = FirebaseStorage.instance;

  //path = Local file path of the image
  // ? to ensure Null Safety.
  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, 'profile_images');
  }

  //Uint8List = The image data as a byte array
  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
   return _uploadFileBytes(fileBytes, fileName, 'profile_images');
  }

  @override
  Future<String?> uploadPostImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, 'post_images');
  }

  @override
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, 'post_images');
  }

  //Handles file uploads for mobile platforms, where the file is located using a local file path.
  Future<String?> _uploadFile(String path, String fileName,
      String folder) async {
    try {
      final file = File(path);

      //Creates a reference to the Firebase Storage location ('$folder/$fileName').
      final storageRef = storage.ref().child('$folder/$fileName');

      final uploadTask = await storageRef.putFile(file);

      //Retrieves and returns the download URL using getDownloadURL so the file can be accessed publicly.
      final downloaderUrl = await uploadTask.ref.getDownloadURL();

      return downloaderUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _uploadFileBytes(Uint8List fileBytes, String fileName,
      String folder) async {
    try {
      final storageRef = storage.ref().child('$folder/$fileName');

      final uploadTask = await storageRef.putData(fileBytes);

      final downloaderUrl = await uploadTask.ref.getDownloadURL();

      return downloaderUrl;
    } catch (e) {
      return null;
    }
  }
}
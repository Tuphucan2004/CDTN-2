import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  // ===== UPLOAD POST IMAGE =====
  Future<String> uploadPostImageBytes(Uint8List bytes) async {
    try {
      final fileName =
          "posts/${DateTime.now().millisecondsSinceEpoch}.jpg";

      final ref = storage.ref().child(fileName);

      print(" UPLOADING: $fileName");

      final metadata = SettableMetadata(
        contentType: "image/jpeg",
      );

      final uploadTask = ref.putData(bytes, metadata);

      // Theo dõi tiến trình (debug)
      uploadTask.snapshotEvents.listen((event) {
        print(
            " PROGRESS: ${event.bytesTransferred}/${event.totalBytes}");
      });

      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final url = await snapshot.ref.getDownloadURL();

        print(" POST IMAGE URL: $url");

        return url;
      } else {
        throw Exception("Upload failed");
      }
    } catch (e) {
      print(" UPLOAD POST ERROR: $e");
      rethrow;
    }
  }

  // ===== UPLOAD AVATAR =====
  Future<String> uploadAvatarBytes(Uint8List bytes, String uid) async {
    try {
      final fileName = "avatars/$uid.jpg";

      final ref = storage.ref().child(fileName);

      print(" UPLOADING AVATAR: $fileName");

      final metadata = SettableMetadata(
        contentType: "image/jpeg",
      );

      final uploadTask = ref.putData(bytes, metadata);

      uploadTask.snapshotEvents.listen((event) {
        print(
            " AVATAR PROGRESS: ${event.bytesTransferred}/${event.totalBytes}");
      });

      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final url = await snapshot.ref.getDownloadURL();

        print("AVATAR URL: $url");

        return url;
      } else {
        throw Exception("Upload avatar failed");
      }
    } catch (e) {
      print(" UPLOAD AVATAR ERROR: $e");
      rethrow;
    }
  }

  // ===== UPLOAD CHAT IMAGE =====
  Future<String> uploadChatImageBytes(Uint8List bytes, String chatId) async {
    try {
      final fileName = "chat_images/$chatId/${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = storage.ref().child(fileName);

      final metadata = SettableMetadata(contentType: "image/jpeg");
      final uploadTask = ref.putData(bytes, metadata);

      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      } else {
        throw Exception("Upload chat image failed");
      }
    } catch (e) {
      print(" UPLOAD CHAT IMAGE ERROR: $e");
      rethrow;
    }
  }
}
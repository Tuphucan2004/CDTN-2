import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final caption = TextEditingController();
  final db = FirestoreService();
  final storage = StorageService();

  Uint8List? imageBytes;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();

      setState(() {
        imageBytes = bytes;
      });
    }
  }

  Future<void> post() async {
    if (imageBytes == null || caption.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chọn ảnh + nhập caption")),
      );
      return;
    }

    try {
      final imageUrl =
      await storage.uploadPostImageBytes(imageBytes!);

      await db.createPost(imageUrl, caption.text.trim());

      if (!mounted) return;

      Navigator.of(context).pop();

      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng bài thành công")),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  @override
  void dispose() {
    caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post"),
        actions: [
          TextButton(
            onPressed: post,
            child: const Text("Post",
                style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey[300],
                child: imageBytes == null
                    ? const Icon(Icons.add_a_photo, size: 50)
                    : Image.memory(imageBytes!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: caption,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Viết caption...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
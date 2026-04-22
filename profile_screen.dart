import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final db = FirestoreService();
  final storage = StorageService();
  final picker = ImagePicker();

  Future<void> changeAvatar() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      try {
        final bytes = await picked.readAsBytes();
        final user = FirebaseAuth.instance.currentUser;

        final url =
        await storage.uploadAvatarBytes(bytes, user!.uid);

        await db.updateAvatar(url);

        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi avatar: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder(
        future: db.getProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
          snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: changeAvatar,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: (data["avatar"] != null &&
                          data["avatar"].toString().isNotEmpty)
                          ? NetworkImage(data["avatar"])
                          : null,
                      child: (data["avatar"] == null ||
                          data["avatar"] == "")
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                  ),

                  StreamBuilder(
                    stream: db.getPosts(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return _stat("0", "Posts");
                      }

                      final count = snapshot.data!.docs
                          .where((d) => d["userId"] == user.uid)
                          .length;

                      return _stat(count.toString(), "Posts");
                    },
                  ),

                  _stat(data["followers"].toString(), "Followers"),
                  _stat(data["following"].toString(), "Following"),
                ],
              ),

              const SizedBox(height: 10),

              Text(data["name"],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold)),
              Text(data["bio"] ?? ""),

              const SizedBox(height: 20),

              Expanded(
                child: StreamBuilder(
                  stream: db.getPosts(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final posts = snapshot.data!.docs
                        .where((d) => d["userId"] == user.uid)
                        .toList();

                    if (posts.isEmpty) {
                      return const Center(
                          child: Text("No posts yet"));
                    }

                    return GridView.builder(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index].data()
                        as Map<String, dynamic>;

                        return Image.network(
                          post["image"],
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                          const Icon(Icons.broken_image),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String n, String label) {
    return Column(
      children: [
        Text(n,
            style:
            const TextStyle(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}
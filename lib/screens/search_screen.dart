import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  String keyword = "";

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Tìm kiếm người dùng...",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              keyword = value.toLowerCase();
            });
          },
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final name =
            (data["name"] ?? "").toString().toLowerCase();

            return name.contains(keyword);
          }).toList();

          if (users.isEmpty) {
            return const Center(child: Text("Không tìm thấy"));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data =
              users[index].data() as Map<String, dynamic>;

              final isMe = data["uid"] == currentUser?.uid;

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProfileScreen(uid: data["uid"]),
                    ),
                  );
                },

                leading: CircleAvatar(
                  backgroundImage:
                  (data["avatar"] != null &&
                      data["avatar"] != "")
                      ? NetworkImage(data["avatar"])
                      : null,
                  child: (data["avatar"] == null ||
                      data["avatar"] == "")
                      ? const Icon(Icons.person)
                      : null,
                ),

                title: Text(
                  data["name"] ?? "User",
                  style: TextStyle(
                    fontWeight:
                    isMe ? FontWeight.bold : FontWeight.normal,
                    color: isMe ? Colors.blue : null,
                  ),
                ),

                subtitle: isMe ? const Text("Bạn") : null,
              );
            },
          );
        },
      ),
    );
  }
}
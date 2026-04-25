import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';
import 'chat_screen.dart';
import 'profile_screen.dart'; // 👈 THÊM

class FriendScreen extends StatelessWidget {
  const FriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Bạn bè")),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.getUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data["uid"] != currentUser?.uid;
          }).toList();

          return ListView(
            children: users.map((doc) {
              final user = doc.data() as Map<String, dynamic>;

              return FutureBuilder<Map<String, dynamic>>(
                future: db.getFriendStatusWithDoc(user["uid"]),
                builder: (context, snap) {
                  final status = snap.data?["status"] ?? "none";

                  Widget trailing;

                  if (status == "accepted") {
                    trailing = ElevatedButton(
                      child: const Text("Chat"),
                      onPressed: () async {
                        final chatId =
                        await db.createChat(user["uid"]);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chatId,
                              otherUserName: user["name"],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (status == "pending") {
                    trailing = const Text("Đã gửi");
                  } else if (status == "request") {
                    trailing = ElevatedButton(
                      child: const Text("Chấp nhận"),
                      onPressed: () async {
                        await db.acceptFriend(user["uid"]);
                      },
                    );
                  } else {
                    trailing = ElevatedButton(
                      child: const Text("Kết bạn"),
                      onPressed: () async {
                        await db.sendFriendRequest(user["uid"]);
                      },
                    );
                  }

                  return ListTile(
                    // 👇 CLICK AVATAR → PROFILE
                    leading: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProfileScreen(uid: user["uid"]),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundImage: (user["avatar"] != null &&
                            user["avatar"] != "")
                            ? NetworkImage(user["avatar"])
                            : null,
                        child: (user["avatar"] == null ||
                            user["avatar"] == "")
                            ? const Icon(Icons.person)
                            : null,
                      ),
                    ),

                    title: Text(user["name"] ?? "Unknown"),
                    subtitle: Text(user["email"] ?? ""),
                    trailing: trailing,
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final db = FirestoreService();

  @override
  void initState() {
    super.initState();
    markAllAsRead(); // 🔴 vào màn là xóa badge
  }

  // ================= MARK AS READ =================
  Future<void> markAllAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final snap = await FirebaseFirestore.instance
        .collection("notifications")
        .where("to", isEqualTo: currentUser.uid)
        .where("read", isEqualTo: false)
        .get();

    for (var doc in snap.docs) {
      await doc.reference.update({"read": true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông báo"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.getNotifications(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notis = snapshot.data!.docs;

          if (notis.isEmpty) {
            return const Center(child: Text("Không có thông báo"));
          }

          return ListView.builder(
            itemCount: notis.length,
            itemBuilder: (context, index) {
              final n =
              notis[index].data() as Map<String, dynamic>;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("users")
                    .doc(n["from"])
                    .get(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const SizedBox();
                  }

                  final user =
                      snap.data!.data() as Map<String, dynamic>? ?? {};

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                      (user["avatar"] != null &&
                          user["avatar"] != "")
                          ? NetworkImage(user["avatar"])
                          : null,
                      child: (user["avatar"] == null ||
                          user["avatar"] == "")
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      "${user["name"] ?? "User"} "
                          "${n["type"] == "like" ? "đã thích bài viết" : "đã bình luận"}",
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
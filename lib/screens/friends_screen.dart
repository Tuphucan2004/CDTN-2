import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

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

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user =
              users[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                    NetworkImage(user["avatar"] ?? ""),
                  ),
                  title: Text(
                    user["name"] ?? "No name",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user["email"] ?? ""),

                  trailing: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Follow ${user["name"]} (chưa làm backend 😄)")),
                      );
                    },
                    child: const Text("Follow"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
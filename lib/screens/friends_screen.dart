import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  final List friends = const [
    {"name": "Giang"},
    {"name": "Nam"},
    {"name": "Hà"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Friends")),
      body: Center(
        child: Container(
          width: 400,
          child: ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(friends[index]["name"]!),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    child: const Text("Add"),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
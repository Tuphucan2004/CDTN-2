import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List friends = [];
  bool isLoading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future fetchFriends() async {
    try {
      final url = kIsWeb
          ? "http://localhost:3000/api/friends"   //  WEB
          : "http://10.0.2.2:3000/api/friends";   //  ANDROID

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        setState(() {
          friends = json.decode(res.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Lỗi server: ${res.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Không kết nối được backend";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    final bgColor = isMobile ? Colors.black : Colors.white;
    final textColor = isMobile ? Colors.white : Colors.black;
    final cardColor = isMobile ? Colors.grey[900] : Colors.white;

    return Container(
      color: bgColor,

      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(
        child: Text(
          error,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final f = friends[index];

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (!isMobile)
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),

              leading: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey,
                child: const Icon(Icons.person,
                    color: Colors.white),
              ),

              title: Text(
                f["name"] ?? "",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

              subtitle: Text(
                "Gợi ý kết bạn",
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),

              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: const Text("Add"),
              ),
            ),
          );
        },
      ),
    );
  }
}
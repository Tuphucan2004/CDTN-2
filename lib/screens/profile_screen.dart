import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map profile = {};
  bool isLoading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future fetchProfile() async {
    try {
      final url = kIsWeb
          ? "http://localhost:3000/api/profile"   // 🌐 WEB
          : "http://10.0.2.2:3000/api/profile";   // 📱 ANDROID

      final res = await http.get(Uri.parse(url));

      print("PROFILE URL: $url");
      print("STATUS: ${res.statusCode}");

      if (res.statusCode == 200) {
        setState(() {
          profile = json.decode(res.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Server lỗi: ${res.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Không kết nối được backend";
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final textColor = isMobile ? Colors.white : Colors.black;
    final bgColor = isMobile ? Colors.black : Colors.white;

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
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// AVATAR
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profile["avatar"] ?? ""),
            ),

            const SizedBox(height: 10),

            /// NAME
            Text(
              profile["name"] ?? "",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 5),

            /// BIO
            Text(
              profile["bio"] ?? "",
              style: TextStyle(color: textColor),
            ),

            const SizedBox(height: 20),

            /// STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildStat("Posts", profile["posts"], textColor),
                buildStat("Followers", profile["followers"], textColor),
                buildStat("Following", profile["following"], textColor),
              ],
            ),

            const SizedBox(height: 20),

            /// BUTTON
            ElevatedButton(
              onPressed: () {},
              child: const Text("Edit Profile"),
            ),

            const SizedBox(height: 20),

            /// GRID POSTS FAKE
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                return Image.network(
                  "https://picsum.photos/200?random=$index",
                  fit: BoxFit.cover,
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildStat(String label, dynamic value, Color color) {
    return Column(
      children: [
        Text(
          "$value",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
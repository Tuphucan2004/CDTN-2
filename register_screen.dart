import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final name = TextEditingController();

  DateTime? selectedDate;

  final auth = AuthService();
  final db = FirestoreService();

  // ================= REGISTER =================
  void register() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chọn ngày sinh ")),
      );
      return;
    }

    final user = await auth.register(email.text, pass.text);

    if (user != null) {
      await db.createUserProfile(
        name.text,
        user.uid,
        user.email!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công ")),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thất bại ")),
      );
    }
  }

  // ================= PICK DATE =================
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.grey.withOpacity(0.2),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Đăng Ký Tài Khoản Mới",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // NAME
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: "Tên",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              // EMAIL
              TextField(
                controller: email,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              // PASSWORD
              TextField(
                controller: pass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mật Khẩu",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              // DATE PICKER
              GestureDetector(
                onTap: pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    selectedDate == null
                        ? "Chọn ngày sinh"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: register,
                  child: const Text("Tạo Tài Khoản"),
                ),
              ),

              const SizedBox(height: 10),

              // BACK TO LOGIN
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Đã có tài khoản? Đăng nhập"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController musicExperienceController =
      TextEditingController();

  DateTime? selectedBirthday;
  bool isLogin = true;
  bool isLoading = false;
  bool isPasswordVisible = false;
  File? profileImage;

  Future<void> _requestPermission() async {
    final status = await Permission.photos.request();
    if (status.isDenied || status.isRestricted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Permission to access gallery is denied.')),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    await _requestPermission();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  void _removeProfileImage() {
    setState(() {
      profileImage = null;
    });
  }

  Future<String> _uploadToFirebaseStorage(File image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final fileName =
        'profileImages/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final imageRef = storageRef.child(fileName);

    await imageRef.putFile(image);
    return await imageRef.getDownloadURL();
  }

  Future<void> _selectBirthday() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        selectedBirthday = picked;
      });
    }
  }

  Future<void> _authenticate() async {
    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        if (usernameController.text.isEmpty ||
            emailController.text.isEmpty ||
            passwordController.text.isEmpty ||
            selectedBirthday == null ||
            musicExperienceController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All fields are required.')),
          );
          return;
        }

        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        String profileImageUrl = 'assets/profile.png';
        if (profileImage != null) {
          profileImageUrl = await _uploadToFirebaseStorage(profileImage!);
        }

        final userId = userCredential.user!.uid;
        await _firestore.collection('users').doc(userId).set({
          'userId': userId,
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'birthday': selectedBirthday!.toIso8601String(),
          'musicExperience': musicExperienceController.text.trim(),
          'bio': '',
          'profileImageUrl': profileImageUrl,
          'followers': 0,
          'following': 0,
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Luna', // Add the name 'Luna' here
          style: TextStyle(
              color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: ListView(
          children: [
            if (!isLogin) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : const AssetImage('assets/defaultProfile.png')
                          as ImageProvider,
                  child: profileImage == null
                      ? const Icon(Icons.camera_alt,
                          size: 50, color: Colors.white)
                      : null,
                ),
              ),
              if (profileImage != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _removeProfileImage,
                ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.white38),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: musicExperienceController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Music Making Experience',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.white38),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  selectedBirthday == null
                      ? 'Choose your birthday'
                      : 'Birthday: ${selectedBirthday!.toLocal()}'
                          .split(' ')[0],
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing:
                    const Icon(Icons.calendar_today, color: Colors.white70),
                onTap: _selectBirthday,
              ),
              const Divider(color: Colors.white24),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white38),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white38),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          const Color(0xFF9C27B0), // Text color white
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _authenticate,
                    child: Text(isLogin ? 'Login' : 'Register'),
                  ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(
                isLogin
                    ? 'New user? Register here'
                    : 'Already have an account? Login',
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

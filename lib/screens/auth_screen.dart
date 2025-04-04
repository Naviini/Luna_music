import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'Profile/profile_screen.dart'; // Navigate to Profile Screen

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  bool isLogin = true; // Toggle between login and register mode
  bool isLoading = false;
  bool isPasswordVisible = false; // Toggle password visibility
  File? profileImage;

  final ImagePicker _picker = ImagePicker();

  // Request permission to access the gallery
  Future<void> _requestPermission() async {
    final status = await Permission.photos.request();
    if (status.isDenied || status.isRestricted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission to access gallery is denied.')),
      );
    }
  }

  // Pick profile image from the gallery
  Future<void> _pickProfileImage() async {
    // Ensure permission is granted before picking an image
    await _requestPermission();

    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  // Remove profile image
  void _removeProfileImage() {
    setState(() {
      profileImage = null;
    });
  }

  // Upload image to Imgur and return the URL
  Future<String> _uploadToImgur(File image) async {
    final url = Uri.parse('https://api.imgur.com/3/upload');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Client-ID YOUR_IMGUR_CLIENT_ID' // Replace with your Imgur client ID
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    final data = jsonDecode(responseData.body);
    if (data['success']) {
      return data['data']['link']; // Return the image URL from Imgur
    } else {
      throw Exception('Failed to upload image');
    }
  }

  // Authenticate user (Login/Registration)
  Future<void> _authenticate() async {
    setState(() => isLoading = true);
    try {
      if (isLogin) {
        // Login logic
        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        // Register logic with validation
        if (usernameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('All fields are required.')),
          );
          return;
        }

        if (!RegExp(r"^[a-zA-Z0-9]+$").hasMatch(usernameController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Username should only contain letters and numbers.')),
          );
          return;
        }

        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Upload profile picture and store the download URL (if an image is selected)
        String profileImageUrl = 'assets/defaultProfile.png'; // Default image
        if (profileImage != null) {
          profileImageUrl = await _uploadToImgur(profileImage!);
        }

        // Create a new user document in Firestore
        final userId = userCredential.user!.uid; // Use UID from Firebase Auth
        await _firestore.collection('users').doc(userId).set({
          'userId': userId,
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'bio': '', // Default empty bio
          'profileImageUrl': profileImageUrl, // Profile image URL
          'followers': 0, // Default followers count
          'following': 0, // Default following count
        });
      }

      // Navigate to Profile Screen after success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (!isLogin) ...[
              // Username field with validation
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  errorText: usernameController.text.isEmpty ? 'Username cannot be empty' : null,
                ),
              ),
              const SizedBox(height: 10),
              // Profile image picker
              GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : AssetImage('assets/defaultProfile.png') as ImageProvider,
                  child: profileImage == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.white)
                      : null,
                ),
              ),
              if (profileImage != null)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: _removeProfileImage,
                ),
            ],
            const SizedBox(height: 20),
            // Email field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            // Password field with show/hide functionality
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !isPasswordVisible,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _authenticate,
                    child: Text(isLogin ? 'Login' : 'Register'),
                  ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin; // Toggle between login and register
                });
              },
              child: Text(isLogin
                  ? 'New user? Register here'
                  : 'Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

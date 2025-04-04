import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication package

class EditBiographyScreen extends StatefulWidget {
  const EditBiographyScreen({super.key});

  @override
  _EditBiographyScreenState createState() => _EditBiographyScreenState();
}

class _EditBiographyScreenState extends State<EditBiographyScreen> {
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentBio();
  }

  // Fetch the current bio from Firestore
  Future<void> _fetchCurrentBio() async {
    try {
      // Get the current logged-in user's ID
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'User is not logged in');
      }

      // Fetch the user's document from Firestore using their userId
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid) // Get the user document by userId
          .get();

      if (!userDoc.exists) {
        throw FirebaseException(code: 'user-not-found', message: 'User profile not found in Firestore', plugin: '');
      }

      setState(() {
        _bioController.text = userDoc['bio'] ?? ''; // Set the current bio
      });
    } catch (e) {
      print("Error fetching user bio: $e");
    }
  }

  // Update the user's bio in Firestore
  Future<void> _updateBio() async {
    try {
      // Get the current logged-in user's ID
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'User is not logged in');
      }

      // Update the bio in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'bio': _bioController.text, // Save the new bio
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bio updated successfully')),
      );

      // Go back to the previous screen after saving the bio
      Navigator.pop(context, {'bio': _bioController.text});
    } catch (e) {
      print("Error updating bio: $e");
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update bio')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Biography'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateBio,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit your biography:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your new biography...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateBio,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Save Bio', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

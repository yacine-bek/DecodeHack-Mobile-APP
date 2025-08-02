import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eco_system_things/classes/UserManager.dart';
import 'package:eco_system_things/classes/Manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _wilayaController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = UserManager();
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _wilayaController.text = user.wilaya;
  }

  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? const Color(0xFF91d5d8) : const Color(0xFFDD6060),
        content: Text(message, style: const TextStyle(color: Colors.black)),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked == null) return;

    final imageFile = File(picked.path);
    final url = await Manager().uploadImageToCloudinary(imageFile);

    if (url == null || url.isEmpty) {
      _showSnackBar('Image upload failed');
      return;
    }

    final user = UserManager();
    final success = await user.updateUserProfile(
      firstName: user.firstName,
      lastName: user.lastName,
      wilaya: user.wilaya,
      pfpUrl: url,
    );

    if (success) {
      setState(() {});
    } else {
      _showSnackBar('Failed to update profile image');
    }
  }

  Future<void> _saveProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final wilaya = _wilayaController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || wilaya.isEmpty) {
      _showSnackBar('All fields are required');
      return;
    }

    final user = UserManager();
    final success = await user.updateUserProfile(
      firstName: firstName,
      lastName: lastName,
      wilaya: wilaya,
      pfpUrl: user.pfp,
    );

    if (success) {
      _showSnackBar('Profile saved', success: true);
      setState(() {});
    } else {
      _showSnackBar('Failed to save profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = UserManager();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: user.pfp.isNotEmpty ? NetworkImage(user.pfp) : null,
                  child: user.pfp.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: PopupMenuButton<ImageSource>(
                    color: const Color(0xFF91d5d8),
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onSelected: _pickImage,
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: ImageSource.camera, child: Text('Take Photo')),
                      PopupMenuItem(value: ImageSource.gallery, child: Text('Choose from Gallery')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _wilayaController,
              decoration: const InputDecoration(labelText: 'Wilaya'),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _saveProfile,
              child: Container(
                width: 150,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFc3ece8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text("Save", style: TextStyle(fontSize: 24)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

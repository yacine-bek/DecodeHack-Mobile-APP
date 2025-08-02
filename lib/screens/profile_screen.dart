import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eco_system_things/classes/UserManager.dart';
import 'package:eco_system_things/classes/Manager.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _wilayaController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = UserManager();
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _wilayaController.text = user.wilaya;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      final imageFile = File(picked.path);
      final url = await Manager().uploadImageToCloudinary(imageFile);

      if (url != null && url.isNotEmpty) {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color.fromARGB(255, 221, 96, 96),
              content: Text(
                'Failed to update profile image',
                style: TextStyle(color: Colors.black),
              ),
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color.fromARGB(255, 221, 96, 96),
            content: Text(
              'Image upload failed',
              style: TextStyle(color: Colors.black),
            ),
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final wilaya = _wilayaController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || wilaya.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color.fromARGB(255, 221, 96, 96),
          content: Text(
            'All fields are required',
            style: TextStyle(color: Colors.black),
          ),
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF91d5d8),
          content: Text('Profile saved', style: TextStyle(color: Colors.black)),
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:  Color.fromARGB(255, 221, 96, 96),
          content: Text(
            'Failed to save profile',
            style: TextStyle(color: Colors.black),
          ),
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
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
                  backgroundImage: user.pfp.isNotEmpty
                      ? NetworkImage(user.pfp)
                      : null,
                  child: user.pfp.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: PopupMenuButton<ImageSource>(
                    color: Color(0xFF91d5d8),

                    icon: const Icon(Icons.edit, color: Colors.white),
                    onSelected: _pickImage,
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: ImageSource.camera,
                        child: Text('Take Photo'),
                      ),
                      PopupMenuItem(
                        value: ImageSource.gallery,
                        child: Text('Choose from Gallery'),
                      ),
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
                decoration: BoxDecoration(
                  color: Color(0xFFc3ece8),
                  borderRadius: BorderRadius.circular(24),
                ),
                width: 150,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.save),
                        Center(child: SizedBox(width: 8)),
                        Center(
                          child: Text("Save", style: TextStyle(fontSize: 24)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

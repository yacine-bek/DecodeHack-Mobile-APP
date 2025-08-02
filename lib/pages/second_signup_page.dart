import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eco_system_things/classes/Manager.dart';
import 'package:eco_system_things/classes/UserManager.dart';
import 'package:eco_system_things/pages/home_page.dart';

class SecondSignupPage extends StatefulWidget {
  final String email;
  final String password;

  const SecondSignupPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<SecondSignupPage> createState() => _SecondSignupPageState();
}

class _SecondSignupPageState extends State<SecondSignupPage> {
  bool _isSubmitting = false;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _selectedWilaya;
  File? _imageFile;

  final List<String> _wilayas = [
    'Adrar', 'Chlef', 'Laghouat', 'Oum El Bouaghi', 'Batna',
    'Béjaïa', 'Biskra', 'Béchar', 'Blida', 'Bouira',
    'Tamanrasset', 'Tébessa', 'Tlemcen', 'Tiaret', 'Tizi Ouzou', 'Alger',
  ];

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFDD6060),
        content: Text(message, style: const TextStyle(color: Colors.black)),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _selectedWilaya == null) {
      _showError("Please fill all required fields");
      setState(() => _isSubmitting = false);
      return;
    }

    String? pfpUrl;
    if (_imageFile != null) {
      try {
        pfpUrl = await Manager().uploadImageToCloudinary(_imageFile!);
      } catch (e) {
        _showError("Image upload failed: $e");
        setState(() => _isSubmitting = false);
        return;
      }
    }

    try {
      await UserManager().signUp(
        user: widget.email,
        password: widget.password,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        pfp: pfpUrl ?? '',
        wilaya: _selectedWilaya!,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (_) {
      _showError("Signup failed");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Signup")),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Image.asset("assets/images/logo.png", width: 300),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(labelText: "First Name"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(labelText: "Last Name"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 300,
                          child: DropdownButtonFormField<String>(
                            value: _selectedWilaya,
                            items: _wilayas
                                .map((wilaya) => DropdownMenuItem(
                                      value: wilaya,
                                      child: Text(wilaya),
                                    ))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedWilaya = value),
                            decoration: const InputDecoration(labelText: "Wilaya"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _imageFile != null
                            ? Image.file(_imageFile!, height: 150)
                            : const Text("No image selected"),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: _takePhoto,
                              child: _buildIconButton(Icons.camera_alt, "Take Photo"),
                            ),
                            GestureDetector(
                              onTap: _pickFromGallery,
                              child: _buildIconButton(Icons.photo_library, "Gallery"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _submit,
                          child: Container(
                            width: 100,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF91D5D8),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Center(
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:eco_system_things/classes/Manager.dart';
import 'package:eco_system_things/classes/UserManager.dart';
import 'package:eco_system_things/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    'Adrar',
    'Chlef',
    'Laghouat',
    'Oum El Bouaghi',
    'Batna',
    'Béjaïa',
    'Biskra',
    'Béchar',
    'Blida',
    'Bouira',
    'Tamanrasset',
    'Tébessa',
    'Tlemcen',
    'Tiaret',
    'Tizi Ouzou',
    'Alger',
  ];

  Future<void> _pickFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color.fromARGB(255, 221, 96, 96),
          content: Text(
            "Please fill all required fields",
            style: TextStyle(color: Colors.black),
          ),
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    String? pfpUrl;

    if (_imageFile != null) {
      try {
        print("Uploading image...");
        pfpUrl = await Manager().uploadImageToCloudinary(_imageFile!);
        print("Image uploaded: $pfpUrl");
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color.fromARGB(255, 221, 96, 96),
            content: Text(
              "Image upload failed: $e",
              style: TextStyle(color: Colors.black),
            ),
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }
    }

    try {
      print("Signing up user...");
      await UserManager().signUp(
        user: widget.email,
        password: widget.password,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        pfp: pfpUrl ?? '',
        wilaya: _selectedWilaya!,
      );
      print("Signup successful. Navigating to HomePage...");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      print("Signup failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color.fromARGB(255, 221, 96, 96),
          content: Text("Signup failed", style: TextStyle(color: Colors.black)),
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Image.asset("assets/images/logo.png", width: 300),

                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: 300,
                          child: TextField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: "First Name",
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 300,
                          child: TextField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: "Last Name",
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 300,
                          child: DropdownButtonFormField<String>(
                            value: _selectedWilaya,
                            items: _wilayas
                                .map(
                                  (wilaya) => DropdownMenuItem(
                                    value: wilaya,
                                    child: Text(wilaya),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedWilaya = value),
                            decoration: const InputDecoration(
                              labelText: "Wilaya",
                            ),
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.camera_alt, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      "Take Photo",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _pickFromGallery,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.photo_library, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      "Gallery",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                              color: const Color(0xFF91d5d8),
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
}

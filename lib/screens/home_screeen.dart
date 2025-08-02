import 'dart:io';
import 'package:eco_system_things/classes/Post.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eco_system_things/classes/Manager.dart';
import 'package:eco_system_things/classes/UserManager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Manager _manager = Manager();
  List<Post> _postsList = [];

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }

  void _refreshPosts() async {
    await _manager.fetchAndAddNewPosts();
    setState(() {
      _postsList = _manager.getAllPosts();
    });
  }

  void _openAddEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddEntryForm(
        onPostAdded: () {
          Navigator.pop(context); 
          _refreshPosts(); 
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _postsList.isEmpty
            ? const Center(child: Text("No posts yet."))
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _postsList.length,
                itemBuilder: (context, index) => _postsList[index].postWidget(),
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: _openAddEntrySheet,
          shape: const CircleBorder(), 
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
}

class _AddEntryForm extends StatefulWidget {
  final VoidCallback onPostAdded;

  const _AddEntryForm({required this.onPostAdded});

  @override
  State<_AddEntryForm> createState() => _AddEntryFormState();
}

class _AddEntryFormState extends State<_AddEntryForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _difficulty;
  String? _pollutionType;
  File? _imageFile;
  bool _isSubmitting = false;

  final _difficulties = ['Easy', 'Medium', 'Hard'];
  final _pollutionTypes = ['Air', 'Water', 'Soil', 'Visual'];

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();

    if (title.isEmpty ||
        desc.isEmpty ||
        _difficulty == null ||
        _pollutionType == null ||
        _imageFile == null) {
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

    setState(() => _isSubmitting = true);

    final imageUrl = await Manager().uploadImageToCloudinary(_imageFile!);
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF91d5d8),
          content: Text(
            'Image upload failed. Try again.',
            style: TextStyle(color: Colors.black),
          ),
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final location = await UserManager().getCurrentLocation();
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color.fromARGB(255, 221, 96, 96),
          content: Text(
            "Location not available. Enable location and try again.",
            style: TextStyle(color: Colors.black),
          ),
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    UserManager().addPost(
      difLVL: _difficulty!,
      polutionType: _pollutionType!,
      title: title,
      description: desc,
      pictures: [imageUrl],
      lat: location.latitude,
      lon: location.longitude,
    );

    widget.onPostAdded();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "New Post",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _difficulty,
              items: _difficulties
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) => setState(() => _difficulty = val),
              decoration: const InputDecoration(labelText: "Difficulty"),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _pollutionType,
              items: _pollutionTypes
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) => setState(() => _pollutionType = val),
              decoration: const InputDecoration(labelText: "Pollution Type"),
            ),
            const SizedBox(height: 8),
            _imageFile != null
                ? Image.file(_imageFile!, height: 150)
                : const Text("No image selected"),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.camera),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt, size: 32),
                          Text("Camera", style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.photo_library, size: 32),
                          Text("Gallery", style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _isSubmitting ? null : _submit,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFc3ece8),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text("Submit", style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

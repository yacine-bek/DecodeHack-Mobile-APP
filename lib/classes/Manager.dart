import 'dart:convert';
import 'dart:io';
import 'package:eco_system_things/classes/Post.dart';
import 'package:eco_system_things/classes/UserManager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class Manager {
  static final Manager _instance = Manager._internal();
  factory Manager() => _instance;
  Manager._internal();

  final DatabaseReference dbRef = UserManager().dbRef;

  final Map<String, Post> posts = {};

  void addPost(Post post) {
    posts[post.id] = post;
  }

  Post? getPostById(String id) {
    return posts[id];
  }

  void removePost(String id) {
    posts.remove(id);
  }

  List<Post> getAllPosts() {
    return posts.values.toList();
  }

  Future<void> fetchAndAddNewPosts() async {
    final snapshot = await dbRef.child('posts').get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      data.forEach((key, value) {
        final postMap = Map<String, dynamic>.from(value);
        final postId = postMap['post_id'];

        if (!posts.containsKey(postId)) {
          posts[postId] = Post.fromJson(postMap);
        }
      });
    }
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'dipgyti2c';
    const uploadPreset = 'employee_pics';

    final uploadUrl = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final originalBytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(originalBytes);

    if (decodedImage == null) {
      return null;
    }

    final resizedImage = img.copyResize(
      decodedImage,
      width: 800,
    ); 
    final compressedJpg = img.encodeJpg(
      resizedImage,
      quality: 60,
    ); 

    final tempDir = await getTemporaryDirectory();
    final compressedFile = File('${tempDir.path}/compressed.jpg')
      ..writeAsBytesSync(compressedJpg);

    final request = http.MultipartRequest('POST', uploadUrl)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath('file', compressedFile.path),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(resBody);
      return jsonResponse['secure_url'];
    } else {
      final errorBody = await response.stream.bytesToString();
      return null;
    }
  }

  Future<File?> downloadImageFromUrl(String url, String savePath) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      return null;
    }
  }
}

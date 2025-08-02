import 'package:eco_system_things/classes/Manager.dart';
import 'package:eco_system_things/classes/Post.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';

class UserManager {
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();
  final DatabaseReference dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://ecosys-133d0-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref();

  late String userId;
  late String password;
  late String idCard;
  late String firstName;
  late String lastName;
  late String pfp = '';
  late String wilaya;
  List<String> postes = [];
  List<String> groupes = [];

  Future<void> signUp({
    required String user,
    required String password,
    required String firstName,
    required String lastName,
    required String pfp,
    required String wilaya,
  }) async {
    userId = user;
    this.password = password;
    this.firstName = firstName;
    this.lastName = lastName;
    this.pfp = pfp;
    this.wilaya = wilaya;

    final Map<String, dynamic> userData = {
      "user_id": user,
      "first_name": firstName,
      "last_name": lastName,
      "password": password,
      "pfp": pfp,
      "posts": [],
      "groups": [],
      "wilaya": wilaya,
    };

      final authBox = Hive.box('authBox');
      await authBox.put('user', user);
      await authBox.put('password', password);

    try {
      await dbRef.child("users").child(user.replaceAll('.', '_')).set(userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<int> logIn({
    required String user,
    required String passwordInput,
  }) async {
    final String userKey = user.replaceAll('.', '_'); 

    try {
      final DataSnapshot snapshot = await dbRef.child("users/$userKey").get();

      if (!snapshot.exists) {
        return 200; 
      }

      final Map<dynamic, dynamic> userData = snapshot.value as Map;

      if (userData["password"] != passwordInput) {
        return 100; 
      }
      final authBox = Hive.box('authBox');
      await authBox.put('user', user);
      await authBox.put('password', passwordInput);

      userId = userData["user_id"];
      password = userData["password"];
      firstName = userData["first_name"];
      lastName = userData["last_name"];
      pfp = userData["pfp"];
      wilaya = userData["wilaya"];
      final groupsMap = userData["groups"] as Map<dynamic, dynamic>?;

      if (groupsMap != null) {
        groupes.addAll(groupsMap.keys.map((e) => e.toString()));
      }

      return 999; 
    } catch (e) {
      return -1; 
    }
  }

  Future<int> tryAutoLogin() async {
    final authBox = Hive.box('authBox');

    final String? savedUser = authBox.get('user');
    final String? savedPassword = authBox.get('password');

    if (savedUser == null || savedPassword == null) {
      return 0; 
    }

    return await logIn(user: savedUser, passwordInput: savedPassword);
  }

  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? wilaya,
    String? pfpUrl,
  }) async {
    try {
      final userKey = userId.replaceAll('.', '_');

      await dbRef.child("users/$userKey").update({
        "first_name": firstName ?? this.firstName,
        "last_name": lastName ?? this.lastName,
        "wilaya": wilaya ?? this.wilaya,
        "pfp": pfpUrl ?? this.pfp,
      });

      if (firstName != null) this.firstName = firstName;
      if (lastName != null) this.lastName = lastName;
      if (wilaya != null) this.wilaya = wilaya;
      if (pfpUrl != null) pfp = pfpUrl;

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> addPost({
    required String title,
    required String description,
    required List<String> pictures,
    required double lat,
    required double lon,
    required String difLVL,
    required String polutionType,
  }) async {
    final now = DateTime.now();

    String sanitize(String input) {
      return input
          .replaceAll('.', '_')
          .replaceAll('#', '_')
          .replaceAll('\$', '_')
          .replaceAll('[', '_')
          .replaceAll(']', '_');
    }

    final safeUserId = sanitize(userId);
    final safeWilaya = sanitize(wilaya);

    final id =
        '${safeWilaya}_${safeUserId}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}${now.second}';

    final postData = {
      "post_id": id,
      "user_id": userId,
      "wilaya": wilaya,
      "title": title,
      "description": description,
      "pictures": pictures,
      "status": "Waiting",
      "geolocal": {"lat": lat, "lng": lon},
      "difLVL": difLVL,
      "polutionType": polutionType,
    };

    try {
      final DataSnapshot snapshot = await dbRef
          .child("users/$safeUserId")
          .get();
      if (snapshot.exists) {
      } else {
      }
    } catch (e) {
    }

    try {
      await dbRef.child("posts").child(id).set(postData);
    } catch (e) {
    }

    final newPost = Post(
      difLVL: difLVL,
      polutionType: polutionType,
      id: id,
      userId: userId,
      wilaya: wilaya,
      title: title,
      description: description,
      pictures: pictures,
      status: "Waiting",
      lat: lat,
      lon: lon,
    );

    Manager().addPost(newPost);
    postes.add(id); 
  }

  Future<void> addUserToPostMembers({required String postId}) async {
    String sanitize(String input) {
      return input
          .replaceAll('.', '_')
          .replaceAll('#', '_')
          .replaceAll('\$', '_')
          .replaceAll('[', '_')
          .replaceAll(']', '_');
    }

    final safeUserId = sanitize(userId);

    try {
      await dbRef
          .child("posts")
          .child(postId)
          .child("members")
          .child(safeUserId)
          .set(true);
      await dbRef
          .child("users")
          .child(safeUserId)
          .child("groups")
          .child(postId)
          .set(true);

    } catch (e) {

    }
    if (!groupes.contains(postId)) {
      groupes.add(postId);
    }
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings(); 
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        
        await Geolocator.openAppSettings(); 
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings(); 
      return null;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return position;
  }
}

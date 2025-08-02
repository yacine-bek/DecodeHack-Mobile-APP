import 'package:eco_system_things/classes/Manager.dart';
import 'package:eco_system_things/classes/Post.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
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

    final userData = {
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

    await dbRef.child("users").child(_sanitize(user)).set(userData);
  }

  Future<int> logIn({
    required String user,
    required String passwordInput,
  }) async {
    final userKey = _sanitize(user);

    try {
      final snapshot = await dbRef.child("users/$userKey").get();

      if (!snapshot.exists) return 200; // User not found

      final data = snapshot.value as Map;
      if (data["password"] != passwordInput) return 100; // Wrong password

      final authBox = Hive.box('authBox');
      await authBox.put('user', user);
      await authBox.put('password', passwordInput);

      userId = data["user_id"];
      password = data["password"];
      firstName = data["first_name"];
      lastName = data["last_name"];
      pfp = data["pfp"];
      wilaya = data["wilaya"];

      final groupsMap = data["groups"] as Map<dynamic, dynamic>?;
      if (groupsMap != null) {
        groupes.addAll(groupsMap.keys.map((e) => e.toString()));
      }

      return 999; // Success
    } catch (_) {
      return -1; // Unknown error
    }
  }

  Future<int> tryAutoLogin() async {
    final authBox = Hive.box('authBox');
    final savedUser = authBox.get('user');
    final savedPassword = authBox.get('password');

    if (savedUser == null || savedPassword == null) return 0;

    return await logIn(user: savedUser, passwordInput: savedPassword);
  }

  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? wilaya,
    String? pfpUrl,
  }) async {
    try {
      final userKey = _sanitize(userId);

      await dbRef.child("users/$userKey").update({
        "first_name": firstName ?? this.firstName,
        "last_name": lastName ?? this.lastName,
        "wilaya": wilaya ?? this.wilaya,
        "pfp": pfpUrl ?? this.pfp,
      });

      if (firstName != null) this.firstName = firstName;
      if (lastName != null) this.lastName = lastName;
      if (wilaya != null) this.wilaya = wilaya;
      if (pfpUrl != null) this.pfp = pfpUrl;

      return true;
    } catch (_) {
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
    final safeUserId = _sanitize(userId);
    final safeWilaya = _sanitize(wilaya);

    final id = '${safeWilaya}_${safeUserId}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}${now.second}';

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

    await dbRef.child("posts").child(id).set(postData);

    final newPost = Post(
      id: id,
      userId: userId,
      wilaya: wilaya,
      title: title,
      description: description,
      pictures: pictures,
      status: "Waiting",
      lat: lat,
      lon: lon,
      difLVL: difLVL,
      polutionType: polutionType,
    );

    Manager().addPost(newPost);
    postes.add(id);
  }

  Future<void> addUserToPostMembers({required String postId}) async {
    final safeUserId = _sanitize(userId);

    await dbRef.child("posts/$postId/members/$safeUserId").set(true);
    await dbRef.child("users/$safeUserId/groups/$postId").set(true);

    if (!groupes.contains(postId)) {
      groupes.add(postId);
    }
  }

  Future<Position?> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
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

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  String _sanitize(String input) {
    return input
        .replaceAll('.', '_')
        .replaceAll('#', '_')
        .replaceAll('\$', '_')
        .replaceAll('[', '_')
        .replaceAll(']', '_');
  }
}

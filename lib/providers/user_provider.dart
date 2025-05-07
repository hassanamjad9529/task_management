import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;
  String? _userType;

  String? get userType => _userType;

  Future<String?> fetchUserType() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          _userType = userDoc
              .data()?['role']; // Assuming 'type' is the field in Firestore
          notifyListeners();
          return _userType;
        }
      }
    } catch (e) {
      debugPrint('Error fetching user type: $e');
    }
    return null;
  }

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}

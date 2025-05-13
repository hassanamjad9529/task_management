import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> createEmployee({
    required String name,
    required String email,
    required String password,
    required String designation,
    required double salary,
    required String phoneNumber,
  }) async {
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty || designation.isEmpty || phoneNumber.isEmpty) {
        return 'All fields are required';
      }
      if (salary < 0) {
        return 'Salary cannot be negative';
      }
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': 'employee',
        'designation': designation,
        'salary': salary,
        'phoneNumber': phoneNumber,
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateEmployee({
    required String uid,
    required String name,
    required String email,
    required String role,
    required String designation,
    required double salary,
    required String phoneNumber,
  }) async {
    try {
      if (name.isEmpty || email.isEmpty || role.isEmpty || designation.isEmpty || phoneNumber.isEmpty) {
        return 'All fields are required';
      }
      if (salary < 0) {
        return 'Salary cannot be negative';
      }
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'email': email,
        'role': role,
        'designation': designation,
        'salary': salary,
        'phoneNumber': phoneNumber,
      });

      User? user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        await user.updateEmail(email);
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteEmployee(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<List<UserModel>> getEmployees() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel(
          uid: doc.id,
          email: data['email'],
          name: data['name'],
          role: data['role'],
          designation: data['designation'] ?? '',
          salary: (data['salary'] ?? 0).toDouble(),
          phoneNumber: data['phoneNumber'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch employees: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
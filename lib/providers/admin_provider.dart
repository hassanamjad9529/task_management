import 'package:flutter/foundation.dart';
import 'package:task_management/services/admin_services.dart';
import '../models/user_model.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();
  List<UserModel> _employees = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> createEmployee({
    required String name,
    required String email,
    required String password,
    required String designation,
    required double salary,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await _adminService.createEmployee(
      name: name,
      email: email,
      password: password,
      designation: designation,
      salary: salary,
      phoneNumber: phoneNumber,
    );

    _isLoading = false;
    if (error != null) {
      _errorMessage = error;
    } else {
      await fetchEmployees();
    }
    notifyListeners();
  }

  Future<void> updateEmployee({
    required String uid,
    required String name,
    required String email,
    required String role,
    required String designation,
    required double salary,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await _adminService.updateEmployee(
      uid: uid,
      name: name,
      email: email,
      role: role,
      designation: designation,
      salary: salary,
      phoneNumber: phoneNumber,
    );

    _isLoading = false;
    if (error != null) {
      _errorMessage = error;
    } else {
      await fetchEmployees();
    }
    notifyListeners();
  }

  Future<void> deleteEmployee(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await _adminService.deleteEmployee(uid);

    _isLoading = false;
    if (error != null) {
      _errorMessage = error;
    } else {
      await fetchEmployees();
    }
    notifyListeners();
  }

  Future<void> fetchEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _employees = await _adminService.getEmployees();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _adminService.signOut();
    _employees = [];
    _errorMessage = null;
    notifyListeners();
  }
}
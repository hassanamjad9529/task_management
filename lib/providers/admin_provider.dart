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

  // Create an employee
  Future<void> createEmployee({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await _adminService.createEmployee(
      name: name,
      email: email,
      password: password,
    );

    _isLoading = false;
    if (error != null) {
      _errorMessage = error;
    } else {
      await fetchEmployees(); // Refresh employee list
    }
    notifyListeners();
  }

  // Fetch employees
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

  // Sign out
  Future<void> signOut() async {
    await _adminService.signOut();
    _employees = [];
    _errorMessage = null;
    notifyListeners();
  }
}
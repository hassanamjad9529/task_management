import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:task_management/models/user_model.dart';
import 'package:task_management/screens/admin_dashboard.dart';
import 'package:task_management/screens/employee_dashboard.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('LoginScreen: Attempting login with email: ${_emailController.text.trim()}');
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print('LoginScreen: Login successful, user: ${userCredential.user!.email}');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        print('LoginScreen: Creating Firestore document for user');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': _emailController.text.trim().split('@')[0],
          'email': _emailController.text.trim(),
          'role': _emailController.text.trim().toLowerCase() == 'admin@gmail.com' ? 'admin' : 'employee',
        });
        print('LoginScreen: Firestore document created');
      }

      final userData = userDoc.exists ? userDoc.data() as Map<String, dynamic> : {
        'name': _emailController.text.trim().split('@')[0],
        'email': _emailController.text.trim(),
        'role': _emailController.text.trim().toLowerCase() == 'admin@gmail.com' ? 'admin' : 'employee',
      };
      final user = UserModel(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
        name: userData['name'] ?? 'Unnamed',
        role: userData['role'] ?? 'employee',
        designation: '',
        salary: userData['salary'] ?? 0.0,
        phoneNumber: userData['phoneNumber'] ?? '',
      );
      Provider.of<UserProvider>(context, listen: false).setUser(user);

      print('LoginScreen: Navigating to ${user.email.toLowerCase() == 'admin@gmail.com' ? 'AdminScreen' : 'EmployeeScreen'}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => user.email.toLowerCase() == 'admin@gmail.com'
              ? AdminScreen()
              : EmployeeScreen(),
        ),
      );
    } catch (e) {
      print('LoginScreen: Login error - $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('LoginScreen: Attempting sign-up with email: ${_emailController.text.trim()}');
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print('LoginScreen: Sign-up successful, user: ${userCredential.user!.email}');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _emailController.text.trim().split('@')[0],
        'email': _emailController.text.trim(),
        'role': _emailController.text.trim().toLowerCase() == 'admin@gmail.com' ? 'admin' : 'employee',
      });
      print('LoginScreen: Firestore document created for new user');

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
        name: _emailController.text.trim().split('@')[0],
        role: _emailController.text.trim().toLowerCase() == 'admin@gmail.com' ? 'admin' : 'employee',
        designation: '',
        salary: 0.0,
        phoneNumber: '',
      );
      Provider.of<UserProvider>(context, listen: false).setUser(user);

      print('LoginScreen: Navigating to ${user.email.toLowerCase() == 'admin@gmail.com' ? 'AdminScreen' : 'EmployeeScreen'}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => user.email.toLowerCase() == 'admin@gmail.com'
              ? AdminScreen()
              : EmployeeScreen(),
        ),
      );
    } catch (e) {
      print('LoginScreen: Sign-up error - $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _signIn,
                        child: Text('Login'),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _signUp,
                        child: Text('Sign Up'),
                      ),
                    ],
                  ),
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:task_management/screens/admin_dashboard.dart';
import 'package:task_management/screens/employee_dashboard.dart';
import 'providers/user_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Task Management App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return LoginScreen();
    } else {
      return FutureBuilder<String?>(
        future: Provider.of<UserProvider>(context, listen: false).fetchUserType(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data == 'employee') {
              return EmployeeScreen(); // Replace with your EmployeeScreen widget
            } else if (snapshot.data == 'admin') {
              return AdminScreen(); // Replace with your AdminScreen widget
            }
            } else if (snapshot.data == '') {
              return LoginScreen(); // Replace with your AdminScreen widget
            }
          
          return Scaffold(
            body: Center(child: Text('Error determining user type')),
          );
        },
      );
    }
  }
}
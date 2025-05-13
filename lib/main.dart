import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:task_management/screens/admin_dashboard.dart';
import 'package:task_management/screens/employee_dashboard.dart';
import 'models/user_model.dart';
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
    final userProvider = Provider.of<UserProvider>(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('StreamBuilder: Connection state - ${snapshot.connectionState}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('StreamBuilder: Waiting for auth state');
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print('StreamBuilder: Error - ${snapshot.error}');
          return Center(child: Text('Auth Error: ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          print('StreamBuilder: User logged in - ${snapshot.data!.email}');
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              print(
                  'FutureBuilder: Connection state - ${userSnapshot.connectionState}');
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                print('FutureBuilder: Waiting for Firestore data');
                return Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasError) {
                print('FutureBuilder: Firestore error - ${userSnapshot.error}');
                return Center(
                    child: Text('Firestore Error: ${userSnapshot.error}'));
              }
              if (userSnapshot.hasData) {
                if (userSnapshot.data!.exists) {
                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final user = UserModel(
                    uid: snapshot.data!.uid,
                    email: snapshot.data!.email!,
                    name: userData['name'] ?? 'Unnamed',
                    role: userData['role'] ?? 'employee',
                    designation: userData['designation'] ?? 'Unknown',
                    salary: userData['salary'] ?? 0,
                    phoneNumber: userData['phoneNumber'] ?? 'N/A',
                  );
                  userProvider.setUser(user);
                  print(
                      'FutureBuilder: User data fetched - ${user.email}, role: ${user.role}');
                  if (user.email.toLowerCase() == 'admin@gmail.com') {
                    print('Navigating to AdminScreen');
                    return AdminScreen();
                  } else {
                    print('Navigating to EmployeeScreen');
                    return EmployeeScreen();
                  }
                } else {
                  print(
                      'FutureBuilder: No user document found, creating default');
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(snapshot.data!.uid)
                      .set({
                    'name': snapshot.data!.email?.split('@')[0] ?? 'Unnamed',
                    'email': snapshot.data!.email,
                    'role':
                        snapshot.data!.email!.toLowerCase() == 'admin@gmail.com'
                            ? 'admin'
                            : 'employee',
                  }).then((_) {
                    print('FutureBuilder: Default user document created');
                    final user = UserModel(
                      uid: snapshot.data!.uid,
                      email: snapshot.data!.email!,
                      name: snapshot.data!.email!.split('@')[0],
                      role: snapshot.data!.email!.toLowerCase() ==
                              'admin@gmail.com'
                          ? 'admin'
                          : 'employee',
                      designation: 'Unknown',
                      salary: 0,
                      phoneNumber: 'N/A',
                    );
                    userProvider.setUser(user);
                    if (user.email.toLowerCase() == 'admin@gmail.com') {
                      print(
                          'Navigating to AdminScreen after document creation');
                      return AdminScreen();
                    } else {
                      print(
                          'Navigating to EmployeeScreen after document creation');
                      return EmployeeScreen();
                    }
                  }).catchError((error) {
                    print(
                        'FutureBuilder: Error creating default document - $error');
                    return Center(
                        child: Text('Error creating user document: $error'));
                  });
                  return Center(child: CircularProgressIndicator());
                }
              }
              print(
                  'FutureBuilder: No user document data, redirecting to LoginScreen');
              return LoginScreen();
            },
          );
        }
        print('StreamBuilder: No user logged in, showing LoginScreen');
        return LoginScreen();
      },
    );
  }
}

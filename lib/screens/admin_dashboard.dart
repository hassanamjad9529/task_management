import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/screens/login_screen.dart';
import '../providers/admin_provider.dart';
import '../providers/user_provider.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch employees when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await adminProvider.signOut();
              userProvider.clearUser();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user?.name ?? "Admin"}'),
            SizedBox(height: 20),
            Text('Create Employee Account', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Employee Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Employee Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Employee Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            adminProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      await adminProvider.createEmployee(
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );
                      if (adminProvider.errorMessage == null) {
                        _nameController.clear();
                        _emailController.clear();
                        _passwordController.clear();
                      }
                    },
                    child: Text('Create Employee'),
                  ),
            if (adminProvider.errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  adminProvider.errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 20),
            Text('Employee List', style: TextStyle(fontSize: 18)),
            Expanded(
              child: adminProvider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : adminProvider.employees.isEmpty
                      ? Center(child: Text('No employees found'))
                      : ListView.builder(
                          itemCount: adminProvider.employees.length,
                          itemBuilder: (context, index) {
                            final employee = adminProvider.employees[index];
                            return ListTile(
                              title: Text(employee.name),
                              subtitle: Text(employee.email),
                              trailing: Text(employee.role),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

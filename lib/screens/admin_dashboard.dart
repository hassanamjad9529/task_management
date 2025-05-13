import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _designationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchEmployees();
    });
  }

  void _showEmployeeActions(BuildContext context, UserModel employee) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Employee'),
            onTap: () {
              Navigator.pop(context);
              _showEditEmployeeDialog(context, employee);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete Employee'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmationDialog(context, employee);
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showEditEmployeeDialog(BuildContext context, UserModel employee) {
    final editNameController = TextEditingController(text: employee.name);
    final editEmailController = TextEditingController(text: employee.email);
    final editDesignationController = TextEditingController(text: employee.designation);
    final editSalaryController = TextEditingController(text: employee.salary.toString());
    final editPhoneNumberController = TextEditingController(text: employee.phoneNumber);
    String role = employee.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Employee'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editNameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: editEmailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: editDesignationController,
                decoration: InputDecoration(labelText: 'Designation'),
              ),
              TextField(
                controller: editSalaryController,
                decoration: InputDecoration(labelText: 'Salary'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: editPhoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              DropdownButtonFormField<String>(
                value: role,
                decoration: InputDecoration(labelText: 'Role'),
                items: ['employee', 'admin'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  role = newValue!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<AdminProvider>(context, listen: false).updateEmployee(
                uid: employee.uid,
                name: editNameController.text.trim(),
                email: editEmailController.text.trim(),
                role: role,
                designation: editDesignationController.text.trim(),
                salary: double.tryParse(editSalaryController.text.trim()) ?? 0,
                phoneNumber: editPhoneNumberController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, UserModel employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<AdminProvider>(context, listen: false).deleteEmployee(employee.uid);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
              decoration: InputDecoration(labelText: 'Name'),
            ),
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
            TextField(
              controller: _designationController,
              decoration: InputDecoration(labelText: 'Designation'),
            ),
            TextField(
              controller: _salaryController,
              decoration: InputDecoration(labelText: 'Salary'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
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
                        designation: _designationController.text.trim(),
                        salary: double.tryParse(_salaryController.text.trim()) ?? 0,
                        phoneNumber: _phoneNumberController.text.trim(),
                      );
                      if (adminProvider.errorMessage == null) {
                        _nameController.clear();
                        _emailController.clear();
                        _passwordController.clear();
                        _designationController.clear();
                        _salaryController.clear();
                        _phoneNumberController.clear();
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(employee.email),
                                  Text('Designation: ${employee.designation}'),
                                  Text('Salary: \$${employee.salary}'),
                                  Text('Phone: ${employee.phoneNumber}'),
                                ],
                              ),
                              trailing: Text(employee.role),
                              onTap: () => _showEmployeeActions(context, employee),
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
    _designationController.dispose();
    _salaryController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
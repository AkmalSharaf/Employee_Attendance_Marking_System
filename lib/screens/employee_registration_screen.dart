import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firebase_service.dart';

/// Employee Registration Screen
///
/// This screen provides a form to add new employees to the system.
/// Required fields: Employee Name, Employee ID, Department, Contact Number
/// Includes proper form validation and success/error messages.
class EmployeeRegistrationScreen extends StatefulWidget {
  const EmployeeRegistrationScreen({super.key});

  @override
  State<EmployeeRegistrationScreen> createState() =>
      _EmployeeRegistrationScreenState();
}

class _EmployeeRegistrationScreenState
    extends State<EmployeeRegistrationScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Firebase service instance
  final FirebaseService _firebaseService = FirebaseService();

  // Text editing controllers
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _contactNumberController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  // message state is no longer needed; we use snackbar directly

  @override
  void dispose() {
    // Clean up controllers
    _nameController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  /// Reset form to initial state
  void _resetForm() {
    _nameController.clear();
    _employeeIdController.clear();
    _departmentController.clear();
    _contactNumberController.clear();
    _formKey.currentState?.reset();
  }

  /// Show snackbar message
  void _showMessage(String message, bool isError) {
    // simply display a snackbar; state fields were removed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Submit the employee registration form
  Future<void> _submitForm() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final empId = _employeeIdController.text.trim();

      // Check for duplicate employeeId before trying to add
      final exists = await _firebaseService.employeeIdExists(empId);
      if (exists) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        _showMessage('Employee ID already exists. Use a unique Employee ID.', true);
        return;
      }

      // Add employee to Firebase
      await _firebaseService.addEmployee(
        name: _nameController.text.trim(),
        employeeId: empId,
        department: _departmentController.text.trim(),
        contactNumber: _contactNumberController.text.trim(),
      );

      // Show success message
      _showMessage('Employee registered successfully!', false);

      // Reset form for next entry
      _resetForm();
    } catch (e) {
      // Show error message
      _showMessage('Error registering employee: ${e.toString()}', true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Registration'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Register New Employee',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill in the employee details below',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Employee Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Employee Name *',
                  hintText: 'Enter full name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter employee name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Employee ID Field
              TextFormField(
                controller: _employeeIdController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID *',
                  hintText: 'Enter employee ID (numbers only)',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter employee ID';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                    return 'Employee ID must contain only numbers';
                  }
                  if (value.trim().length < 2) {
                    return 'Employee ID must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Department Field
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department *',
                  hintText: 'Enter department',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter department';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contact Number Field
              TextFormField(
                controller: _contactNumberController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number *',
                  hintText: 'Enter 10-digit phone number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter contact number';
                  }
                  if (value.trim().length != 10) {
                    return 'Contact number must be exactly 10 digits';
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                    return 'Contact number must contain only numbers';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Register Employee',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Clear Button
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _resetForm,
                  child: const Text(
                    'Clear Form',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              // Note
              const SizedBox(height: 24),
              const Text(
                '* Required fields',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

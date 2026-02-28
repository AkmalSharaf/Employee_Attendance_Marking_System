import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/employee.dart';
import '../services/firebase_service.dart';

/// Attendance Screen
///
/// This screen displays a list of all registered employees and allows
/// marking attendance with checkboxes. Includes search/filter functionality.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // Firebase service instance
  final FirebaseService _firebaseService = FirebaseService();

  // Selected date for attendance
  DateTime _selectedDate = DateTime.now();

  // Search query
  String _searchQuery = '';

  // Loading state
  bool _isLoading = false;

  // Map to track attendance status for each employee
  Map<String, bool> _attendanceStatus = {};

  // Filter selection: 'all', 'present', or 'absent'
  String _selectedFilter = 'all';

  // (Removed unused fields - messages are shown directly via snackbar)

  @override
  void initState() {
    super.initState();
    _loadAttendanceForDate();
  }

  /// Load attendance records for the selected date
  Future<void> _loadAttendanceForDate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get attendance records for the selected date
      final attendanceList =
          await _firebaseService.getAttendanceByDate(_selectedDate);

      // Update attendance status map
      final Map<String, bool> statusMap = {};
      for (var attendance in attendanceList) {
        statusMap[attendance.employeeId] = attendance.isPresent;
      }

      if (mounted) {
        setState(() {
          _attendanceStatus = statusMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showMessage('Error loading attendance: ${e.toString()}', true);
      }
    }
  }

  /// Show snackbar message
  void _showMessage(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Select a date for attendance marking
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAttendanceForDate();
    }
  }

  /// Toggle attendance for an employee.
  /// Accepts the desired `isPresent` value (prevents race/stale-state issues).
  Future<void> _toggleAttendance(Employee employee, bool isPresent) async {
    final previous = _attendanceStatus[employee.id] ?? false;

    // Optimistically update UI
    setState(() {
      _attendanceStatus[employee.id] = isPresent;
    });

    try {
      await _firebaseService.markAttendance(
        employeeId: employee.id,
        employeeName: employee.name,
        date: _selectedDate,
        isPresent: isPresent,
      );
    } catch (e) {
      // Revert on error
      setState(() {
        _attendanceStatus[employee.id] = previous;
      });
      _showMessage('Error marking attendance: ${e.toString()}', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Date selector
          TextButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            label: Text(
              DateFormat('MMM dd, yyyy').format(_selectedDate),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search employees by name...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Attendance Summary card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _buildAttendanceSummary(),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // hint about delete gesture
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                'Swipe right to left to delete',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Employee List
            Expanded(
              child: _buildEmployeeList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build attendance summary widget with clickable filters
  Widget _buildAttendanceSummary() {
    return StreamBuilder<List<Employee>>(
      stream: _firebaseService.getAllEmployees(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final employees = snapshot.data!;
        final presentCount = _attendanceStatus.values
            .where((isPresent) => isPresent)
            .length;
        final totalCount = employees.length;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary
                .withAlpha((0.3 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedFilter = 'all'),
                child: _buildSummaryItem(
                  'Total Employees',
                  totalCount.toString(),
                  Icons.people,
                  isSelected: _selectedFilter == 'all',
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedFilter = 'present'),
                child: _buildSummaryItem(
                  'Present',
                  presentCount.toString(),
                  Icons.check_circle,
                  color: Colors.green,
                  isSelected: _selectedFilter == 'present',
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedFilter = 'absent'),
                child: _buildSummaryItem(
                  'Absent',
                  (totalCount - presentCount).toString(),
                  Icons.cancel,
                  color: Colors.red,
                  isSelected: _selectedFilter == 'absent',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build summary item widget with optional selection highlighting
  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
    bool isSelected = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.white.withAlpha((0.7 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Column(
        children: [
          Icon(icon, color: color ?? Colors.grey[700], size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.grey[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Build employee list with attendance toggles
  Widget _buildEmployeeList() {
    return StreamBuilder<List<Employee>>(
      stream: _firebaseService.getAllEmployees(),
      builder: (context, snapshot) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadAttendanceForDate,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No employees registered yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Please register employees first',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Filter employees by search query and attendance status
        final employees = snapshot.data!;
        var filteredEmployees = employees.where((employee) {
          if (_searchQuery.isNotEmpty &&
              !employee.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
            return false;
          }

          // Apply attendance filter
          final isPresent = _attendanceStatus[employee.id] ?? false;
          if (_selectedFilter == 'present') {
            return isPresent;
          } else if (_selectedFilter == 'absent') {
            return !isPresent;
          }
          // 'all' shows everyone
          return true;
        }).toList();

        // Sort by date (present first, then by name)
        filteredEmployees.sort((a, b) {
          final aPresent = _attendanceStatus[a.id] ?? false;
          final bPresent = _attendanceStatus[b.id] ?? false;
          // Present employees first
          if (aPresent && !bPresent) return -1;
          if (!aPresent && bPresent) return 1;
          return a.name.compareTo(b.name);
        });

        if (filteredEmployees.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No employees found for "$_searchQuery"',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadAttendanceForDate,
          child: ListView.separated(
            itemCount: filteredEmployees.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final employee = filteredEmployees[index];
              final isPresent = _attendanceStatus[employee.id] ?? false;

              // Support swipe-to-delete
              return Dismissible(
                key: Key('employee_${employee.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete employee'),
                      content: const Text(
                          'Are you sure you want to delete this employee and all their attendance records?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  try {
                    await _firebaseService.deleteEmployeeAndAttendance(employee.id);
                    _showMessage('Employee deleted', false);
                    // Refresh lists
                    _loadAttendanceForDate();
                  } catch (e) {
                    _showMessage('Error deleting employee: ${e.toString()}', true);
                  }
                },
                child: _buildEmployeeCard(employee, isPresent),
              );
            },
          ),
        );
      },
    );
  }

  /// Build individual employee card with attendance toggle
  Widget _buildEmployeeCard(Employee employee, bool isPresent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPresent
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
        child: InkWell(
      onTap: () => _toggleAttendance(employee, !( _attendanceStatus[employee.id] ?? false)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: isPresent
                    ? Colors.green
                    : Colors.grey[300],
                child: Text(
                  employee.name.isNotEmpty
                      ? employee.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: isPresent ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Employee Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPresent ? Colors.green[800] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.badge,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          employee.employeeId,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.business,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            employee.department,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.blue[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Attendance Toggle
              Column(
                children: [
                  Switch(
                    value: isPresent,
                    onChanged: (value) => _toggleAttendance(employee, value),
                    activeThumbColor: Colors.green,
                    activeTrackColor: Colors.green[200],
                  ),
                  Text(
                    isPresent ? 'Present' : 'Absent',
                    style: TextStyle(
                      fontSize: 12,
                      color: isPresent ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

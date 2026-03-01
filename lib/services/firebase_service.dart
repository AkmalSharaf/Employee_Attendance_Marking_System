import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/employee.dart';
import '../models/attendance.dart';

/// Firebase Service class that handles all Firebase Firestore operations.
///
/// This service provides methods for:
/// - Employee management (CRUD operations)
/// - Attendance tracking and retrieval
class FirebaseService {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // UUID generator for creating unique IDs
  final Uuid _uuid = const Uuid();

  // Collection names
  static const String employeesCollection = 'employees';
  static const String attendanceCollection = 'attendance';

  // ==================== EMPLOYEE OPERATIONS ====================

  /// Get all employees from Firestore
  /// Returns a stream of `List<Employee>` for real-time updates
  Stream<List<Employee>> getAllEmployees() {
    return _firestore
        .collection(employeesCollection)
        .orderBy('name', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Employee.fromFirestore(doc)).toList());
  }

  /// Get a single employee by ID
  Future<Employee?> getEmployeeById(String id) async {
    try {
      final doc = await _firestore.collection(employeesCollection).doc(id).get();
      if (doc.exists) {
        return Employee.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching employee: $e');
    }
  }

  /// Add a new employee to Firestore
  /// Returns the created Employee with generated ID
  Future<Employee> addEmployee({
    required String name,
    required String employeeId,
    required String department,
    required String contactNumber,
  }) async {
    try {
      // Ensure employeeId is unique
      final exists = await employeeIdExists(employeeId);
      if (exists) {
        throw Exception('Employee with ID "$employeeId" already exists');
      }

      // Generate a unique ID
      final String id = _uuid.v4();

      // Create employee data
      final employee = Employee(
        id: id,
        name: name,
        employeeId: employeeId,
        department: department,
        contactNumber: contactNumber,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection(employeesCollection)
          .doc(id)
          .set(employee.toFirestore());

      return employee;
    } catch (e) {
      throw Exception('Error adding employee: $e');
    }
  }

  /// Check whether an employee with the given `employeeId` already exists.
  Future<bool> employeeIdExists(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection(employeesCollection)
          .where('employeeId', isEqualTo: employeeId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking employee ID: $e');
    }
  }

  /// Update an existing employee
  Future<void> updateEmployee(Employee employee) async {
    try {
      await _firestore
          .collection(employeesCollection)
          .doc(employee.id)
          .update(employee.toFirestore());
    } catch (e) {
      throw Exception('Error updating employee: $e');
    }
  }

  /// Delete an employee by ID
  Future<void> deleteEmployee(String id) async {
    try {
      await _firestore.collection(employeesCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting employee: $e');
    }
  }

  /// Delete an employee and all related attendance records.
  Future<void> deleteEmployeeAndAttendance(String employeeId) async {
    final batch = _firestore.batch();
    try {
      final empRef = _firestore.collection(employeesCollection).doc(employeeId);
      batch.delete(empRef);

      final attendanceSnapshot = await _firestore
          .collection(attendanceCollection)
          .where('employeeId', isEqualTo: employeeId)
          .get();

      for (final doc in attendanceSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error deleting employee and attendance: $e');
    }
  }

  /// Search employees by name (case-insensitive)
  Future<List<Employee>> searchEmployees(String query) async {
    try {
      final snapshot = await _firestore
          .collection(employeesCollection)
          .orderBy('name')
          .get();

      final employees =
          snapshot.docs.map((doc) => Employee.fromFirestore(doc)).toList();

      // Filter by name containing the query (case-insensitive)
      if (query.isEmpty) {
        return employees;
      }

      return employees
          .where((emp) =>
              emp.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Error searching employees: $e');
    }
  }

  // ==================== ATTENDANCE OPERATIONS ====================

  /// Get attendance records for a specific date
  /// Uses deterministic document IDs to avoid requiring a composite index.
  Future<List<Attendance>> getAttendanceByDate(DateTime date) async {
    try {
      // Normalize date to start of day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final dateString =
          '${startOfDay.year}-${startOfDay.month.toString().padLeft(2, '0')}-${startOfDay.day.toString().padLeft(2, '0')}';

      // Get all employees
      final employees = await getAllEmployees().first;

      // For each employee, try to get their attendance record for this date
      final List<Attendance> attendanceList = [];
      for (final employee in employees) {
        final docId = '${employee.id}_$dateString';
        final doc =
            await _firestore.collection(attendanceCollection).doc(docId).get();
        if (doc.exists) {
          attendanceList.add(Attendance.fromFirestore(doc));
        }
      }

      return attendanceList;
    } catch (e) {
      throw Exception('Error fetching attendance: $e');
    }
  }

  /// Get attendance records for a specific employee
  Future<List<Attendance>> getAttendanceByEmployee(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection(attendanceCollection)
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Attendance.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error fetching employee attendance: $e');
    }
  }

  /// Mark attendance for an employee
  /// Uses a deterministic document ID based on employeeId and date (YYYY-MM-DD format)
  /// This avoids requiring a composite Firestore index.
  Future<Attendance> markAttendance({
    required String employeeId,
    required String employeeName,
    required DateTime date,
    required bool isPresent,
  }) async {
    try {
      // Normalize date to start of day
      final startOfDay = DateTime(date.year, date.month, date.day);

      // Generate deterministic document ID: {employeeId}_{YYYY-MM-DD}
      final dateString =
          '${startOfDay.year}-${startOfDay.month.toString().padLeft(2, '0')}-${startOfDay.day.toString().padLeft(2, '0')}';
      final docId = '${employeeId}_$dateString';

      // Try to get the existing document
      final existingDoc =
          await _firestore.collection(attendanceCollection).doc(docId).get();

      if (existingDoc.exists) {
        // Update existing attendance
        await existingDoc.reference.update({
          'isPresent': isPresent,
        });

        // Re-fetch and return the updated document
        final updatedDoc = await existingDoc.reference.get();
        return Attendance.fromFirestore(updatedDoc);
      } else {
        // Create new attendance record
        final attendance = Attendance(
          id: docId,
          employeeId: employeeId,
          employeeName: employeeName,
          date: startOfDay,
          isPresent: isPresent,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(attendanceCollection)
            .doc(docId)
            .set(attendance.toFirestore());

        return attendance;
      }
    } catch (e) {
      throw Exception('Error marking attendance: $e');
    }
  }

  /// Delete attendance record by ID
  Future<void> deleteAttendance(String id) async {
    try {
      await _firestore.collection(attendanceCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting attendance: $e');
    }
  }

  /// Get all attendance records
  Future<List<Attendance>> getAllAttendance() async {
    try {
      final snapshot = await _firestore
          .collection(attendanceCollection)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Attendance.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error fetching all attendance: $e');
    }
  }
}

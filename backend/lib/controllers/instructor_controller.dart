import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';

class InstructorController {
  static Future<Response> getAssignedClients(Request request) async {
    try {
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null) {
        return Response.unauthorized('{"error": "Not authenticated"}');
      }

      final instructorId = userPayload['userId'] as int?;
      if (instructorId == null) {
        return Response.badRequest(body: '{"error": "Invalid token payload"}');
      }

      final db = Database();
      final clients = await db.getClientsForInstructor(instructorId);

      final clientsJson = clients.map((client) => client.toJson()).toList();
      
      return Response.ok(
        jsonEncode(clientsJson),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error getting assigned clients for instructor: $e');
      return Response.internalServerError(
        body: '{"error": "An unexpected error occurred"}',
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  static Future<Response> getAssignedTrainers(Request request) async {
    try {
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null) {
        return Response.unauthorized('{"error": "Not authenticated"}');
      }

      final instructorId = userPayload['userId'] as int?;
      if (instructorId == null) {
        return Response.badRequest(body: '{"error": "Invalid token payload"}');
      }

      final db = Database();
      final trainers = await db.getTrainersForInstructor(instructorId);

      final trainersJson = trainers.map((trainer) => trainer.toJson()).toList();
      
      return Response.ok(
        jsonEncode(trainersJson),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error getting assigned trainers for instructor: $e');
      return Response.internalServerError(
        body: '{"error": "An unexpected error occurred"}',
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  static Future<Response> getAssignedManager(Request request) async {
    try {
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null) {
        return Response.unauthorized('{"error": "Not authenticated"}');
      }

      final instructorId = userPayload['userId'] as int?;
      if (instructorId == null) {
        return Response.badRequest(body: '{"error": "Invalid token payload"}');
      }

      final db = Database();
      final manager = await db.getManagerForInstructor(instructorId);

      if (manager == null) {
        return Response.notFound('{"error": "Manager not found"}');
      }

      return Response.ok(
        jsonEncode(manager.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error getting assigned manager for instructor: $e');
      return Response.internalServerError(
        body: '{"error": "An unexpected error occurred"}',
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // === FOR ADMINS (getting data for a specific instructor) ===

  static Future<Response> getAssignedClientsForInstructor(Request request, String instructorIdStr) async {
    try {
      final instructorId = int.tryParse(instructorIdStr);
      if (instructorId == null) {
        return Response.badRequest(body: '{"error": "Invalid instructor ID"}');
      }

      final db = Database();
      final clients = await db.getClientsForInstructor(instructorId);
      final clientsJson = clients.map((client) => client.toJson()).toList();
      
      return Response.ok(
        jsonEncode(clientsJson),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error getting assigned clients for instructor: $e');
      return Response.internalServerError(body: '{"error": "An unexpected error occurred"}');
    }
  }

  static Future<Response> getAssignedTrainersForInstructor(Request request, String instructorIdStr) async {
    try {
      final instructorId = int.tryParse(instructorIdStr);
      if (instructorId == null) {
        return Response.badRequest(body: '{"error": "Invalid instructor ID"}');
      }

      final db = Database();
      final trainers = await db.getTrainersForInstructor(instructorId);
      final trainersJson = trainers.map((trainer) => trainer.toJson()).toList();
      
      return Response.ok(
        jsonEncode(trainersJson),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error getting assigned trainers for instructor: $e');
      return Response.internalServerError(body: '{"error": "An unexpected error occurred"}');
    }
  }

  static Future<Response> getAssignedManagerForInstructor(Request request, String instructorIdStr) async {
    try {
      final instructorId = int.tryParse(instructorIdStr);
      if (instructorId == null) {
        return Response.badRequest(body: '{"error": "Invalid instructor ID"}');
      }

      final db = Database();
      final manager = await db.getManagerForInstructor(instructorId);

      if (manager == null) {
        return Response.notFound('{"error": "Manager not found for instructor $instructorId"}');
      }

      return Response.ok(
        jsonEncode(manager.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error getting assigned manager for instructor: $e');
      return Response.internalServerError(body: '{"error": "An unexpected error occurred"}');
    }
  }
}
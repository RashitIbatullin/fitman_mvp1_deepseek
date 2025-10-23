import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../models/user_back.dart';

class ManagerController {
  static Future<Response> getAssignedClients(Request request) async {
    try {
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null) {
        return Response.unauthorized('{"error": "Not authenticated"}');
      }

      // Предполагаем, что 'userId' в payload токена - это ID пользователя (менеджера)
      final managerId = userPayload['userId'] as int?;
      if (managerId == null) {
        return Response.badRequest(body: '{"error": "Invalid token payload"}');
      }

      final db = Database();
      final clients = await db.getClientsForManager(managerId);

      final clientsJson = clients.map((client) => client.toJson()).toList();
      
      return Response.ok(
        jsonEncode(clientsJson),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error getting assigned clients: $e');
      return Response.internalServerError(
        body: '{"error": "An unexpected error occurred"}',
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  static Future<Response> getAssignedInstructors(Request request) async {
    try {
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null) {
        return Response.unauthorized('{"error": "Not authenticated"}');
      }

      final managerId = userPayload['userId'] as int?;
      if (managerId == null) {
        return Response.badRequest(body: '{"error": "Invalid token payload"}');
      }

      final db = Database();
      // TODO: Implement getInstructorsForManager in Database class
      final instructors = await db.getInstructorsForManager(managerId);

      final instructorsJson = instructors.map((instructor) => instructor.toJson()).toList();
      
      return Response.ok(
        jsonEncode(instructorsJson),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error getting assigned instructors: $e');
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

      final managerId = userPayload['userId'] as int?;
      if (managerId == null) {
        return Response.badRequest(body: '{"error": "Invalid token payload"}');
      }

      final db = Database();
      // TODO: Implement getTrainersForManager in Database class
      final trainers = await db.getTrainersForManager(managerId);

      final trainersJson = trainers.map((trainer) => trainer.toJson()).toList();
      
      return Response.ok(
        jsonEncode(trainersJson),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error getting assigned trainers: $e');
      return Response.internalServerError(
        body: '{"error": "An unexpected error occurred"}',
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  static Future<Response> assignClients(Request request, String managerIdStr) async {
    try {
      final managerId = int.tryParse(managerIdStr);
      if (managerId == null) {
        return Response.badRequest(body: '{"error": "Invalid manager ID"}');
      }

      final body = await request.readAsString();
      final payload = jsonDecode(body);
      
      final clientIdsRaw = payload['client_ids'] as List?;
      if (clientIdsRaw == null) {
        return Response.badRequest(body: '{"error": "client_ids is required"}');
      }
      
      final clientIds = clientIdsRaw.cast<int>().toList();

      final db = Database();
      await db.assignClientsToManager(managerId, clientIds);

      return Response.ok('{"message": "Clients assigned successfully"}');

    } catch (e) {
      print('Error assigning clients: $e');
      return Response.internalServerError(body: '{"error": "An unexpected error occurred"}');
    }
  }

  static Future<Response> getAssignedClientIds(Request request, String managerIdStr) async {
    try {
      final managerId = int.tryParse(managerIdStr);
      if (managerId == null) {
        return Response.badRequest(body: '{"error": "Invalid manager ID"}');
      }

      final db = Database();
      final clientIds = await db.getAssignedClientIds(managerId);

      return Response.ok(jsonEncode(clientIds), headers: {'Content-Type': 'application/json'});

    } catch (e) {
      print('Error getting assigned client IDs: $e');
      return Response.internalServerError(body: '{"error": "An unexpected error occurred"}');
    }
  }

  static Future<Response> assignInstructors(Request request, String managerIdStr) async {
    try {
      final managerId = int.tryParse(managerIdStr);
      if (managerId == null) {
        return Response.badRequest(body: '{"error": "Invalid manager ID"}');
      }

      final body = await request.readAsString();
      final payload = jsonDecode(body);
      
      final instructorIdsRaw = payload['instructor_ids'] as List?;
      if (instructorIdsRaw == null) {
        return Response.badRequest(body: '{"error": "instructor_ids is required"}');
      }
      
      final instructorIds = instructorIdsRaw.cast<int>().toList();

      final db = Database();
      await db.assignInstructorsToManager(managerId, instructorIds);

      return Response.ok('{"message": "Instructors assigned successfully"}');

    } catch (e) {
      print('Error assigning instructors: $e');
      return Response.internalServerError(body: '{"error": "An unexpected error occurred"}');
    }
  }

  static Future<Response> getAssignedInstructorIds(Request request, String managerIdStr) async {
    try {
      final managerId = int.tryParse(managerIdStr);
      if (managerId == null) {
        return Response.badRequest(body: '{"error": "Invalid manager ID"}');
      }

      final db = Database();
      final instructorIds = await db.getAssignedInstructorIds(managerId);

      return Response.ok(jsonEncode(instructorIds), headers: {'Content-Type': 'application/json'});

    } catch (e) {
      print('Error getting assigned instructor IDs: $e');
      return Response.internalServerError(body: '{"error": "An unexpected error occurred"}');
    }
  }

  static Future<Response> assignTrainers(Request request, String managerIdStr) async {
    try {
      final managerId = int.tryParse(managerIdStr);
      if (managerId == null) {
        return Response.badRequest(body: '{"error": "Invalid manager ID"}');
      }

      final body = await request.readAsString();
      final payload = jsonDecode(body);
      
      final trainerIdsRaw = payload['trainer_ids'] as List?;
      if (trainerIdsRaw == null) {
        return Response.badRequest(body: '{"error": "trainer_ids is required"}');
      }
      
      final trainerIds = trainerIdsRaw.cast<int>().toList();

      final db = Database();
      await db.assignTrainersToManager(managerId, trainerIds);

      return Response.ok('{"message": "Trainers assigned successfully"}');

    } catch (e) {
      print('Error assigning trainers: $e');
      return Response.internalServerError(body: '{"error": "An unexpected error occurred"}');
    }
  }

  static Future<Response> getAssignedTrainerIds(Request request, String managerIdStr) async {
    try {
      final managerId = int.tryParse(managerIdStr);
      if (managerId == null) {
        return Response.badRequest(body: '{"error": "Invalid manager ID"}');
      }

      final db = Database();
      final trainerIds = await db.getAssignedTrainerIds(managerId);

      return Response.ok(jsonEncode(trainerIds), headers: {'Content-Type': 'application/json'});

    } catch (e) {
      print('Error getting assigned trainer IDs: $e');
      return Response.internalServerError(body: '{"error": "An unexpected error occurred"}');
    }
  }
}

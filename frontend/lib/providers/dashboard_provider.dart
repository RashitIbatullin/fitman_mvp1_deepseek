import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_data.dart';
import '../services/api_service.dart';

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final data = await ApiService.getClientDashboardData();
  return DashboardData.fromJson(data);
});

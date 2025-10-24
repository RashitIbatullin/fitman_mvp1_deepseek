import 'package:flutter/material.dart';

import 'package:fitman_app/models/schedule_item.dart';

import 'package:fitman_app/services/api_service.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import 'client_preference_schedule.dart';



final scheduleProvider = FutureProvider<List<ScheduleItem>>((ref) async {

  return ApiService.getSchedule();

});



class SessionsScreen extends ConsumerWidget {

  const SessionsScreen({super.key});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final scheduleData = ref.watch(scheduleProvider);



    return Scaffold(

      appBar: AppBar(

        title: const Text('Занятия'),

      ),

      body: scheduleData.when(

        data: (schedule) => schedule.isEmpty

            ? _buildEmptyState(context)

            : _buildLessonsList(context, schedule),

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) => Center(child: Text('Ошибка: $error')),

      ),

    );

  }



  Widget _buildLessonsList(BuildContext context, List<ScheduleItem> schedule) {

    return ListView.builder(

      itemCount: schedule.length,

      itemBuilder: (context, index) {

        final item = schedule[index];

        return ListTile(

          title: Text(item.trainingPlanName),

          subtitle: Text(DateFormat('d MMM y, HH:mm', 'ru').format(item.startTime)),

          trailing: Chip(

            label: Text(item.status),

            backgroundColor: _getStatusColor(item.status),

          ),

        );

      },

    );

  }



  Widget _buildEmptyState(BuildContext context) {

    return Center(

      child: Padding(

        padding: const EdgeInsets.all(16.0),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Text(

              'Вам еще не назначены занятия. Заполните, пожалуйста, предпочтения по времени.',

              textAlign: TextAlign.center,

            ),

            const SizedBox(height: 16),

            ElevatedButton(

              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientPreferenceSchedule()));
              },

              child: const Text('Заполнить предпочтения'),

            ),

          ],

        ),

      ),

    );

  }



  Color _getStatusColor(String status) {

    switch (status) {

      case 'completed':

        return Colors.green;

      case 'scheduled':

        return Colors.blue;

      case 'canceled':

        return Colors.red;

      default:

        return Colors.grey;

    }

  }

}

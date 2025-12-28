import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/schedule.dart';
import 'package:myapp/services/schedule_service.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/routes/app_router.dart';

class ScheduleListPage extends StatelessWidget {
  const ScheduleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Schedule>>(
      stream: ScheduleService().getSchedules(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text('Tidak ada jadwal.', style: GoogleFonts.lato()));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Schedule schedule = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(schedule.day, style: GoogleFonts.poppins()),
                subtitle: Text(schedule.names.join(', '),
                    style: GoogleFonts.lato()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        context.push(
                            '${AppRoutes.scheduleUpdate}/${schedule.id}');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        ScheduleService().deleteSchedule(schedule.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Syncfusion Calendar Example'),
        ),
        body: MyCalendar(),
      ),
    );
  }
}

class MyCalendar extends StatelessWidget {
  fetchUserData() async {
    final response = await http
        .get(Uri.parse('https://event-calendar-3.onrender.com/list_events'));
    if (response.statusCode == 200) {
      // Parse the response body
      var userData = jsonDecode(response.body);
      // Process the userData as needed
      for (var userDataItem in userData) {
        meetings.add(Appointment(
          color: Colors.green,
          startTime: DateTime.parse(userDataItem["from_date"]),
          endTime: DateTime.parse(userDataItem["from_date"]),
          subject: userDataItem["description"],
          isAllDay: true,
        ));
      }
    } else {
      // Handle error response
      print('Failed to load user data: ${response.statusCode}');
      return;
    }
  }

  RxList<Appointment> meetings = <Appointment>[].obs;

  @override
  Widget build(BuildContext context) {
    fetchUserData(); // Call fetchUserData() to populate the meetings list

    return Container(
      height: 500,
      child: Obx(
        () {
          // Check if meetings is initialized
          if (meetings.isEmpty) {
            // If not initialized, return a placeholder widget or empty container
            return Center(
              child: CircularProgressIndicator(), // Placeholder widget
            );
          } else {
            // If initialized, return SfCalendar with meetings data
            return SfCalendar(
              view: CalendarView.month,
              dataSource: CustomCalendarDataSource(getAppointment(meetings)),
              onTap: (CalendarTapDetails details) {
                // Handle tap events here
                // ...
              },
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
            );
          }
        },
      ),
    );
  }

  RxList<Appointment> getAppointment(meetings) {
    RxList<Appointment> meeting = meetings;

    return meeting;
  }

  void _addNewAppointment(BuildContext context, DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('New Appointment'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter Subject'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String subject = controller.text;
                meetings.add(Appointment(
                  color: Colors.green,
                  startTime: selectedDate,
                  endTime: selectedDate,
                  subject: subject,
                  isAllDay: true,
                ));
                Navigator.of(context).pop();
                print(meetings);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class CustomCalendarDataSource extends CalendarDataSource {
  CustomCalendarDataSource(List<Appointment> source) {
    appointments = source;
  }
}

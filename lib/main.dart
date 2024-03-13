import 'dart:convert';

import 'package:eventbooking/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: const Text(
            'Multi-calendar Management App',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const LoginPage(),
      ),
    );
  }
}

class MyCalendar extends StatelessWidget {
  fetchUserData() async {
    final response = await http
        .get(
        Uri.parse('https://event-calendar-3.onrender.com/list_events'),
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET,PUT,POST,DELETE,PATCH,OPTIONS"
        });
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
            return const Center(
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
                if (details.targetElement == CalendarElement.calendarCell) {
                  // Check if the tapped element is a calendar cell (date)
                  isDateBooked(DateTime selectedDate) {
                    for (var appointment in meetings) {
                      if (appointment.startTime.year == selectedDate.year &&
                          appointment.startTime.month == selectedDate.month &&
                          appointment.startTime.day == selectedDate.day) {
                        return true; // Date is already booked
                      }
                    }
                    return false; // Date is not booked
                  }

                  DateTime selectedDate = details.date!;
                  bool isEventBooked = isDateBooked(selectedDate);
                  if (isEventBooked) {
                    // Show a snack bar if the event is already booked
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('The date is already booked with an event.'),
                      ),
                    );
                  } else {
                    _addNewAppointment(context, selectedDate);
                  }
                }
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
          title: const Text('New Appointment'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter Subject'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String subject = controller.text;
                String formattedDate =
                    DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(selectedDate);
                meetings.add(Appointment(
                  color: Colors.green,
                  startTime: selectedDate,
                  endTime: selectedDate,
                  subject: subject,
                  isAllDay: true,
                ));
                createEvent() async {
                  // Define the request body
                  // Map<String, dynamic> requestBody = {
                  //   "name": "Meeting with Client",
                  //   "date": "2024-03-25",
                  //   "from_date": formattedDate,
                  //   "to_date": formattedDate,
                  //   "status": "Busy",
                  //   "description": subject,
                  //   "user_id": "2",
                  //   "created_by_id": "456"
                  // };
                  Map<String, dynamic> requestBody = {
                    "name": "test",
                    "date": "2024-03-15",
                    "from_date": "2024-03-14T09:00:00",
                    "to_date": "2024-03-14T10:00:00",
                    "status": "Busy",
                    "description": "Discuss project requirements",
                    "user_id": 2,
                    "created_by_id": 456
                  };
                  try {
                    // Send a POST request to the specified URL with the request body
                    final response = await http.post(
                        Uri.parse(
                            'https://event-calendar-3.onrender.com//create_event'),
                        // body: jsonEncode(requestBody));
                        body: requestBody);
                    print(requestBody);

                    // Check if the request was successful (status code 200)
                    if (response.statusCode == 200) {
                      // Parse the response body
                      var responseData = jsonDecode(response.body);
                      // Process the responseData as needed
                      print('Event created successfully: $responseData');
                    } else {
                      // Handle error response
                      print('Failed to create event: ${response.statusCode}');
                    }
                  } catch (e) {
                    // Handle exceptions
                    print('Error creating event: $e');
                  }
                }

                await createEvent();

                Navigator.of(context).pop();
                print(meetings);
              },
              child: const Text('Add'),
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

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
  // final CalendarController _controller = CalendarController();
  // final MyCalendarController _myController = Get.put(MyCalendarController());

  fetchUserData() async {
    final response = await http
        .get(Uri.parse('https://event-calendar-3.onrender.com/list-events'));
    if (response.statusCode == 200) {
      // Parse the response body
      var userData = jsonDecode(response.body);
      // Process the userData as needed
      print(userData);
      return userData;
    } else {
      // Handle error response
      print('Failed to load user data: ${response.statusCode}');
      return [].obs;
    }
  }

  RxList<Appointment> meetings = <Appointment>[].obs;

  @override
  Widget build(BuildContext context) {
    meetings = fetchUserData();
    return Container(
      height: 500,
      child: Obx(
        () => SfCalendar(
          view: CalendarView.month,
          // dataSource: _myController.dataSource.value,
          dataSource: CustomCalendarDataSource(getAppointment(meetings)),
          // controller: _controller,
          onTap: (CalendarTapDetails details) {
            // Handle tap events here
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
                  SnackBar(
                    content: Text('The date is already booked with an event.'),
                  ),
                );
              } else {
                _addNewAppointment(context, selectedDate);
              }
            }
          },
          // specialRegions:
          //     _getSpecialRegions(_myController.dataSource.value!.appointments),
          monthViewSettings: const MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        ),
      ),
    );
  }

  RxList<Appointment> getAppointment(meetings) {
    RxList<Appointment> meeting = meetings;
    // final DateTime today = DateTime.now();
    // final DateTime startdate = DateTime.now();
    // meetings.add(Appointment(
    //     color: Colors.green,
    //     startTime: startdate,
    //     endTime: startdate,
    //     subject: "My n",
    //     isAllDay: true));
    // return meetings;
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

// List<TimeRegion> _getSpecialRegions(List<dynamic>? appointments) {
//   List<TimeRegion> specialRegions = [];
//   if (appointments != null) {
//     for (Appointment appointment in appointments) {
//       specialRegions.add(TimeRegion(
//         startTime: appointment.startTime,
//         endTime: appointment.endTime,
//         color: appointment.color,
//         enablePointerInteraction: true,
//         text: appointment.subject,
//         textStyle: TextStyle(color: Colors.white),
//       ));
//     }
//   }
//   return specialRegions;
// }

//   void _handleCalendarTap(CalendarTapDetails details, context) {
//     if (details.targetElement == CalendarElement.calendarCell) {
//       // Show a dialog to add event details
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Add Event'),
//             content: TextFormField(
//               decoration: InputDecoration(hintText: 'Enter event details'),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   // Add the event to the data source
//                   if (_myController.dataSource.value != null &&
//                       _myController.dataSource.value!.appointments != null) {
//                     Appointment newAppointment = Appointment(
//                       startTime: details.date!,
//                       endTime: details.date!.add(Duration(hours: 1)),
//                       subject: 'New Event',
//                       color: Colors.green,
//                       isAllDay: false,
//                     );
//                     _myController.dataSource.update((dataSource) {
//                       dataSource!.appointments!.add(newAppointment);
//                     });
//                   } else {
//                     Appointment newAppointment = Appointment(
//                       startTime: details.date!,
//                       endTime: details.date!.add(Duration(hours: 1)),
//                       subject: 'New Event',
//                       color: Colors.green,
//                       isAllDay: false,
//                     );
//                     _myController.dataSource.update((dataSource) {
//                       dataSource!.appointments = [];
//                       dataSource.appointments!.add(newAppointment);
//                     });
//                   }
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('Add'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
// }

// class MyCalendarController extends GetxController {
//   Rx<CustomCalendarDataSource> dataSource = Rx<CustomCalendarDataSource>(
//     CustomCalendarDataSource(
//       appointments: [
//         Appointment(
//           startTime: DateTime.now(),
//           endTime: DateTime.now().add(Duration(hours: 2)),
//           subject: 'Meeting',
//           color: Colors.blue,
//           isAllDay: false,
//         ),
//       ],
//     ),
//   );
// }

// class Appointment {
//   final DateTime startTime;
//   final DateTime endTime;
//   final String subject;
//   final Color color;
//   final bool isAllDay;

//   Appointment({
//     required this.startTime,
//     required this.endTime,
//     required this.subject,
//     required this.color,
//     required this.isAllDay,
//   });

class CustomCalendarDataSource extends CalendarDataSource {
  CustomCalendarDataSource(List<Appointment> source) {
    appointments = source;
  }
}

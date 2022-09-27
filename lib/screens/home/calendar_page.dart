import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool isLoading = true;
  List<String> date_events = [];

  Map<String, List<String>> events = {
    // '2022-9-9' : ["e", "b"],
    // '2022-9-10' : ["e", "b"]
  };

  _getEventsForDay(DateTime day) {
    return events["${day.year}-${day.month}-${day.day}"] ?? [];
  }

  Future<void> _loadData(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      var result = await http.get(Uri.parse(api_endpoint + "api/v1/events"));
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        print(response);
        if (response['status']) {
          if (mounted) {
            if (response['data'] != null) {
              for (MapEntry e in response['data'].entries) {
                List<String> v = [];
                e.value.forEach((k) {
                  v.add(k['details'].toString());
                });
                DateTime t = DateTime.parse(e.key);

                events["${t.year}-${t.month}-${t.day}"] = v;
              }
              date_events = events[
                      "${_selectedDay.year}-${_selectedDay.month}-${_selectedDay.day}"] ??
                  [];
              setState(() {});
            }
          }
        } else {
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Error!',
                message: 'Something went wrong!',
                contentType: ContentType.failure,
              ),
            ));
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error!',
              message: 'Something went wrong!',
              contentType: ContentType.failure,
            ),
          ));
      }
    } catch (e) {
      print(e);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: 'Something went wrong!',
            contentType: ContentType.failure,
          ),
        ));
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 70,
              backgroundColor: Colors.white,
              leading: BackButton(
                color: Colors.black,
              ),
            ),
            body: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: primaryColorRGB(1),
                    ),
                  )
                : Column(
                    children: [
                      TableCalendar(
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        firstDay: DateTime.utc(2010, 10, 16),
                        lastDay: DateTime.utc(2040, 3, 14),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        eventLoader: (day) {
                          return _getEventsForDay(day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay =
                                focusedDay; // update `_focusedDay` here as well
                            date_events = events[
                                    "${_selectedDay.year}-${_selectedDay.month}-${_selectedDay.day}"] ??
                                [];
                          });
                        },
                      ),
                      Expanded(
                          child: ListView.builder(
                        padding: EdgeInsets.only(top: 15, left: 15, right: 15),
                        itemCount: date_events.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            child: ListTile(
                              title: Text(date_events[index]),
                            ),
                          );
                        },
                      ))
                    ],
                  )));
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel, Event, EventList;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_wjob/cammon/color_extension.dart';
import 'package:flutter_wjob/classes/class_job_item.dart';
import 'package:flutter_wjob/view/filtre/jobmatching.dart';

class CalendarScreen extends StatefulWidget {
  List<JobItem> jobList = [];
  CalendarScreen({Key? key, required this.jobList}) : super(key: key);
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _nextMonth;
  late DateTime _selectedDate;
  late EventList<Event> _markedDates;
  List<DateTime> _selectableDates = [];

  @override
  void initState() {
    super.initState();
    _nextMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 1);
    _selectedDate = _nextMonth;
    _markedDates = EventList<Event>(events: {});
    _generateRandomSelectableDays();
  }

  void _generateRandomSelectableDays() {
    int daysInNextMonth = DateTime(_nextMonth.year, _nextMonth.month + 1, 0).day;
    Random random = Random();
    Set<int> randomDays = {};

    while (randomDays.length < 4) {
      int randomDay = random.nextInt(daysInNextMonth) + 1;
      randomDays.add(randomDay);
    }

    for (int day in randomDays) {
      DateTime availableDay = DateTime(_nextMonth.year, _nextMonth.month, day);
      _selectableDates.add(availableDay);
    }
  }

  void _navigateToHomeScreen() {
    if (_selectableDates.contains(_selectedDate)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Jobmatching(jobs: widget.jobList,),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a valid date!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Date'),
        backgroundColor: TColor.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Choose an available date from next month',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: CalendarCarousel<Event>(
              onDayPressed: (date, events) {
                if (_selectableDates.contains(date)) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              selectedDateTime: _selectedDate,
              todayBorderColor: Colors.transparent,
              todayButtonColor: Colors.transparent,
              daysHaveCircularBorder: true,
              thisMonthDayBorderColor: Colors.transparent,
              nextMonthDayBorderColor: Colors.transparent,
              prevMonthDayBorderColor: Colors.transparent,
              markedDatesMap: _markedDates,
              markedDateShowIcon: false,
              markedDateMoreShowTotal: false,
              showHeader: true,
              // headerText: '${_nextMonth.year} - ${_nextMonth.month}',
              minSelectedDate: _nextMonth,
              maxSelectedDate: DateTime(_nextMonth.year, _nextMonth.month + 1, 0),
              daysTextStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              weekendTextStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              todayTextStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              selectedDayTextStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              selectedDayButtonColor: TColor.primary,
              selectedDayBorderColor: Colors.transparent,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: _navigateToHomeScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 13,horizontal: 45),
                shadowColor: Colors.black45,
                elevation: 5,
              ),
              child: Text(
                'Next',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final DateTime selectedDate;

  HomeScreen({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen'), backgroundColor: TColor.primary),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          margin: EdgeInsets.all(20),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event, size: 50, color: TColor.primary),
                SizedBox(height: 10),
                Text(
                  'Selected Date:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 5),
                Text(
                  '${selectedDate.toLocal()}'.split(' ')[0],
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: TColor.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
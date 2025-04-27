import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_wjob/api_service.dart';
import 'package:flutter_wjob/classes/class_job_item.dart';
import 'package:flutter_wjob/view/filtre/jobmatching.dart';


class FilterJob extends StatefulWidget {
  @override
  _FilterJobState createState() => _FilterJobState();
}

DateTime generateRandomDate(String datePostedFilter, Random random) {
  final now = DateTime.now();
  final random = Random();

  // Create different ranges based on the filter
  switch (datePostedFilter) {
    case 'Today':
      return now.subtract(Duration(minutes: random.nextInt(60 * 24))); 
    case 'Last 3 days':
      return now.subtract(Duration(days: random.nextInt(3)));
    case 'Last 7 days':
      return now.subtract(Duration(days: random.nextInt(7)));
    case 'Last 30 days':
      return now.subtract(Duration(days: random.nextInt(30)));
    default:
      return now.subtract(Duration(days: random.nextInt(30)));
  }
}
String formatDate(DateTime date, {bool isTimeFormat = false}) {
 if (isTimeFormat) {
    return DateFormat('HH:mm').format(date); 
  } else {
    return DateFormat('MMM dd').format(date); 
  }
}

String getTimeDifference(DateTime jobDate, {bool isTimeFormat = false}) {
  final currentDate = DateTime.now();
  final difference = currentDate.difference(jobDate);

  if (difference.inDays < 1) {
    return isTimeFormat ? formatDate(jobDate, isTimeFormat: true) : 'Today';
  } else if (difference.inDays == 1) {
    return isTimeFormat ? formatDate(jobDate, isTimeFormat: true) : 'Yesterday';
  } else {
    return '${difference.inDays} days ago';
  }
}


class _FilterJobState extends State<FilterJob> {
  bool hasVerification = true;
  bool under10Applications = true;
  bool isLoading = false; // To manage the loading state

  String? selectedJobTitle;
  String? selectedLocation;
  String? selectedExperienceLevel;
  String? selectedSalaryRange;
  String? selectedDatePosted;

  Future<void> _showOptionDialog({
    required String title,
    required List<String> options,
    required Function(String) onSelected,
  }) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(title),
          children: options
              .map((e) => SimpleDialogOption(
                    child: Text(e),
                    onPressed: () => Navigator.pop(context, e),
                  ))
              .toList(),
        );
      },
    );

    if (selected != null) onSelected(selected);
  }

  bool _isValidDate(String dateStr) {
    try {
      DateTime.parse(dateStr); // Try parsing the date
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    ListTile(
                      title: Text("Experience level: ${selectedExperienceLevel ?? "Any"}"),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _showOptionDialog(
                        title: "Select Experience Level",
                        options: ['Internship', 'Junior', 'Mid', 'Senior', 'Lead'],
                        onSelected: (val) => setState(() => selectedExperienceLevel = val),
                      ),
                    ),
                    ListTile(
                      title: Text("Job Title: ${selectedJobTitle ?? "Any"}"),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _showOptionDialog(
                        title: "Select Job Title",
                        options: ['Flutter Developer', 'Backend Developer', 'Data Analyst'],
                        onSelected: (val) => setState(() => selectedJobTitle = val),
                      ),
                    ),
                    SwitchListTile(
                      title: Text("Has Verification"),
                      value: hasVerification,
                      activeColor: Color(0xFF40E0D0),
                      onChanged: (value) {
                        setState(() {
                          hasVerification = value;
                        });
                      },
                    ),
                    ListTile(
                      title: Text("Location: ${selectedLocation ?? "Any"}"),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _showOptionDialog(
                        title: "Select Location",
                        options: ['Tunis', 'Sfax', 'Sousse', 'Remote'],
                        onSelected: (val) => setState(() => selectedLocation = val),
                      ),
                    ),
                    ListTile(
                      title: Text("Salary Range: ${selectedSalaryRange ?? "Any"}"),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _showOptionDialog(
                        title: "Select Salary Range",
                        options: ['<1000', '1000-2000', '2000-3000', '>3000'],
                        onSelected: (val) => setState(() => selectedSalaryRange = val),
                      ),
                    ),
                    ListTile(
                      title: Text("Date Posted: ${selectedDatePosted ?? "Any"}"),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _showOptionDialog(
                        title: "Select Date Posted",
                        options: ['Today', 'Last 3 days', 'Last 7 days', 'Last 30 days'],
                        onSelected: (val) => setState(() => selectedDatePosted = val),
                      ),
                    ),
                    SwitchListTile(
                      title: Text("Under 10 Applications"),
                      value: under10Applications,
                      activeColor: Color(0xFF40E0D0),
                      onChanged: (value) {
                        setState(() {
                          under10Applications = value;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true; // Show loading indicator
                          });

                          final jobs = await ApiService().filterJobs(
                            jobTitle: selectedJobTitle,
                            location: selectedLocation,
                            experienceLevel: selectedExperienceLevel,
                            salaryRange: selectedSalaryRange,
                            datePosted: selectedDatePosted,
                          );
                          print(jobs);

                          // Map the jobs to JobItem objects
                          final random = Random();
                          List<JobItem> jobItems  = jobs.map((job) {
                            final datePosted = job['date_posted'] != null && _isValidDate(job['date_posted'])
                            ? DateTime.parse(job['date_posted'])
                            : generateRandomDate(selectedDatePosted ?? 'Last 30 days', random);

                            // Format date and calculate time difference
                            final formattedDate = formatDate(datePosted, isTimeFormat: selectedDatePosted != null && selectedDatePosted == 'Today');
                            final timeAgo = getTimeDifference(datePosted, isTimeFormat: selectedDatePosted != null && selectedDatePosted == 'Today');

                            return JobItem(
                              title: job['title'] ?? "No title",
                              location: job['location'] ?? "No location",
                              timeAgo: timeAgo,
                              icon: Icons.business, 
                            );
                          }).toList();

                          if (mounted) {
                            setState(() {
                              isLoading = false; 
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Jobmatching(jobs: jobItems),
                              ),
                            );
                          }
                        },
                        child: isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text("Apply Filters"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF40E0D0),
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

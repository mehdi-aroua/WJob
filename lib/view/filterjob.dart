import 'package:flutter/material.dart';

class FilterJob extends StatefulWidget {
  @override
  _FilterJobState createState() => _FilterJobState();
}

class _FilterJobState extends State<FilterJob> {
  bool hasVerification = true; 
  bool under10Applications = true;

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
              // Filter list
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    ListTile(
                      title: Text("Experience level"),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    ListTile(
                      title: Text("Job Type"),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    // Functional Switch
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
                      title: Text("Location"),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    ListTile(
                      title: Text("Industry"),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    ListTile(
                      title: Text("Title"),
                      trailing: Icon(Icons.chevron_right),
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

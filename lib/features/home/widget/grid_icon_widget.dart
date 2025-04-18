import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'icon_home_widget.dart';

class GridIconWidget extends StatelessWidget {
  const GridIconWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;

          if (isWideScreen) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _buildIconWidgets(context)),
            );
          } else {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildIconWidgets(context).sublist(0, 3),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildIconWidgets(context).sublist(3),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  List<Widget> _buildIconWidgets(BuildContext context) {
    return [
      IconHomeWidget(
        iconName: Icons.campaign,
        iconDescription: 'announcements'.tr(),
        onTap: () {
          // Navigate to announcements page
        },
      ),
      IconHomeWidget(
        iconName: Icons.event,
        iconDescription: 'events'.tr(),
        onTap: () {
          // Navigate to events page
        },
      ),
      IconHomeWidget(
        iconName: Icons.volunteer_activism,
        iconDescription: 'donations'.tr(),
        onTap: () {
          // Navigate to donations page
        },
      ),
      IconHomeWidget(
        iconName: Icons.school,
        iconDescription: 'classes'.tr(),
        onTap: () {
          // Navigate to Islamic classes page
        },
      ),
      IconHomeWidget(
        iconName: Icons.calendar_today,
        iconDescription: 'calendar'.tr(),
        onTap: () {
          // Navigate to Islamic calendar page
        },
      ),
      IconHomeWidget(
        iconName: Icons.more_horiz,
        iconDescription: 'more'.tr(),
        onTap: () {
          _showMoreOptions(context);
        },
      ),
    ];
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: [
            ListTile(
              leading: Icon(Icons.library_books),
              title: Text('library'.tr()),
              onTap: () {
                // Navigate to Islamic library page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('community'.tr()),
              onTap: () {
                // Navigate to community page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('q_and_a'.tr()),
              onTap: () {
                // Navigate to Q&A page
                Navigator.pop(context);
              },
            ),
            // Add more options as needed
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hobby_reads_flutter/screens/admin/admin_nav_bar.dart';
import 'package:hobby_reads_flutter/widgets/app_footer.dart';

class AdminScaffold extends StatelessWidget {
  final Widget body;
  final String currentRoute;

  const AdminScaffold({
    super.key,
    required this.body,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
                Expanded(
                  child: body,
                ),
                const AppFooter(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AdminNavBar(currentRoute: currentRoute),
          ),
        ],
      ),
    );
  }
} 
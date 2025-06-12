import 'package:flutter/material.dart';
import 'package:hobby_reads_flutter/widgets/app_footer.dart';
import 'package:hobby_reads_flutter/widgets/nav_app_bar.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final bool useNavBar;
  final String? currentRoute;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.useNavBar = true,
    this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final appBar = useNavBar 
      ? NavAppBar(currentRoute: currentRoute ?? ModalRoute.of(context)?.settings.name ?? '')
      : AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(title),
          actions: actions,
        );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 16),
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
            child: appBar,
          ),
        ],
      ),
    );
  }
} 
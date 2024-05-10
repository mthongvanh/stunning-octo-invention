import 'package:flutter/material.dart';
import 'package:stunning_octo_invention/navigation/app_router.dart';

import 'presentation/pages/app/app.dart';
import 'presentation/pages/map/map_controller.dart';
import 'presentation/pages/search/search_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

/// [MainApp] will lock the height at 800px with an aspect ratio of 11.7/25.0
/// to simulate a phone in portrait mode
class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final controller = MapController();
  final focusNode = FocusNode();



  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: SizedBox(
                height: 800,
                child: AspectRatio(
                  aspectRatio: 11.7 / 25.0,
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    onGenerateRoute: AppRouter.call,
                    home: AppWidget(
                        controller,
                        focusNode,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

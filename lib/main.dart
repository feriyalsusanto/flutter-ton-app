import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:ton_miniapp/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.cupertino(
      title: 'Flutter Web App',
      debugShowCheckedModeBanner: false,
      cupertinoThemeBuilder: (context, theme) {
        return theme.copyWith(applyThemeToAll: true, primaryColor: Colors.blue);
      },
      home: const HomePage(),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: child,
          ),
        );
      },
    );
  }
}

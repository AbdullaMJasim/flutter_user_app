import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/auth_view_model.dart';
import 'views/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/theme.dart'; // Import your new theme file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // First, create the text theme using your utility.
    final textTheme = createTextTheme(context, 'Lato', 'Montserrat');
    // Then, create an instance of your MaterialTheme.
    final materialTheme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'Flutter Demo',
      // Finally, apply the light theme from your MaterialTheme instance.
      theme: materialTheme.light(), 
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

import 'package:therapist_app/constants/global_variables.dart';
import 'package:therapist_app/features/auth/screens/auth_screen.dart';
import 'package:therapist_app/features/auth/services/auth_service.dart';
import 'package:therapist_app/provider/user_provider.dart';
import 'package:therapist_app/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'common/widgets/bottom_bar.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
  FlutterNativeSplash.remove();
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authService.getUserData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FocusMi',
      theme: ThemeData(
        scaffoldBackgroundColor: GlobalVariables.backgroundColor,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        colorScheme: const ColorScheme.light(
          primary: GlobalVariables.primaryText,
        ),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: Provider.of<UserProvider>(context).user.token.isNotEmpty
          ? NavBarRoots()
          : const AuthScreen(),
    );
  }
}

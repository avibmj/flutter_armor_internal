import 'package:flutter/material.dart';
import 'ui/main_screen.dart';
import 'ui/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan plugin sudah siap
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'myARTOMORO',
      debugShowCheckedModeBanner: false,
      home: CheckAuth(),
      
    );
  }
}
class CheckAuth extends StatefulWidget{
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth>{
  bool isAuth = false;

  @override
  void initState(){
    super.initState();
    _checkIfLoggedIn();
  }

  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if(token != null){
      if(mounted){
        setState(() {
          isAuth = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context){
    Widget child;
    if (isAuth) {
      child = MainScreen(); // ganti Home -> MainScreen
    } else {
      child = Login();
    }


    return Scaffold(
      body: child,
    );
  }
}
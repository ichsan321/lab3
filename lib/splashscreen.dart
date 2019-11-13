import 'package:flutter/material.dart';
import 'loginscreen.dart'; 

void main() => runApp(SplashScreen()); 

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(primarySwatch: MaterialColor(0xFF18FFFF, color)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
      body: new Container( decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: AssetImage('asset/images/background1.jpg'),
                  fit: BoxFit.fill)),
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,// tata letak loaing screen 
      children: <Widget>[
      Image.asset(
      'asset/images/mytolongbeli.png',
       scale: 2.5,
        ),
      SizedBox(
      height: 20,
      ),// ukuran pada loading 
      new ProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressIndicator extends StatefulWidget {
  @override
  _ProgressIndicatorState createState() => new _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
  with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
    duration: const Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          if (animation.value > 0.99) {
            //print('Sucess Login');
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage()));
          }
        });
      });
    controller.repeat();
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Container(
      width: 200, // panjang loading bar 
      color: Colors.teal,
      child: LinearProgressIndicator(
        value: animation.value,
        backgroundColor: Colors.black, // warna pada mengurangi bar loading
        valueColor:
        new AlwaysStoppedAnimation<Color>(Color.fromRGBO(40, 206, 209, 1)), // warna pada bar loading
      ),
    ));
  }
}

Map<int, Color> color = {
  50: Color.fromRGBO(40, 206, 209, .1),
  100: Color.fromRGBO(40, 206, 209, .2),
  200: Color.fromRGBO(40, 206, 209, .3),
  300: Color.fromRGBO(40, 206, 209, .4),
  400: Color.fromRGBO(40, 206, 209, .5),
  500: Color.fromRGBO(40, 206, 209, .6),
  600: Color.fromRGBO(40, 206, 209, .7),
  700: Color.fromRGBO(40, 206, 209, .8),
  800: Color.fromRGBO(40, 206, 209, .9),
  900: Color.fromRGBO(40, 206, 209, 1),
};

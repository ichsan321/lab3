import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // buat menyimpan value pada pref
import 'package:mytolongbeli/registrationscreen.dart'; // untuk mengarah ke registration
import 'package:toast/toast.dart';
import 'package:mytolongbeli/mainscreen.dart';
import 'package:mytolongbeli/forgotpassword.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;

String urlLogin = "http://michannael.com/mytolongbeli/php/login_user.php";
String urlSecurityCodeForResetPass =
    "http://michannael.com/mytolongbeli/php/secure_code.php";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginPage());
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isChecked = false; // variabel untuk ceklis box
  final TextEditingController _emcontroller =
      TextEditingController(); // declare variabel email
  String _email = "";
  final TextEditingController _pscontroller =
      TextEditingController(); // declare variabel password
  String _pass = "";

  @override
  void initState() {
    // method untuk load data shared pref
    _loadPref();
    print('Init: $_email');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // membuat interface login
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: new Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: AssetImage(
                    'asset/images/background1.jpg'), // untuk background belakang
                fit: BoxFit.fill)),
        padding: EdgeInsets.all(30.0), // jarak sisi tepi pada padding
        child: Column(
          // untuk foto
          mainAxisAlignment:
              MainAxisAlignment.center, // untuk mengatur tata letak widget
          children: <Widget>[
            Image.asset(
              'asset/images/mytolongbeli.png', // foto berdasarkan letaknay di folder tersebut
              scale: 2.5, // mengatur size foto
            ),
            TextField(
                // Email text
                controller: _emcontroller, // variabel email
                decoration: InputDecoration(
                  labelText: 'Email', // label email tampill
                  labelStyle: new TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  icon: Icon(Icons.email),
                )),
            TextField(
              // password
              controller: _pscontroller,
              decoration: InputDecoration(
                  labelText: 'Password', // label password tampil
                  labelStyle: new TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  icon: Icon(Icons.lock)),
              obscureText:
                  true, // untuk membuat tanda bintang supaya tidak nampak
            ),
            SizedBox(
              height: 10,
            ),
            MaterialButton(
              // tombol buat login
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      20.0)), //untuk atur radius tombol tepi
              minWidth: 300,
              height: 50,
              child: Text('LOGIN'),
              color: Color.fromRGBO(40, 206, 209, 1),
              textColor: Colors.white,
              elevation: 20,
              onPressed: _onLogin, // nama variabel login button
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool value) {
                    _onChange(value);
                  },
                ),
                Text('Remember Me', style: TextStyle(fontSize: 16))
              ],
            ),
            GestureDetector(
                onTap: _onRegister,
                child: Text('Register new account',
                    style: TextStyle(fontSize: 16))),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
                onTap: _onForgot,
                child: Text('Forgot Account', style: TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }

  void _onLogin() {
    // method untuk login button
    _email = _emcontroller.text;
    _pass = _pscontroller.text;
    if (_isEmailValid(_email) && (_pass.length > 4)) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(message: "Login in");
      pr.show();
      http.post(urlLogin, body: {
        "email": _email,
        "password": _pass,
      }).then((res) {
        print(res.statusCode);
        var string = res.body;
        List dres = string.split(",");
        print(dres);
        Toast.show(dres[0], context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        if (dres[0] == "success") {
          pr.dismiss();
          print("Radius:");
          print(dres[3]);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(
                      email: _email,
                      radius: dres[1],
                      name: dres[2],
                      credit: dres[3])));
        } else {
          pr.dismiss();
        }
      }).catchError((err) {
        pr.dismiss();
        print(err);
      });
    } else {}
  }

  void _onChange(bool value) {
    setState(() {
      _isChecked = value;
      print('Check value $value');
      _savePref(value);
    });
  }

  void _savePref(bool value) async {
    // untuk menympan value pada cek box(remember me)
    print('Inside loadpref');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _email = _emcontroller.text;
    _pass = _pscontroller.text;

    if (value) {
      if (_isEmailValid(_email)) {
        // jika value benar maka di simpan
        // Store value in pref
        await prefs.setString('email', _email);
        await prefs.setString('pass', _pass);
        print(' Pref Stored ');
      } else {
        print('Email invalid!!!'); //jika email salah
        setState(() {
          _isChecked = false;
        });
      }
    } else {
      await prefs.setString('email', ''); // buat hapus value di store prefs
      await prefs.setString('pass', '');
      setState(() {
        _emcontroller.text = '';
        _pscontroller.text = '';
        _isChecked = false;
      });
      print('pref removed');
      // remove value from preff
    }
  }

  void _loadPref() async {
    // untuk menampilkan value pada pref
    print('Inside loadpref');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _email = (prefs.getString('email'));
    _pass = (prefs.getString('pass'));
    print(_email);
    print(_pass);

    if (_email.length > 1) {
      _emcontroller.text = _email;
      _pscontroller.text = _pass;
      setState(() {
        _isChecked = true;
      });
    } else {
      print('No pref');
      setState(() {
        _isChecked = false;
      });
    }
  }

  void _onRegister() {
    print('onRegister');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterScreen()));
  }

  void _onForgot() {
    print('Forgot');
    _email = _emcontroller.text;

    if (_isEmailValid(_email)) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(message: "Sending Email");
      pr.show();
      http.post(urlSecurityCodeForResetPass, body: {
        "email": _email,
        "password": _pass,
      }).then((res) {
        print("secure code : " + res.body);
        if (res.body == "error") {
          pr.dismiss();

          Toast.show('error', context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else {
          pr.dismiss();

          _saveEmailForPassReset(_email);
          _saveSecureCode(res.body); //save secure code for password reset

          Toast.show('Security code sent to your email', context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ResetPassword()));
        }
      }).catchError((err) {
        pr.dismiss();
        print(err);
      });
    } else {
      Toast.show('Invalid Email', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _saveEmailForPassReset(String code) async {
    print('saving preferences');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('resetPassEmail', code);
  }

  void _saveSecureCode(String code) async {
    print('saving preferences');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('secureCode', code);
  }
}

bool _isEmailValid(String email) {
  return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
}

import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

void main() => runApp(M());

class M extends StatelessWidget {
  @override
  Widget build(context) {
    return MaterialApp(
      home: SplashScreen(
        seconds: 2,
        backgroundColor: Color.fromRGBO(255, 204, 102, 1),
        navigateAfterSeconds: H(),
        title: Text(
          '{ spectacle } ',
          style: TextStyle(
            fontSize: 48.0,
            fontFamily: 'AbrilFatface',
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        loadingText: Text(
          'discover excellence',
          style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18.0,
              fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class H extends StatefulWidget {
  @override
  _H createState() => _H();
}

class _H extends State<H> {
  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 204, 102, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 204, 102, 1),
      ),
      body: Center(
        child: Text('This is Text!'),
      ),
    );
  }
}

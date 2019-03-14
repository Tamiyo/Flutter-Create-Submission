import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:http/http.dart' as http;

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

var cg = Colors.green;

void main() => runApp(MaterialApp(
      home: S(),
      theme: ThemeData(
        primaryColor: cg,
        accentColor: cg,
      ),
    ));

class S extends HookWidget {
  @override
  Widget build(x) {

    startCountdown() async {
      return Timer(Duration(seconds: 3), () {
        Navigator.of(x).pushReplacement(MaterialPageRoute(builder: (x) {
          return H();
        }));
      });
    }

    startCountdown();
    return Scaffold(
      body: Stack(
        children: [
          FlareActor(
            'assets/s.flr',
            fit: BoxFit.contain,
            animation: 'fade',
          ),
        ],
      ),
    );
  }
}

var s = [];
var f = FlutterLocalNotificationsPlugin();
var b = FirebaseVision.instance.barcodeDetector();
var p;

void si() {
  p.setString('u', json.encode('{ \"items\": ' + s.toString() + "}"));
}

var tr = 'http://www.pngmart.com/files/5/Snow-PNG-Transparent-Image.png';

class H extends HookWidget {
  var _p;
  var ctx;
  var _r;
  var u;

  Future<String> _cA(var uE) async {
    var uA = "0";

    switch (uE[6]) {
      case "0":
      case "1":
      case "2":
        uA += uE[1] + uE[2] + uE[6] + '0000' + uE.substring(3, 6) + uE[7];
        break;
      case "3":
        uA += uE.substring(1, 4) + '00000' + uE.substring(4, 6) + uE[7];
        break;
      case "4":
        uA += uE.substring(1, 5) + '00000' + uE[5] + uE[7];
        break;
      case "5":
      case "6":
      case "7":
      case "8":
      case "9":
        uA += uE.substring(1, 6) + '0000' + uE[6] + uE[7];
    }

    return uA;
  }

  Future getImage() async {
    _p.state.show();

    var ba = await b.detectInImage(FirebaseVisionImage.fromFile(
            await ImagePicker.pickImage(source: ImageSource.camera))) ??
        [];

    u ??= ba[0].rawValue;

    _p.state.dismiss();

    if (u != null) {
      u = (u.length < 12) ? await _cA(u) : u;

      var r = await http.get(
          'https://api.upcitemdb.com/prod/trial/lookup?upc=' + u,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          });

      var d = json.decode(r.body);

      Navigator.of(ctx).push(MaterialPageRoute(builder: (x) => C(d: d)));
    } else {
      Scaffold.of(ctx).showSnackBar(SnackBar(
        content: Text('Failed barcode scan, try again!'),
      ));
    }
  }

  void _G() async {
    p = await SharedPreferences.getInstance();

    f.initialize(InitializationSettings(
        AndroidInitializationSettings('@mipmap/my_launcher'), null));

    for (var le in s) {
      var e = DateTime.parse(le['eD']);
      le['dl'] = e.difference(DateTime.now()).inDays;
      le['p'] = le['dl'] / e.difference(DateTime.parse(le['sD'])).inDays;
    }

    s.sort((a, b) => a['p'].compareTo(b['p']));

    _r.value = true;
  }

  @override
  Widget build(x) {
    ctx = useContext();
    _r = useState(false);
    _p = useState(ProgressHUD(
      loading: false,
    ));
    u = useState('');

    _G();

    return Scaffold(
        appBar: AppBar(
          title: Text('My Pantry'),
          centerTitle: true,
        ),
        body: Builder(builder: (x) {
          ctx = x;
          return _r.value
              ? Stack(
                  children: [
                    ListView.separated(
                      itemCount: s.length,
                      padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
                      itemBuilder: (x, i) {
                        var e = s[i];
                        return ListTile(
                          title: Text(e['n'], maxLines: 2),
                          trailing: IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () async {
                                await f.cancel(e['n'].hashCode);
                                s.removeAt(i);
                                Navigator.pop(x);
                              }),
                        );
                      },
                      separatorBuilder: (x, i) => Divider(
                            color: Colors.transparent,
                          ),
                    ),
                    _p.value,
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: getImage,
          child: Icon(Icons.add_a_photo),
        ));
  }
}

class C extends HookWidget {
  C({this.d});

  var d;
  var n;
  var image;
  var eD;

  @override
  Widget build(x) {
    image = Image.network(d['images'].isEmpty ? tr : d['images'][0]);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF454851)),
      ),
      body: Stack(
        children: <Widget>[
          FlareActor(
            'assets/w.flr',
            alignment: Alignment.center,
            fit: BoxFit.cover,
            animation: 'tick',
          ),
          Center(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    DateTimePickerFormField(
                      inputType: InputType.date,
                      format: DateFormat('yyyy-MM-dd'),
                      editable: false,
                      decoration: InputDecoration(
                        labelText: 'Expiration Date',
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      onChanged: (D) {
                        eD = D;
                      },
                    ),
                    MaterialButton(
                      child: Text('Submit'),
                      onPressed: () async {
                        var dt = DateTime.now();
                        var ti = d['title'];
                        int fr = eD.difference(dt).inDays;

                        s.add({
                          'fr': fr > 0 ? fr.toString() : 1,
                          'n': ti,
                          'iU': d['images'].length > 0 ? d['images'][0] : tr,
                          'sD': dt,
                          'eD': eD
                        });
                        si();
                        await f.schedule(
                            ti.hashCode,
                            'Spoil Alert!',
                            '$ti is going to spoil soon!',
                            dt.add(Duration(days: fr)),
                            NotificationDetails(
                                AndroidNotificationDetails(
                                    'epn', 'Push Notifications', '',
                                    priority: Priority.High,
                                    channelAction:
                                        AndroidNotificationChannelAction
                                            .CreateIfNotExists),
                                null));
                        Navigator.of(x).pop();
                      },
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

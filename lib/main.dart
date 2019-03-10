import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

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
  List<String> savedItems = [
    '4',
    'Rosmary Spices',
    'https://cdn.shopify.com/s/files/1/1225/3182/products/rosemary-tea-top-close.jpg?v=1504589423',
    '2134001239012',
  ];

  final BarcodeDetector barcodeDetector =
      FirebaseVision.instance.barcodeDetector();

  @override
  _H createState() => _H();
}

class _H extends State<H> {
  bool _ready = false;

  Future getImage() async {
    final File image = await ImagePicker.pickImage(source: ImageSource.camera);

    showDialog(
        context: this.context,
        builder: (BuildContext context) {
          return D(
            image: image,
            barcodeDetector: widget.barcodeDetector,
            savedItems: widget.savedItems,
          );
        });
  }

  void _G() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
//    widget.savedItems = preferences.getStringList('user-data');

    setState(() {
      _ready = true;
    });
  }

  @override
  void initState() {
    _G();
    super.initState();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Color.fromRGBO(255, 204, 102, 1),
      body: Center(
        child: ListView.separated(
          itemCount: (widget.savedItems.length / 4).floor(),
          padding: EdgeInsets.all(8.0),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: Image.network(
                    widget.savedItems[4 * index + 2],
                  ).image,
                ),
                title: Text(widget.savedItems[4 * index + 1]),
                subtitle: Text(widget.savedItems[4 * index] + ' days left!'),
                onTap: () {
                  /// TODO Implement onTap -> DetailsPage
//                    savedItems[4 * index + 2]
                },
                trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      widget.savedItems.removeRange(index, index + 3);
                      setState(() {});
                    }),
              ),
              color: Colors.white,
            );
          },
          separatorBuilder: (BuildContext context, int index) => Divider(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: getImage,
        icon: Icon(Icons.camera),
        label: Text('Scan Barcode'),
      ),
    );
  }
}

class D extends StatefulWidget {
  D({this.image, this.barcodeDetector, this.savedItems});

  List<String> savedItems;
  File image;
  BarcodeDetector barcodeDetector;

  @override
  _D createState() => _D(image: image, barcodeDetector: barcodeDetector);
}

class _D extends State<D> {
  _D({this.image, this.barcodeDetector});

  File image;
  BarcodeDetector barcodeDetector;

  bool _ready = false;
  bool _detected = true;

  void _g() async {
    final List<Barcode> barcodes = await barcodeDetector
        .detectInImage(FirebaseVisionImage.fromFile(image));

    if (barcodes.length < 1) {
      _detected = false;
    } else {
      print(barcodes[0].rawValue);
    }

    if (_detected) {
      Navigator.push(context,
          new MaterialPageRoute(builder: (BuildContext context) {
        return C(
          upc: barcodes[0].rawValue,
          savedItems: widget.savedItems,
        );
      }));
    }

    setState(() {
      _ready = true;
    });
  }

  @override
  void initState() {
    _g();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _ready
          ? (_detected
              ? Text(
                  'Image Loaded!',
                  textAlign: TextAlign.center,
                )
              : Text(
                  'Image Failed To Load!\nTry Again!',
                  textAlign: TextAlign.center,
                ))
          : Text(
              'Processing...',
              textAlign: TextAlign.center,
            ),
      content: _ready ? null : LinearProgressIndicator(),
    );
  }
}

class C extends StatefulWidget {
  C({this.upc, this.savedItems});

  String upc;
  List<String> savedItems;

  _C createState() => new _C(upc: upc);
}

class _C extends State<C> {
  _C({this.upc});

  String upc;
  DateTime expirationDate;
  Map<String, dynamic> data;

  bool _ready = false;

  void _G() async {
    var response = await http.get(
        'https://api.upcitemdb.com/prod/trial/lookup?upc=' + upc,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        });

    print(response.body);
    data = json.decode(response.body);
    setState(() {
      _ready = true;
    });
  }

  @override
  void initState() {
    _G();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Color.fromRGBO(255, 255, 255, 1.0),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
                'Sam\'s Choice Himalayan Pink Salt: Great for seasoning meat and vegetable plates'),
            Divider(
              color: Colors.transparent,
            ),
            Image.network(
              'https://i5.walmartimages.com/asr/489aab95-19e0-483b-bc6e-61ba2198be13_2.fe847f38d8f37ecd320145b8fba64dd4.jpeg?odnHeight=450&odnWidth=450&odnBg=ffffff',
              fit: BoxFit.cover,
              scale: 1.5,
            ),
            Divider(
              color: Colors.transparent,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Average Price: \$3.98'),
                Text('UPC: 0078742245867')
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: DateTimePickerFormField(
                    inputType: InputType.date,
                    onChanged: (d) {
                      expirationDate = d;
                    },
                    format: DateFormat('yyyy-MM-dd'),
                    editable: false,
                    decoration: InputDecoration(
                      labelText: 'Expiration Date',
                      counterText: 'Expiration Date',
                      hasFloatingPlaceholder: false,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: MaterialButton(
                    onPressed: () {
                      /// TODO Note the way this is setup
                      /// 1. Days Left TODO Parse this value
                      /// 2. Name
                      /// 3. ImageURL

                      widget.savedItems
                        ..add(expirationDate
                            .difference(DateTime.now())
                            .inDays
                            .toString())
                        ..add(data['items'][0]['title'])
                        ..add(data['items'][0]['images'][0])
                        ..add(upc);

                      Navigator.of(context).pop();
                    },
                    child: Text('Submit'),
                    color: Colors.amber,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

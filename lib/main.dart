import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;

var aR = Color(0xFFbd3d3d);
var _w = Colors.white;
var _tC;
var _m = MainAxisAlignment.spaceBetween;

_e(c) => EdgeInsets.all(c);

main() => runApp(MaterialApp(
      theme: ThemeData(
          primaryColor: aR,
          textTheme: TextTheme(
              title: TextStyle(fontFamily: 'Teko', fontSize: 28, color: _w),
              subtitle: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                color: _w,
              ))),
      home: S(),
    ));

class S extends StatefulWidget {
  _S createState() => _S();
}

class _S extends State with SingleTickerProviderStateMixin {
  _gA() async {
    final r = await http.get(
        'https://www.gamespot.com/api/articles/?api_key=247c3e174dbfcc32ba1251b9b45fdf4af37cd7c8&filter=title%3Aapex%20legends&format=json');
    Future.delayed(Duration(seconds: 2)).then((_) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => Scaffold(
                appBar: AppBar(
                  backgroundColor: aR,
                  title: Text(
                    'Apex Legends Companion',
                  ),
                  bottom: TabBar(
                    indicatorColor: _w,
                    tabs: [
                      Tab(
                        text: 'Find Players',
                      ),
                      Tab(
                        text: 'Browse Articles',
                      )
                    ],
                    controller: _tC,
                  ),
                ),
                body: H(gA: json.decode(r.body)['results']),
              )));
    });
  }

  initState() {
    _tC = TabController(length: 2, vsync: this);
    _gA();
    super.initState();
  }

  build(c) => Scaffold(
          body: Stack(
        children: [
          Image.asset(
            'assets/s.png',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ],
      ));
}

class H extends StatefulWidget {
  H({this.gA});

  final gA;

  _H createState() => _H(gA: gA);
}

class _H extends State {
  _H({this.gA});

  final _c = TextEditingController();
  final gA;
  ProgressHUD _pH;
  int pf = 5;

  _gP(pN, pf, c) async {
    FocusScope.of(c).requestFocus(FocusNode());
    final r = await http.get(
        'https://public-api.tracker.gg/apex/v1/standard/profile/5/$pN',
        headers: {
          'TRN-Api-Key': '3ac4362a-8357-4855-89aa-c3c7444382ca'
        }).timeout(Duration(seconds: 10));
    final b = json.decode(r.body);
    if (b.keys.contains('errors') || b['data']['children'].length == 0) {
      Scaffold.of(c).showSnackBar(SnackBar(
        content: Text('Couldn\'t Find Stats for $pN on PC'),
      ));
    } else {
      Navigator.of(c).push(MaterialPageRoute(
          builder: (_) => P(
                j: b,
              )));
    }
  }

  initState() {
    _pH = ProgressHUD(
      color: _w,
      loading: false,
      containerColor: aR,
      borderRadius: 5.0,
      text: 'Loading...',
    );
    super.initState();
  }

  build(c) => Stack(
        children: [
          Container(
            padding: _e(8.0),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/b.png'), fit: BoxFit.cover)),
            child: TabBarView(
              children: [
                Center(
                  child: Container(
                    color: _w,
                    child: TextField(
                      controller: _c,
                      decoration: InputDecoration(
                        suffixIcon: MaterialButton(
                          onPressed: () async {
                            setState(() => _pH.state.show());
                            await _gP(_c.text, pf, c);
                            setState(() => _pH.state.dismiss());
                          },
                          color: Color(0xFFed6929),
                          child: Text(
                            'Search',
                            style: TextStyle(color: _w),
                          ),
                        ),
                        contentPadding: EdgeInsets.only(left: 16.0, top: 16.0),
                        hintText: 'Player Name',
                      ),
                    ),
                  ),
                ),
                G(
                  gA: gA,
                )
              ],
              controller: _tC,
            ),
          ),
          _pH
        ],
      );
}

class P extends StatelessWidget {
  P({this.j});

  final j;

  build(c) {
    var ch = {};
    for (var h in j['data']['children']) {
      if (h['metadata']['legend_name'] != 'Unknown') {
        ch = h['metadata'];
        break;
      }
    }
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Image.asset(
            'assets/b.png',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    FadeInImage.assetNetwork(
                      placeholder: 'assets/lpb.png',
                      image: ch['bgimage'],
                    ),
                    Center(
                      child: Transform(
                        transform: Matrix4.translationValues(0.0, 30.0, 0.0),
                        child: Column(
                          children: [
                            FadeInImage.assetNetwork(
                              placeholder: 'assets/lpp.png',
                              image: ch['icon'],
                              imageScale: 3.0,
                              placeholderScale: 3.0,
                            ),
                            Text(
                              j['data']['metadata']['platformUserHandle'],
                              style: TextStyle(fontSize: 48.0),
                            ),
                            Text(
                              '${ch['legend_name']} Main',
                              style: TextStyle(fontSize: 18.0),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.transparent,
                  height: 48.0,
                ),
                Column(
                    children: j['data']['stats']
                        .map<Widget>(
                          (d) => Container(
                                padding: _e(16.0),
                                child: Row(
                                  mainAxisAlignment: _m,
                                  children: [
                                    Text(
                                      '${d['metadata']['name']}:',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      d['displayValue'],
                                      style: TextStyle(
                                        fontSize: 20.0,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                        )
                        .toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class G extends StatelessWidget {
  G({this.gA});

  final gA;

  build(c) {
    var l = gA.length;
    return Container(
        child: StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: l,
      itemBuilder: (c, i) => Card(
            child: Stack(
              children: [
                Positioned.fill(
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/l.png',
                    image: gA[l - 1 - i]['image']['original'],
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                    child: Container(
                  padding: _e(16.0),
                  child: InkWell(
                    onTap: () async {
                      final u = gA[l - 1 - i]['site_detail_url'];
                      if (await canLaunch(u)) {
                        await launch(u);
                      } else {
                        Scaffold.of(c).showSnackBar(SnackBar(
                            content: Text(
                                'Could not open article, try again later!')));
                      }
                    },
                    child: Column(
                      mainAxisAlignment: _m,
                      children: [
                        Text(
                          gA[l - 1 - i]['title'],
                          style: Theme.of(c).textTheme.title,
                        ),
                        Row(
                          mainAxisAlignment: _m,
                          children: [
                            Text(
                              gA[l - 1 - i]['publish_date'],
                              style: Theme.of(c).textTheme.subtitle,
                            ),
                            Icon(
                              Icons.open_in_new,
                              color: _w,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                  ),
                ))
              ],
            ),
          ),
      staggeredTileBuilder: (_) => StaggeredTile.count(4, 2),
    ));
  }
}

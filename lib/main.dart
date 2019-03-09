import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(M());

class M extends StatelessWidget {
  @override
  Widget build(context) {
    var tc = Color.fromRGBO(50, 48, 49, 1.0);
    var ff1 = 'AbrilFatface';

    var sbts = TextStyle(fontSize: 16.0, fontFamily: 'OpenSans', color: tc);

    return MaterialApp(
      theme: new ThemeData(
          backgroundColor: Color.fromRGBO(255, 204, 102, 1),
          textTheme: TextTheme(
            headline: TextStyle(
              fontSize: 64.0,
              letterSpacing: 1.5,
              fontFamily: ff1,
              color: tc,
            ),
            title: TextStyle(fontSize: 20.0, fontFamily: 'NotoSans', color: tc),
            subtitle: sbts,
            body1: sbts,
          )),
      home: H(),
    );
  }
}

class H extends StatefulWidget {
  @override
  _H createState() => _H();
}

class _H extends State<H> {
  var _m;
  bool _r = false;

  Map<String, dynamic> dummyData = {
    'source': {'name': 'Fox News'},
    'author': 'Anna Hopkins',
    'title':
        'Flu season has peaked, but nasty strain is on rise: report - Fox News',
    'description':
        'CDC officials are warning that flu season is declining, but a stronger strain of the virus is on the rise.',
    'url':
        'https://www.foxnews.com/health/flu-season-has-peaked-but-nasty-strain-is-on-rise-report',
    'urlToImage':
        'https://static.foxnews.com/foxnews.com/content/uploads/2019/03/AP19059694883455.jpg',
    'publishedAt': '2019-03-08T21:43:44Z',
    'content':
        'Flu season may be nearing its end, but health officials are warning of recent wave of a stronger strain of the virus that is more likely to cause hospitalizations and deaths. The Centers for Disease Control and Prevention (CDC) said on Friday that widespread … '
  };

  @override
  void initState() {
    _f();
    super.initState();
  }

  void _f() async {
    var r = await http.get(
        'https://newsapi.org/v2/top-headlines?apiKey=d66af0d32651408f9b6ae8b2158d533e&country=us');
    _m = json.decode(r.body)['articles'];
    _r = true;
    setState(() {});
  }

  Widget _sP() {
    return _r
        ? ListView.separated(
            padding: EdgeInsets.all(8.0),
            itemBuilder: (x, i) => Center(
                    child: Container(
                  child: Container(
                    child: ListTile(
                      onTap: () => Navigator.push(
                          x,
                          MaterialPageRoute(
                              builder: (x) => _buildDetailsPage(_m[i], x))),
                      leading: CircleAvatar(
                        backgroundImage: Image.network(
                                'http://logo.clearbit.com/' +
                                    (_m[i]['source']['name'].contains('.')
                                        ? _m[i]['source']['name'].replaceAll(' ', '')
                                        : _m[i]['source']['name'].replaceAll(' ', '') + '.com'))
                            .image,
                      ),
                      title: Text(
                        _m[i]['title'],
                        maxLines: 2,
                      ),
                      subtitle: Text(
                        _m[i]['publishedAt']
                            .substring(0, _m[i]['publishedAt'].indexOf('T')),
                      ),
                    ),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      colors: [Colors.white , Colors.transparent],
                      begin: Alignment(0.5, -2.0),
                      end: Alignment(1.0, 1.0),
                    )),
                  ),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: Image.network(
                              _m[i]['urlToImage'])
                              .image,
                          fit: BoxFit.cover)),
                )),
            separatorBuilder: (ctx, i) => Divider(),
            itemCount: 4)
        : _buildSplashPage();
  }

  Widget _buildDetailsPage(m, ctx) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AspectRatio(
                aspectRatio: MediaQuery.of(ctx).size.height /
                    MediaQuery.of(ctx).size.width,
                child: Image.network(
                  m['urlToImage'],
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      m['title'],
                      style: TextStyle(fontSize: 28.0),
                    ),
                    Divider(
                      color: Colors.transparent,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text((m['author'] != null && m['author'] != "") ? (m['author'] + ', ' + m['source']['name']) : ''),
                        Text(m['publishedAt'].toString().substring(
                            0, m['publishedAt'].toString().indexOf('T')))
                      ],
                    ),
                    Divider(
                      color: Colors.transparent,
                    ),
                    Text(m['content'])
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplashPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text("{ spectacle }",
            style: TextStyle(
                fontFamily: "AbrilFatface",
                fontSize: 64.0,
                letterSpacing: 1.5)),
        Text("discover excellence",
            style: TextStyle(
                fontFamily: "OpenSans",
                fontSize: 24.0,
                fontStyle: FontStyle.italic))
      ],
    );
  }

  Widget _buildTestWidget() {
    return ListView.separated(
        padding: EdgeInsets.all(8.0),
        itemBuilder: (ctx, i) => Center(
                child: Container(
              child: Container(
                child: ListTile(
                  onTap: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                          builder: (ctx) => _buildDetailsPage(dummyData, ctx))),
                  leading: CircleAvatar(
                    backgroundImage:
                        Image.network('http://logo.clearbit.com/BBCNews.com')
                            .image,
                  ),
                  title: Text(
                    'US women\'s national team take legal action over discrimination',
                    maxLines: 2,
                  ),
                  subtitle: Text(
                    '2019-03-08T21:46:00Z'
                        .substring(0, '2019-03-08T21:46:00Z'.indexOf('T')),
                  ),
                ),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [Colors.white, Colors.transparent],
                  begin: Alignment(0.5, -2.0),
                  end: Alignment(1.0, 2.0),
                )),
              ),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: Image.network(
                              'https://ichef.bbci.co.uk/onesport/cps/624/cpsprodpb/F109/production/_105950716_gettyimages-1060172164.jpg')
                          .image,
                      fit: BoxFit.cover)),
            )),
        separatorBuilder: (ctx, i) => Divider(),
        itemCount: 3);
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 204, 102, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 204, 102, 1),
      ),
      body: _sP(),
    );
  }
}

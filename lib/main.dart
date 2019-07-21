import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:typed_data';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ui.Image image;
  bool isImageloaded = false;
  double _x;
  double _y;
  double _len = 0;

  void initState() {
    super.initState();
    init();
  }

  Future <Null> init() async {
    final ByteData data = await rootBundle.load('images/gB1aKmm4.jpg');
    image = await loadImage(new Uint8List.view(data.buffer));
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  Widget _buildImage() {
    if (this.isImageloaded) {
      return new CustomPaint(
        painter: new ImageEditor(image: image, scrollLen: _len, offset: new Offset(_x, _y)),
        size: new Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height)
      );
    } else {
      return new Center(child: new Text('loading'));
    }
  }

  @override
  Widget build(BuildContext context) {

    //child: _buildImage(),

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Card(
          child: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (detail) {
                _x = detail.globalPosition.dx;
                _y = detail.globalPosition.dy;
              },
              onVerticalDragStart: (detail) {
                _x = detail.globalPosition.dx;
                _y = detail.globalPosition.dy;
              },
              onHorizontalDragUpdate: (detail) {
                setState(() {
                _len -= detail.globalPosition.dx - _x;
                _x = detail.globalPosition.dx;
                _y = detail.globalPosition.dy;
                });
              },
              onVerticalDragUpdate: (detail) {
                setState(() {
                _len += detail.globalPosition.dy - _y;
                _x = detail.globalPosition.dx;
                _y = detail.globalPosition.dy;
                });
              },
              child: _buildImage(),
            ),
      ))
    );
  }
}

class ImageEditor extends CustomPainter {

  ImageEditor({
    this.image,
    this.scrollLen,
    this.offset
  });

  ui.Image image;
  final double scrollLen;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    //ByteData data = image.toByteData() as ByteData;
    canvas.drawImage(image, new Offset(offset.dx, offset.dy), new Paint());


    final p1 = Offset(50, 50);
    final p2 = Offset(250, 150);
    final paint = Paint()
      ..color = Colors.yellow
      ..isAntiAlias = true
      ..strokeWidth = 2;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(ImageEditor oldDelegate) => oldDelegate.scrollLen != scrollLen;

}


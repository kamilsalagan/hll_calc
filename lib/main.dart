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
      theme: ThemeData.dark(),
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

int _img_height = 0;
int _img_width = 0;

class _MyHomePageState extends State<MyHomePage> {
  ui.Image image;
  bool isImageloaded = false;
  Offset _startingFocalPoint;

  Offset _previousOffset;
  Offset _offset = Offset.zero;

  double _previousZoom;
  double _zoom = 1.0;

  double _drawX = 0;
  double _drawY = 0;

  void initState() {
    super.initState();
    init();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    setState(() {
      _startingFocalPoint = details.focalPoint;
      _previousOffset = _offset;
      _previousZoom = _zoom;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _zoom = _previousZoom * details.scale;
      // Ensure that item under the focal point stays in the same place despite zooming
      final Offset normalizedOffset = (_startingFocalPoint - _previousOffset) / _previousZoom;
      _offset = details.focalPoint - normalizedOffset * _zoom;
    });
  }

  void _handleScaleReset() {
    setState(() {
      _zoom = 1.0;
      _offset = Offset.zero;
    });
  }

  void _handleTap(TapUpDetails details) {
    setState(() {
      _drawX = details.globalPosition.dx;
      _drawY = details.globalPosition.dy;
    });
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
        _img_height = img.height;
        _img_width = img.width;
        print('Img W: ' + _img_width.toString() + ' Img H: ' + _img_height.toString());
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  Widget _buildImage() {
    if (this.isImageloaded) {
      return new SizedBox(
        width: _img_width.toDouble(),
        height: _img_height.toDouble(),
        child: new GestureDetector(
          behavior: HitTestBehavior.translucent,
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
          onDoubleTap: _handleScaleReset,
          onTapUp: _handleTap,
          child: new CustomPaint(
            painter: new ImageEditor(image: image, scrollLen: _zoom, offset: _offset, drawX: _drawX, drawY: _drawY),
            size: new Size(_img_width.toDouble(), _img_height.toDouble()),
          ),
        ),
      );
    } else {
      return new Center(child: new Text('loading'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      width: _img_width.toDouble(),
      height: _img_height.toDouble(),
      child: _buildImage(),
    );
  }
}

class ImageEditor extends CustomPainter {
  static const comp = - (3.14) / 2;
  ImageEditor({
    this.image,
    this.scrollLen,
    this.offset,
    this.drawX,
    this.drawY
  });

  ui.Image image;
  final double scrollLen;
  final Offset offset;
  final double drawX;
  final double drawY;



  @override
  void paint(Canvas canvas, Size size) {

    //size = Size(_img_width.toDouble(), _img_height.toDouble());

    Paint paint = new Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = 2.0;

    canvas.drawRect(offset & Size(_img_width.toDouble(), _img_height.toDouble()), paint);


    double fscale = scrollLen;
    if (fscale < 0.2)
      fscale = 0.2;

    Offset center = size.center(Offset.zero) * scrollLen + offset;
    double radius = _img_width / _img_height * scrollLen;


//    double estHeight = _img_height * radius;

//    if (center.dx > 0) //Stick map to left edge
//      center = new Offset(0, center.dy);

//    if (center.dy < 0) //Stick map to top edge if pushing beyond
//      center = new Offset(center.dx, 0);

 //   if (center.dy + estHeight > size.height) //Y + Map height not to exceed screen limits -- Currently not working
 //     center = new Offset(center.dx, center.dy+estHeight);
 //   double sR = drawX/drawY * scrollLen;
    double sX = (drawX);
    double sY = (drawY);


    print('X: ' + drawX.toString() + ' Y: ' + drawY.toString() + ' sX: ' + sX.toString() + ' sY: ' + sY.toString() + ' dx: ' + center.dx.toString() + ' dy: ' + center.dy.toString());
    print('Center: ' + center.toString() + ' Radius: ' + radius.toString() + ' ScrollLen: ' + scrollLen.toString() + ' offset: ' + offset.toString());
    print('Size X: ' + size.width.toString() + ' Size Y: ' + size.height.toString());



   // canvas.translate(center.dx, center.dy);
    //canvas.scale(scrollLen);


    canvas.drawImage(image, offset, paint);

    if (drawX != 0 && drawY != 0) {
      final p1 = new Offset(70 + offset.dx, 300 + offset.dy);
      final p2 = new Offset(sX, sY);
      canvas.drawLine(p1, p2, paint);
    }







    }

  @override
  bool shouldRepaint(ImageEditor oldDelegate) {

   return oldDelegate.scrollLen != scrollLen
     || oldDelegate.offset != offset
    || oldDelegate.drawX != drawX
   || oldDelegate.drawY != drawY;
  }

}


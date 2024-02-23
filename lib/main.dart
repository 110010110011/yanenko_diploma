import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

int nmbrpxls = 50;
var alphaList = <int>[];
var redList = <int>[];
var greenList = <int>[];
var blueList = <int>[];
void main() => runApp(const SPMapp());

class SPMapp extends StatelessWidget {
  const SPMapp({super.key});

  static const String _title = 'Virtual Scanning Probe Microscope';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: _title,
          home: Scaffold(
          appBar: AppBar(title: const Text(_title)),
          body: MyStatefulWidget(), //duration: Duration(seconds: tscan)),
        ));
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key}); //, required this.duration});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class FirstDisabledFocusNode extends FocusNode {
  @override
  bool consumeKeyboardToken() {
    return false;
  }
}

class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with SingleTickerProviderStateMixin {
  int tscan = 10;
  late AnimationController _controller;
  late Uint8List imageData; //

  @override
  void initState() {
    int imgpxl = nmbrpxls * nmbrpxls;
    List<int> imagedata = List.filled(imgpxl, 0);
    //final random = Random();
    for (int i = 0; i < imgpxl; i++) {
      imagedata[i] = 100;
      /* alphaList.add(random.nextInt(255));
      redList.add(random.nextInt(255));
      greenList.add(random.nextInt(255));
      blueList.add(random.nextInt(255)); */
    }
    imageData = Uint8List.fromList(imagedata);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
          seconds: tscan), //widget.duration, //Duration(seconds: tscan),
    ); //..repeat(reverse: false);
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    /*  int imgpxl = nmbrpxls * nmbrpxls;
    for (int i = 0; i < imgpxl; i++) {
      alphaList.removeLast();
      redList.removeLast();
      greenList.removeLast();
      blueList.removeLast();
    }  */
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AspectRatio(
          aspectRatio: 1,
          child: Stack(alignment: Alignment.topLeft, children: <Widget>[
            //Image.memory(imageData),
            //Image.asset('images/STMimage.jpg'),
            // CustomPaint(
            //     size: MediaQuery.of(context).size,
            //     painter: ImagePainter(nmbrpxl: nmbrpxls)),
            CustomPaint(
                size: MediaQuery.of(context).size,
                painter:
                CurtainPainter(value: _controller.value, nmbrpxl: nmbrpxls))
          ])),
      Row(
        children: [
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _controller.forward();
              },
              child: const Text('Start'),
            ),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () => _controller.stop(),
              child: const Text('Stop'),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
              child: TextField(
                  focusNode: FirstDisabledFocusNode(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Time per pixel, ms" + tscan.toString()),
                  textAlign: TextAlign.center,
                  onSubmitted: (String string) {
                    tscan = int.tryParse(string)!;
                    _controller.duration = Duration(seconds: tscan);
                  })),
          Expanded(
              child: TextField(
                  focusNode: FirstDisabledFocusNode(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Size in Pixels"),
                  textAlign: TextAlign.center,
                  onSubmitted: (String string) {
                    setState(() {
                      int imgpxl = nmbrpxls * nmbrpxls;
                      for (int i = 0; i < imgpxl; i++) {
                        alphaList.removeLast();
                        redList.removeLast();
                        greenList.removeLast();
                        blueList.removeLast();
                      }
                      nmbrpxls = int.tryParse(string)!;
                      imgpxl = nmbrpxls * nmbrpxls;
                      final random = Random();
                      for (int i = 0; i < imgpxl; i++) {
                        alphaList.add(random.nextInt(255));
                        redList.add(random.nextInt(255));
                        greenList.add(random.nextInt(255));
                        blueList.add(random.nextInt(255));
                      }
                    });
                  })),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Feedback"),
              value: "-1",
              items: [
                DropdownMenuItem(child: TextField(
                  focusNode: FirstDisabledFocusNode(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Feedback Proportional"
                  ),
                  textAlign: TextAlign.center,
                  onSubmitted: (String string) {
                    tscan = int.tryParse(string)!;
                  },
                ), value: "-1",),

                DropdownMenuItem(child: TextField(
                    focusNode: FirstDisabledFocusNode(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Feedback Differential"
                  ),
                  textAlign: TextAlign.center,
                    onSubmitted: (String string) {
                      // nmbrpxl = int.tryParse(string)!;
                    }
                ), value: "1",),

                DropdownMenuItem(child: TextField(
                    focusNode: FirstDisabledFocusNode(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Feedback Integral"
                  ),
                  textAlign: TextAlign.center,
                    onSubmitted: (String string) {
                      //tscan = int.tryParse(string)!;
                    }
                ), value: "2",),
              ],

              onChanged: (v){},
            ),
            // TextField(
            //     keyboardType: TextInputType.number,
            //     decoration: InputDecoration(
            //         border: OutlineInputBorder(),
            //         labelText: "Feedback Proportional"),
            //     textAlign: TextAlign.center,
            //     onSubmitted: (String string) {
            //       //  tscan = int.tryParse(string)!;
            //     })
          ),
          Expanded(
              child: TextField(
                  focusNode: FirstDisabledFocusNode(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: "Size in nm"),
                  textAlign: TextAlign.center,
                  onSubmitted: (String string) {
                    // nmbrpxl = int.tryParse(string)!;
                  })),
        ],
      ),

      Row(
        children: [
          Expanded(
              child: TextField(
                  focusNode: FirstDisabledFocusNode(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Sample Bias, V"),
                  textAlign: TextAlign.center,
                  onSubmitted: (String string) {
                    //tscan = int.tryParse(string)!;
                  })),
          Expanded(
              child: TextField(
                  focusNode: FirstDisabledFocusNode(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Tunneling Current, nA"),
                  textAlign: TextAlign.center,
                  onSubmitted: (String string) {
//                    nmbrpxl = int.tryParse(string)!;
                  })),
        ],
      ),
      Row(
        children: [
          Expanded(
              child: TextField(
                  focusNode: FirstDisabledFocusNode(),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: "Sample Name"),
                  textAlign: TextAlign.center,
                  onSubmitted: (String string) {})),
          Expanded(
              child: TextField(
                  focusNode: FirstDisabledFocusNode(),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: "Tip Name"),
                  textAlign: TextAlign.center,
                  onSubmitted: (String string) {})),
        ],
      )

    ]);
  }
}

class CurtainPainter extends CustomPainter {
  final double value;
  final int nmbrpxl;
  CurtainPainter({required this.value, required this.nmbrpxl}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.indigoAccent.shade100;
    canvas.drawRect(
        Offset(0, 0) &
        Size(size.width,
            (size.height / nmbrpxl) * ((1 - value) * nmbrpxl).truncate()),
        paint);
    canvas.drawRect(
        Offset(0,
            (size.height / nmbrpxl) * ((1 - value) * nmbrpxl).truncate()) &
        Size(
            size.width *
                (((1 - value) * nmbrpxl) -
                    ((1 - value) * nmbrpxl).truncate()),
            size.height / nmbrpxl),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ImagePainter extends CustomPainter {
  final int nmbrpxl;
  ImagePainter({required this.nmbrpxl}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    // final random = Random();
    var pixelcolor = Paint()..color = Colors.green;
    int k = 0;
    for (int i = 0; i < nmbrpxl; i++) {
      for (int j = 0; j < nmbrpxl; j++) {
        pixelcolor.color = pixelcolor.color
            .withAlpha(alphaList[k])
            .withBlue(blueList[k])
            .withGreen(greenList[k])
            .withRed(redList[k]);
        k++;
        canvas.drawRect(
            Offset(size.width / nmbrpxl * j, size.height / nmbrpxl * i) &
            Size(size.width / nmbrpxl, size.height / nmbrpxl),
            pixelcolor);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

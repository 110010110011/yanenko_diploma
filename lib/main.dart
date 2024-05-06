import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'microscopeTransmission.dart';
import 'parametersActions.dart';
import 'dart:developer' as developer;

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
          body: const MyStatefulWidget(), //duration: Duration(seconds: tscan)),
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
  String? dropdownSelectedValue = "0";
  String? sampleName;
  String? tipName;
  bool isScaning = false;


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
    final gamma = AssetImage('images/gamma.png');
    MicroscopeParams microscopeParams = MicroscopeParams();
    return Column(children: [
      Row(
        children: [
          Expanded(
            child: Image(image: gamma,)
          ),
        ],
      ),

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
            child: ElevatedButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                sendPOST(microscopeParams);
                _controller.forward();
                isScaning = true;
                null;
              },
              child: Text('Start'),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: isScaning ? Text('Pause') : Text('Resume'),
              onPressed: (){
                if(isScaning){
                  _controller.stop();
                }else{
                  _controller.forward();
                }
                setState(() {
                  isScaning = !isScaning;
                });
              },
            ),
          ),
        ],
      ),

      Row(
        children: [
          Expanded(
              child: DropdownButtonFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "All parmeters"),
                value: "0",
                items: [
                  DropdownMenuItem(
                    value: "0",
                    child:
                    Text("Time per pixel, ms"+ 10.toString()),),
                  const DropdownMenuItem(
                    value: "1",
                    child:
                    Text("Feedback Proportional"),),
                  const DropdownMenuItem(
                    value: "2",
                    child:
                    Text("Feedback Integral"),),
                  const DropdownMenuItem(
                    value: "3",
                    child:
                    Text("Feedback Differential"),),
                  const DropdownMenuItem(
                    value: "4",
                    child:
                    Text("Size in Pixels"),),
                  const DropdownMenuItem(
                    value: "5",
                    child:
                    Text("Size in nm"),),
                  const DropdownMenuItem(
                    value: "6",
                    child:
                    Text("Sample Bias, V"),),
                  const DropdownMenuItem(
                    value: "7",
                    child:
                    Text("Tunneling Current, nA"),),
                  const DropdownMenuItem(
                    value: "8",
                    child:
                    Text("Sample Name"),),
                  const DropdownMenuItem(
                    value: "9",
                    child:
                    Text("Tip Name"),),
                ],
                onChanged: (v) {dropdownSelectedValue = v;},
              )
          )
        ],
      ),

      Row(
        children: [
          Expanded(
            child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Input your parameters"),
                textAlign: TextAlign.center,
                onSubmitted: (String input) {microscopeParams.setValue(input, dropdownSelectedValue);}
            ),
          ),
        ],
      ),

      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {

              },
              child: Text('Clean'),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () => _controller.stop(),

              child: Text('Save'),
            ),
          ),
        ],
      ),


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
        const Offset(0, 0) &
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

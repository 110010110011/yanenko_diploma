import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:my_app/saveImage.dart';
import 'microscopeTransmission.dart';
import 'saveImage.dart';
import 'parametersActions.dart';
import 'package:flutter/material.dart';

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
  MicroscopeParams microscopeParams = MicroscopeParams();
  SaveImages saveImg = SaveImages();
  late List<Color?> pixels;
  late int rowStartPoint;

  @override
  void initState(){
    super.initState();
    pixels = List.filled(pow(microscopeParams.sizeInPxl, 2).toInt(), Colors.grey[200]);
    rowStartPoint = pixels.length - sqrt(pixels.length).toInt() - index;
  }

  String? dropdownSelectedValue = "0";
  String? sampleName;
  String? tipName;

  bool isScanning = false;
  late List<Color?> loadedPixels;
  int index = 0;
  int counter = 0;
  late Timer timer;
  bool goRight = true;


  List<Color?> getColorListFromJson(Map<String, dynamic> json){
    List<Color?> colors = <Color>[];

    for (var row in json['pixels']){
      for (var pixel in row){
        colors.add(Color.fromARGB(255, pixel[0], pixel[1], pixel[2]));
      }
    }

    return colors;
  }

  Future<List<Color?>> loadPixelGrid() async {
    String jsonString = await rootBundle.loadString('images/pixels.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    loadedPixels = getColorListFromJson(jsonMap);
    return loadedPixels;
  }

  void drawPixelsRandomly() {

    setState(() {
      loadPixelGrid();
    });

    timer = Timer.periodic(Duration(milliseconds: microscopeParams.timePerPxl), (timer) {
      if (index < pixels.length) {
        setState(() {
          if (counter == sqrt(loadedPixels.length).toInt()){
            goRight = !goRight;
            counter = 0;
            if (goRight){
              rowStartPoint = loadedPixels.length - sqrt(loadedPixels.length).toInt() - index;
            }
            else{
              rowStartPoint = loadedPixels.length - index - 1;
            }
          }
          if (goRight){
            pixels[rowStartPoint + counter] = loadedPixels[index];
            counter++;
          }
          else{
            pixels[rowStartPoint - counter] = loadedPixels[index];
            counter++;
          }

          index++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void stopDrawing() {
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // final gamma = AssetImage('images/gamma.png');
    return Column(children: [
      Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Colors.indigo,
                Colors.blue,
                Colors.blue,
                Colors.yellow,
                Colors.yellow,
                Colors.yellow,
                Colors.yellow,
                Colors.white
              ],
            )
        ),
        width: MediaQuery.of(context).size.width,
        height: 50,
      ),

      Divider(color: Colors.black, height: 1, thickness: 3),

    RepaintBoundary(
    key: saveImg.globalKey,
      child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: microscopeParams.sizeInPxl,
          ),
          itemCount: pixels.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              width: 20,
              height: 20,
              color: pixels[index],
            );
          },
        ),
    ),

      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                //sendPOST(microscopeParams);
                drawPixelsRandomly();
                isScanning = true;
              },
              child: Text('Start'),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: isScanning ? Text('Pause') : Text('Resume'),
              onPressed: (){
                if(isScanning){
                  stopDrawing();
                }else{
                  drawPixelsRandomly();
                }
                setState(() {
                  isScanning = !isScanning;
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
                    Text("Time per pixel, ms"+ 500.toString()),),
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
                setState(() {
                  pixels = List.filled(100, Colors.grey[500]);
                  index = 0;
                  counter = 0;
                  // timer = microscopeParams.timePerPxl as Timer;
                  goRight = true;
                  rowStartPoint = pixels.length - sqrt(pixels.length).toInt() - index;
                });
              },
              child: Text('Clean'),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () => {saveImg.captureAndSave()},

              child: Text('Save'),
            ),
          ),
        ],
      ),


    ]);
  }
}


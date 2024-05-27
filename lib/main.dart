import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:my_app/saveImage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'parametersActions.dart';
import 'package:flutter/material.dart';

void main() => runApp(const SPMapp());

class SPMapp extends StatelessWidget {
  const SPMapp({super.key});


  static const String _title = 'Virtual Scanning Probe Microscope';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: _title, // The title of app, which appears in the app's title bar.
          home: Scaffold(
          appBar: AppBar(title: const Text(_title)),
          body: const MyStatefulWidget(), // The main content of the app, represented here by the MyStatefulWidget.
        ));
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key}); // Additional parameters can be added if needed

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}
// Define a custom FocusNode class named FirstDisabledFocusNode
class FirstDisabledFocusNode extends FocusNode {
  // Override the consumeKeyboardToken method to return false
  @override
  bool consumeKeyboardToken() {
    return false;
  }
}

class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with SingleTickerProviderStateMixin {
  MicroscopeParams microscopeParams = MicroscopeParams(); // Instance of MicroscopeParams class, likely containing parameters for the microscope
  SaveImages saveImg = SaveImages();  // Instance of SaveImages class, likely responsible for saving images
  late List<Color?> pixels; // List of colors representing pixels, declared as late to be initialized in initState
  late int rowStartPoint; // Starting point for the row, declared as late to be initialized in initState

  // WebSocket channel for communication, connecting to a local server
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://10.0.2.2:8080/ws'),
  );

  @override
  void initState(){
    super.initState();
    // Initialize pixels with a list filled with grey color, based on microscope parameters
    pixels = List.filled(pow(microscopeParams.sizeInPxl, 2).toInt(), Colors.grey[200]);
    rowStartPoint = pixels.length - sqrt(pixels.length).toInt() - index; // Calculate the starting point of the row based on the total number of pixels
  }

  // Variables for dropdown selection and names, with initial value for dropdown
  String? dropdownSelectedValue = "0";
  String? sampleName;
  String? tipName;

  // Boolean to track if scanning is in progress
  bool isScanning = false;
  // List of colors to represent loaded pixels, declared as late to be initialized later
  late List<Color?> loadedPixels;
  // Index and counter variables, initialized to zero
  int index = 0;
  int counter = 0;
  // Timer for managing scan timing, declared as late to be initialized later
  late Timer timer;
  // Boolean to track scan direction, initialized to true
  bool goRight = true;

// Method to convert a JSON map to a list of colors
  List<Color?> getColorListFromJson(Map<String, dynamic> json){
    List<Color?> colors = <Color>[];

    // Iterate through rows and pixels in the JSON to extract color information
    for (var row in json['pixels']){
      for (var pixel in row){
        colors.add(Color.fromARGB(255, pixel[0], pixel[1], pixel[2])); // Add color to the list by converting ARGB values from JSON
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

  Future<void> confirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // користувач має натиснути одну з кнопок
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Clean'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to clean params and image?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // закриває діалогове вікно
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                setState(() {
                  pixels = List.filled(100, Colors.grey[500]);
                  index = 0;
                  counter = 0;
                  goRight = true;
                  rowStartPoint = pixels.length - sqrt(pixels.length).toInt() - index;
                  microscopeParams.timePerPxl = 500;
                  microscopeParams.proportionalFeedback = 1;
                  microscopeParams.integralFeedback = 1;
                  microscopeParams.differentialFeedback = 1;
                  microscopeParams.sizeInPxl = 10;
                  microscopeParams.sizeInNm = 100;
                  microscopeParams.sampleBias = 100;
                  microscopeParams.tunnelingCurrent = 100;
                  microscopeParams.sampleName = "";
                  microscopeParams.tipName = ""; // Set params by default
                });
                Navigator.of(context).pop();
                // Додайте код для збереження даних тут
              },
            ),
          ],
        );
      },
    );
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
                // var a = jsonEncode(microscopeParams);
                //
                // channel.sink.add(a);
                // print('Data sent!');
                //
                // channel.stream.listen((message) {
                //   print(message);
                // });

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
                confirmationDialog(context);
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


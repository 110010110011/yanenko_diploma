void setValue(String input, String? dropdownSelectedValue){

  var tscan;
  var sampleName;
  var tipName;

  switch (dropdownSelectedValue){
    case "-1":
      break;
    case "0":
      tscan = int.tryParse(input)!;
      // _controller.duration = Duration(seconds: tscan);
      break;
    case "1":
      tscan = int.tryParse(input)!;
      break;
    case "2":
      tscan = int.tryParse(input)!;
      break;
    case "3":
    // nmbrpxl = int.tryParse(input)!;
      break;
    case "4":
      // setState(() {
      //   int imgpxl = nmbrpxls * nmbrpxls;
      //   for (int i = 0; i < imgpxl; i++) {
      //     alphaList.removeLast();
      //     redList.removeLast();
      //     greenList.removeLast();
      //     blueList.removeLast();
      //   }
      //   nmbrpxls = int.tryParse(input)!;
      //   imgpxl = nmbrpxls * nmbrpxls;
      //   final random = Random();
      //   for (int i = 0; i < imgpxl; i++) {
      //     alphaList.add(random.nextInt(255));
      //     redList.add(random.nextInt(255));
      //     greenList.add(random.nextInt(255));
      //     blueList.add(random.nextInt(255));
      //   }
      // });
      break;
    case "5":
    // nmbrpxl = int.tryParse(input)!;
      break;
    case "6":
      tscan = int.tryParse(input)!;
      break;
    case "7":
    // nmbrpxl = int.tryParse(input)!;
      break;
    case "8":
      sampleName = input;
      break;
    case "9":
      tipName = input;
      break;
  }
}
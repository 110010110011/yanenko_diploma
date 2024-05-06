class MicroscopeParams {
  late int timePerPxl;
  late int proportionalFeedback;
  late int integralFeedback;
  late int differentialFeedback;
  late int sizeInPxl;
  late int sizeInNm;
  late int sampleBias;
  late int tunnelingCurrent;
  late int sampleName;
  late int tipName;


  void setValue(String input, String? dropdownSelectedValue) {
    switch (dropdownSelectedValue) {
      case "-1":
        break;
      case "0":
        timePerPxl = int.tryParse(input)!;
        break;
      case "1":
        proportionalFeedback = int.tryParse(input)!;
        break;
      case "2":
        integralFeedback = int.tryParse(input)!;
        break;
      case "3":
        differentialFeedback = int.tryParse(input)!;
        break;
      case "4":
        sizeInPxl = int.tryParse(input)!;
        break;
      case "5":
        sizeInNm = int.tryParse(input)!;
        break;
      case "6":
        sampleBias = int.tryParse(input)!;
        break;
      case "7":
        tunnelingCurrent = int.tryParse(input)!;
        break;
      case "8":
        sampleName = int.tryParse(input)!;
        break;
      case "9":
        tipName = int.tryParse(input)!;
        break;
    }
  }
}
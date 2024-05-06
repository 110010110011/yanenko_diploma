import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_app/parametersActions.dart';

Future<String> sendPOST(MicroscopeParams microscopeParams) async {
    final response = await http.post(
        Uri.parse('http://myopencart.example.com/index.php?route=api/cart/add'),
        // NB: you don't need to fill headers field
        headers: {
            'Content-Type': 'application/json' // 'application/x-www-form-urlencoded' or whatever you need
        },
        body: {
            'tipName': microscopeParams.tipName,
            'sampleName': microscopeParams.sampleName,
            'tunnelingCurrent': microscopeParams.tunnelingCurrent,
            'sampleBias': microscopeParams.sampleBias,
            'sizeInNm': microscopeParams.sizeInNm,
            'sizeInPxl': microscopeParams.sizeInPxl,
            'differentialFeedback': microscopeParams.differentialFeedback,
            'integralFeedback': microscopeParams.integralFeedback,
            'proportionalFeedback': microscopeParams.proportionalFeedback,
            'timePerPxl': microscopeParams.timePerPxl,
        },
    );

    if (response.statusCode == 200) {
        return response.body;
    } else {
        return "Error ${response.statusCode}: ${response.body}";
    }
}
import 'dart:async';
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:markets/generated/i18n.dart';

import '../models/Step.dart';

class MapsUtil {
  static const String BASE_URL =
      "https://maps.googleapis.com/maps/api/directions/json?";

  static final MapsUtil _instance = MapsUtil.internal();

  MapsUtil.internal();

  factory MapsUtil() => _instance;

  final JsonDecoder _decoder = JsonDecoder();

  Future<List<LatLng>> get(String url) async {
    final response = await http.get(Uri.parse(BASE_URL + url));

    String res = response.body;
    int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode > 400) {
      res = "{\"status\":$statusCode,\"message\":\"error\",\"response\":$res}";
      throw Exception(res);
    }

    List<LatLng> steps = [];
    try {
      steps = parseSteps(
        _decoder.convert(res)["routes"][0]["legs"][0]["steps"],
      );
    } catch (e) {
      print("Error parsing steps: $e");
    }

    return steps;
  }

  List<LatLng> parseSteps(final responseBody) {
    List<Step> _steps = responseBody.map<Step>((json) {
      return Step.fromJson(json);
    }).toList();

    // Ensure conversion to non-nullable LatLng
    List<LatLng> _latLng = _steps
        .map((Step step) => step.startLatLng)
        .where((latLng) => latLng != null)
        .cast<LatLng>()
        .toList();

    return _latLng;
  }

  Future<String> getAddressName(LatLng location, String apiKey) async {
    try {
      final endPoint =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey';

      final response = await http.get(Uri.parse(endPoint));
      final decoded = jsonDecode(response.body);

      return decoded['results'][0]['formatted_address'];
    } catch (e) {
      print("Error in getAddressName: $e");
      return S.current.unknown + '4';
    }
  }
}

// import 'dart:async';
// import 'dart:convert';

// import 'package:google_map_location_picker/google_map_location_picker.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:markets/generated/i18n.dart';

// import '../models/Step.dart';

// class MapsUtil {
//   static final BASE_URL =
//       "https://maps.googleapis.com/maps/api/directions/json?";

//   static MapsUtil _instance = new MapsUtil.internal();

//   MapsUtil.internal();

//   factory MapsUtil() => _instance;
//   final JsonDecoder _decoder = new JsonDecoder();

//   Future<dynamic> get(String url) {
//     return http.get(BASE_URL + url).then((http.Response response) {
//       String res = response.body;
//       int statusCode = response.statusCode;
// //      print("API Response: " + res);
//       if (statusCode < 200 || statusCode > 400 || json == null) {
//         res = "{\"status\":" +
//             statusCode.toString() +
//             ",\"message\":\"error\",\"response\":" +
//             res +
//             "}";
//         throw new Exception(res);
//       }

//       List<LatLng>? steps;
//       try {
//         steps =
//             parseSteps(_decoder.convert(res)["routes"][0]["legs"][0]["steps"]);
//       } catch (e) {
//         // throw new Exception(e);
//       }

//       return steps;
//     });
//   }

//   List<LatLng> parseSteps(final responseBody) {
//     List<Step> _steps = responseBody.map<Step>((json) {
//       return new Step.fromJson(json);
//     }).toList();
//     List<LatLng> _latLang =
//         _steps.map((Step step) => step.startLatLng).toList();
//     return _latLang;
//   }

//   Future<String> getAddressName(LatLng location, String apiKey) async {
//     try {
//       var endPoint =
//           'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location?.latitude},${location?.longitude}&key=$apiKey';
//       var response = jsonDecode((await http.get(endPoint,
//               headers: await LocationUtils.getAppHeaders()))
//           .body);

//       return response['results'][0]['formatted_address'];
//     } catch (e) {
//       print(e);
//       return S.current.unknown + '4';
//     }
//   }
// }

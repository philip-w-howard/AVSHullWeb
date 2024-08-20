import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;

import '../models/hull.dart';
import '../settings/settings.dart';

// **********************************************************
void printLocalStorageKeys() {
  // Iterate over the length of localStorage
  for (int i = 0; i < html.window.localStorage.length; i++) {
    // Get the key at the current index
    String? key = html.window.localStorage.keys.elementAt(i);
    print('Key: $key');
  }
}

// **********************************************************
Future<void> saveFile(String contents, String defaultName, String extension) async {
  try {
    final encodedContent = base64.encode(utf8.encode(contents));

    final anchor = html.AnchorElement(
      href: 'data:text/plain;charset=utf-8;base64,$encodedContent',
    );
    anchor.download = '$defaultName.$extension';
    anchor.click();
  }
  catch (e) {
    //print('caught exception');
  }
 }

// **********************************************
// Does not indicate failure when "cancel" is hit
Future<String?> readFile(String extension) async {
  final completer = Completer<String>();
  try {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.$extension'; 
    uploadInput.click();
    await uploadInput.onChange.first;

    final file = uploadInput.files!.first;
    final reader = html.FileReader();

    reader.onLoadEnd.listen((event) {
      final fileContents = reader.result as String;
      completer.complete(fileContents);
    });

    reader.readAsText(file);

    return completer.future;
  } catch (e) {
    //print('caught exception');
  }
  
  return null;
}

// ***********************************************************
void writeString(String key, String contents) {
  html.window.localStorage[key] = contents;
}
// ***********************************************************
String? readString(String key) {
  return html.window.localStorage[key];
}

// ***********************************************************
void writeHull(Hull hull) {
  String jsonString = json.encode(hull.toJson());
  String key = 'hull.${hull.name}';

  // FIX THIS: check to see if the key already exists?
  writeString(key, jsonString);
  recordLastHull(hull.name);
}
// ***********************************************************
Hull? readHull(String name) {
  String key = 'hull.$name';
  String? jsonString = html.window.localStorage[key];

  if (jsonString != null) {
    Map<String, dynamic> jsonHull = json.decode(jsonString);
    return Hull.fromJson(jsonHull);
  }

  return null;
}


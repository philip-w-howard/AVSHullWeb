import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;
import '../settings/settings.dart';

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

void writeExportOffsetsParams(ExportOffsetsParams params) {
  String jsonString = json.encode(params.toJson());

  print('writing ExportOffsetsParams object to localStorage');
  print(jsonString);
  html.window.localStorage['ExportOffsetsParams'] = jsonString;
}

ExportOffsetsParams readExportOffsetsParams() {
  String? jsonString = html.window.localStorage['ExportOffsetsParams'];
  if (jsonString != null) {
    Map<String, dynamic> paramsMap = json.decode(jsonString);
    print('Loaded ExportOffsetsParams from localStorage');
    return ExportOffsetsParams.fromJson(paramsMap);
  }

  // If setting not found, create default settings
  print('returning default ExportOffsetsParams object');
  return ExportOffsetsParams();
}
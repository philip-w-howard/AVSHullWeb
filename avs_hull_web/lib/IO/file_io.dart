import 'dart:convert';
import 'dart:async';
//import 'dart:html' as html;

import 'dart:js_interop';

import '../models/hull.dart';
import '../settings/settings.dart';

const hullPrefix = 'hull.';

// **********************************************************
@JS('window.localStorage')
external JSStorage get localStorage;

@JS()
@staticInterop
class JSStorage {}

extension JSStorageExtension on JSStorage {
  external int get length;
  external JSString? key(int index);
  external void setItem(String key, String value);
  external JSString? getItem(String key);
}

// **********************************************************
@JS('document.createElement')
external JSAny createElement(String tag);

@JS()
@staticInterop
class AnchorElement {}

extension AnchorElementExtension on AnchorElement {
  external set href(String value);
  external set download(String value);
  external void click();
}

// **********************************************************
@JS()
@staticInterop
class JSFileList {}

extension JSFileListExtension on JSFileList {
  external JSFile? item(int index);
}

// **********************************************************
@JS()
@staticInterop
class InputElement {}

extension InputElementExtension on InputElement {
  external set type(String value);
  external set accept(String value);
  external void click();
  external JSFileList? get files;
  external set onchange(JSFunction handler);
}


// **********************************************************
@JS()
@staticInterop
class JSFile {}

extension JSFileExtension on JSFile {
  external String get name;
}

@JS('FileReader')
@staticInterop
class FileReader {
  external factory FileReader();
}

extension FileReaderExtension on FileReader {
  external void readAsText(JSFile file);
  external set onloadend(JSFunction handler);
  external JSAny? get result;
}

// **********************************************************
void printLocalStorageKeys() {
  for (int i = 0; i < localStorage.length; i++) {
    final JSString? jsKey = localStorage.key(i);
    final String? key = jsKey?.toDart;
    print('Key: $key');
  }
}
// **********************************************************
List<String> getHullNames() {
  List<String> names = [];
  
  for (int i = 0; i < localStorage.length; i++) {
    // Get the key at the current index
    final JSString? jsKey = localStorage.key(i);
    final String? key = jsKey?.toDart;
    if (key != null && key.startsWith(hullPrefix)) {
      names.add(key.substring(hullPrefix.length));
    }
  }

  return names;
}
// **********************************************************
Future<void> saveFile(String contents, String defaultName, String extension) async {
  try {
    final encodedContent = base64.encode(utf8.encode(contents));
    final href = 'data:text/plain;charset=utf-8;base64,$encodedContent';

    final anchor = createElement('a') as AnchorElement;
    anchor.href = href;
    anchor.download = '$defaultName.$extension';
    anchor.click();
  } catch (e) {
    // Handle error if needed
  }
}
// **********************************************
// Does not indicate failure when "cancel" is hit
Future<String?> readFile(String extension) async {
  final completer = Completer<String?>();

  final input = createElement('input') as InputElement;
  input.type = 'file';
  input.accept = '.$extension';

  input.onchange = ((JSAny event) {
    final file = input.files?.item(0);
    if (file == null) {
      completer.complete(null);
      return;
    }

    final reader = FileReader();
    reader.onloadend = ((JSAny _) {
      final result = reader.result;
      if (result != null && result is JSString) {
        completer.complete(result.toDart);
      } else {
        completer.complete(null);
      }
    }).toJS;

    reader.readAsText(file);
  }).toJS;

  input.click();

  return completer.future;
}

// ***********************************************************
void writeString(String key, String contents) {
  localStorage.setItem(key, contents);
}
// ***********************************************************
String? readString(String key) {
  final JSString? jsValue = localStorage.getItem(key);
  return jsValue?.toDart;
}

// ***********************************************************
void writeHull(Hull hull) {
  hull.timeSaved = DateTime.now();

  String jsonString = json.encode(hull.toJson());
  String key = '$hullPrefix${hull.name}';

  // FIX THIS: check to see if the key already exists?
  writeString(key, jsonString);
  recordLastHull(hull.name);
}
// ***********************************************************
Hull? readHull(String name, Hull original) {
  final key = '$hullPrefix$name';
  final JSString? jsJson = localStorage.getItem(key);
  final String? jsonString = jsJson?.toDart;

  if (jsonString != null) {
    Map<String, dynamic> jsonHull = json.decode(jsonString);
    original.updateFromJson(jsonHull);
    return original;
  }

  return null;
}


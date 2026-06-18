import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<String?> pickDeviceImage() async {
  final images = await pickDeviceImages(multiple: false);
  return images.isEmpty ? null : images.first;
}

Future<List<String>> pickDeviceImages({bool multiple = true}) async {
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'image/*'
    ..multiple = multiple;
  input.style.display = 'none';

  final completer = Completer<List<String>>();

  input.onchange = (web.Event _) {
    unawaited(_readSelectedImages(input, completer));
  }.toJS;

  input.oncancel = (web.Event _) {
    if (!completer.isCompleted) completer.complete(const []);
    input.remove();
  }.toJS;

  input.onerror = (web.Event event) {
    if (!completer.isCompleted) completer.completeError(event);
    input.remove();
  }.toJS;

  web.document.body?.append(input);
  input.click();
  return completer.future;
}

Future<void> _readSelectedImages(
  web.HTMLInputElement input,
  Completer<List<String>> completer,
) async {
  try {
    final files = input.files;
    if (files == null || files.length == 0) {
      if (!completer.isCompleted) completer.complete(const []);
      return;
    }

    final images = <String>[];
    for (var index = 0; index < files.length; index++) {
      final file = files.item(index);
      if (file == null) continue;
      images.add(await _readAsDataUrl(file));
    }

    if (!completer.isCompleted) completer.complete(images);
  } catch (error, stackTrace) {
    if (!completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
  } finally {
    input.remove();
  }
}

Future<String> _readAsDataUrl(web.File file) {
  final reader = web.FileReader();
  final completer = Completer<String>();

  reader.onload = (web.Event _) {
    final result = reader.result;
    if (result != null && result.isA<JSString>()) {
      completer.complete((result as JSString).toDart);
    } else {
      completer.completeError(StateError('Selected file could not be read.'));
    }
  }.toJS;

  reader.onerror = (web.Event event) {
    completer.completeError(event);
  }.toJS;

  reader.readAsDataURL(file);
  return completer.future;
}

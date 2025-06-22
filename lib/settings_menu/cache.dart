import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';

Future<int> _getTotalSizeOfFilesInDir(FileSystemEntity file) async {
  if (file is File) {
    return await file.length();
  }
  if (file is Directory) {
    final List<FileSystemEntity> children = file.listSync();
    int total = 0;
    for (final child in children) {
      total += await _getTotalSizeOfFilesInDir(child);
    }
    return total;
  }
  return 0;
}

Future<void> clearCache(BuildContext context) async {
  final cacheDir = await getTemporaryDirectory();
  int cacheSize = await _getTotalSizeOfFilesInDir(cacheDir);

  if (cacheDir.existsSync()) {
    cacheDir.deleteSync(recursive: true);
  }

  CherryToast.success(
    title: Text("Cache Cleared!"),
    description: Text("Freed ${(cacheSize / (1024 * 1024)).toStringAsFixed(2)} MB"),
    animationType: AnimationType.fromLeft,
    toastDuration: Duration(seconds: 3),
  ).show(context);
}
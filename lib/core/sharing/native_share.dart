import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

enum NativeShareOutcome { completed, dismissed, copiedFallback }

Future<NativeShareOutcome> shareTextWithNativeSheet(
  BuildContext context, {
  required String title,
  required String text,
}) async {
  final renderObject = context.findRenderObject();
  final RenderBox? box = renderObject is RenderBox ? renderObject : null;
  final result = await SharePlus.instance.share(
    ShareParams(
      title: title,
      subject: title,
      text: text,
      // Required on iPad and harmless elsewhere; keeps share sheet anchored.
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );

  if (result.status == ShareResultStatus.dismissed) {
    return NativeShareOutcome.dismissed;
  }

  if (result.status == ShareResultStatus.unavailable) {
    await copyShareText(text);
    return NativeShareOutcome.copiedFallback;
  }

  return NativeShareOutcome.completed;
}

Future<void> copyShareText(String text) {
  return Clipboard.setData(ClipboardData(text: text));
}

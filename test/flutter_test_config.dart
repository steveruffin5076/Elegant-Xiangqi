import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Keep tests offline and deterministic: google_fonts falls back to the
/// platform default font instead of fetching over the network.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  return testMain();
}

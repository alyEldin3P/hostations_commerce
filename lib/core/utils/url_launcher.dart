import 'dart:developer';
import 'package:url_launcher/url_launcher.dart' as launcher;

class AppUrlLauncher {
  /// Launches a URL in the default browser
  static Future<bool> launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await launcher.canLaunchUrl(uri)) {
        return await launcher.launchUrl(uri, mode: launcher.LaunchMode.externalApplication);
      } else {
        log('Could not launch URL: $url');
        return false;
      }
    } catch (e) {
      log('Error launching URL: $e');
      return false;
    }
  }
}

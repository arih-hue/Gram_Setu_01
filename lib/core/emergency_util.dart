import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class EmergencyUtil {
  static const String emergencyNumber = '108';

  static Future<void> callEmergency(BuildContext context) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: emergencyNumber,
    );
    
    debugPrint('SOS: Attempting to call $emergencyNumber');
    
    try {
      if (await canLaunchUrl(launchUri)) {
        debugPrint('SOS: canLaunchUrl returned true, launching...');
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('SOS: canLaunchUrl returned FALSE');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Phone dialer not available. Please call 108 manually.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('SOS Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
    }
  }
}

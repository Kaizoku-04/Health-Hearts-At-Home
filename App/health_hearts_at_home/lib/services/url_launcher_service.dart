import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class URLLauncherService {
  // Make a phone call
  static Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

      if (await canLaunchUrl(launchUri)) {
        return await launchUrl(launchUri);
      } else {
        debugPrint('Could not launch phone call');
        return false;
      }
    } catch (e) {
      debugPrint('Error making phone call: $e');
      return false;
    }
  }

  // Send an email
  static Future<bool> sendEmail({
    required String email,
    String subject = '',
    String body = '',
  }) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          if (subject.isNotEmpty) 'subject': subject,
          if (body.isNotEmpty) 'body': body,
        },
      );

      if (await canLaunchUrl(launchUri)) {
        return await launchUrl(launchUri);
      } else {
        debugPrint('Could not send email');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
      return false;
    }
  }

  // Send SMS
  static Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(launchUri)) {
        return await launchUrl(launchUri);
      } else {
        debugPrint('Could not send SMS');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending SMS: $e');
      return false;
    }
  }

  // Open a website
  static Future<bool> openWebsite(String url) async {
    try {
      final Uri launchUri = Uri.parse(url);

      if (await canLaunchUrl(launchUri)) {
        return await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not open website');
        return false;
      }
    } catch (e) {
      debugPrint('Error opening website: $e');
      return false;
    }
  }
}

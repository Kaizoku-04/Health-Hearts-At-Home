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

  static Future<bool> openWebsite(String url) async {
    try {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $url');
        return false;
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      return false;
    }
  }

  // Open Instagram profile (tries app, falls back to web)
  static Future<bool> openInstagram({required String username}) async {
    try {
      // Web URL (always valid)
      final Uri webUrl = Uri.parse('https://www.instagram.com/$username/');

      // Deep link to the app (may or may not be handled)
      final Uri appUrl = Uri.parse('instagram://user?username=$username');

      if (await canLaunchUrl(appUrl)) {
        // Try to open in Instagram app
        return await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      }

      // Fallback to browser
      if (await canLaunchUrl(webUrl)) {
        return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }

      debugPrint('Could not open Instagram for $username');
      return false;
    } catch (e) {
      debugPrint('Error opening Instagram: $e');
      return false;
    }
  }

  // Open Facebook page/profile (tries app, falls back to web)
  static Future<bool> openFacebook({required String pagePath}) async {
    // pagePath example: "lluchildrens" or "LomaLindaUniversityChildrensHealth"
    try {
      final String web = 'https://www.facebook.com/$pagePath';

      // Facebook app deep link for pages/profiles
      final Uri appUrl = Uri.parse('fb://facewebmodal/f?href=$web');
      final Uri webUrl = Uri.parse(web);

      if (await canLaunchUrl(appUrl)) {
        return await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      }

      if (await canLaunchUrl(webUrl)) {
        return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }

      debugPrint('Could not open Facebook for $pagePath');
      return false;
    } catch (e) {
      debugPrint('Error opening Facebook: $e');
      return false;
    }
  }

  // Open YouTube (tries app, then web)
  static Future<bool> openYouTube({required String url}) async {
    try {
      // Normalize URL
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final Uri webUrl = Uri.parse(url);

      // Deep link for YouTube app (optional, if you want to try app scheme)
      // For a full URL, you can often just use it directly with externalApplication.
      final launched = await launchUrl(
        webUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint('Could not open YouTube: $url');
      }
      return launched;
    } catch (e) {
      debugPrint('Error opening YouTube: $e');
      return false;
    }
  }
}

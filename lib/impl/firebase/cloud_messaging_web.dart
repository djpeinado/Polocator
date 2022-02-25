// ignore: avoid_web_libraries_in_flutter
/// Copyright (C) 2021 Alberto Peinado Checa
///
/// This file is part of polocator.
///
/// polocator is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// polocator is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with polocator.  If not, see <http://www.gnu.org/licenses/>.
import 'dart:js' as js;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase/firebase.dart' as firebase;

import '../../misc/const.dart';
import '../../misc/exceptions.dart';

import 'cloud_messaging_base.dart';

class FirebaseCloudMessaging extends FirebaseCloudMessagingBase {
  static final FirebaseCloudMessaging instance = FirebaseCloudMessaging();

  @override
  Future<String?> getId() async {
    // Ask for permission
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.denied:
      case AuthorizationStatus.notDetermined:
        throw new NotificationsNotGrantedException();
      default:
    }

    if (kIsWeb) {
      try {
        String? token = await FirebaseMessaging.instance.getToken(
          vapidKey: js.context[JS.firebaseConfigProxy][JS.vApIdKey],
        );
        return token;
      } on firebase.FirebaseError catch (e) {
        print('FirebaseCloudMessaging - Error: ' + e.toString());
        print('FirebaseException code: ' + e.code);
        if (e.code == 'messaging/permission-blocked') {
          throw new NotificationsNotGrantedException();
        }
        return null;
      } catch (error) {
        print('FirebaseCloudMessaging - Error: ' + error.toString());
        return null;
      }
    }
    return null;
  }
}

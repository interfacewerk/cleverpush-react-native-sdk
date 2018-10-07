import { NativeModules, NativeEventEmitter, NetInfo, Platform } from 'react-native';
import invariant from 'invariant';

const RNCleverPush = NativeModules.CleverPush;

const eventBroadcastNames = [
  'CleverPush-notificationOpened',
  'CleverPush-subscribed'
];

var CleverPushEventEmitter;

var _eventNames = ['opened', 'subscribed'];

var _notificationHandler = new Map();
var _notificationCache = new Map();
var _listeners = [];

if (RNCleverPush != null) {
  CleverPushEventEmitter = new NativeEventEmitter(RNCleverPush);

  for (var i = 0; i < eventBroadcastNames.length; i++) {
    var eventBroadcastName = eventBroadcastNames[i];
    var eventName = _eventNames[i];

    _listeners[eventName] = handleEventBroadcast(eventName, eventBroadcastName)
  }
}

function handleEventBroadcast(type, broadcast) {
  return CleverPushEventEmitter.addListener(
    broadcast, (notification) => {
      var handler = _notificationHandler.get(type);

      if (handler) {
        handler(notification);
      } else {
        _notificationCache.set(type, notification);
      }
    }
  );
}

function checkIfInitialized() {
  return RNCleverPush != null;
}

export default class CleverPush {
  static addEventListener(type: any, handler: Function) {
    if (!checkIfInitialized()) return;

    invariant(
      type === 'opened' || type === 'subscribed',
      'CleverPush only supports `opened`, and `subscribed` events'
    );

    _notificationHandler.set(type, handler);

    // Check if there is a cache for this type of event
    var cache = _notificationCache.get(type);
    if (handler && cache) {
      handler(cache);
      _notificationCache.delete(type);
    }
  }

  static removeEventListener(type, handler) {
    if (!checkIfInitialized()) return;

    invariant(
      type === 'opened' || type === 'subscribed',
      'CleverPush only supports `opened`, and `subscribed` events'
    );

    _notificationHandler.delete(type);
  }

  static clearListeners() {
    if (!checkIfInitialized()) return;

    for (var i = 0; i < _eventNames.length; i++) {
      _listeners[_eventNames].remove();
    }
  }

  static registerForPushNotifications() {
    if (!checkIfInitialized()) return;

    if (Platform.OS === 'ios') {
      RNCleverPush.registerForPushNotifications();
    } else {
      console.log('This function is not supported on Android');
    }
  }

  static promptForPushNotificationsWithUserResponse(callback: Function) {
    if (!checkIfInitialized()) return;

    if (Platform.OS === 'ios') {
      invariant(
        typeof callback === 'function',
        'Must provide a valid callback'
      );
      RNCleverPush.promptForPushNotificationsWithUserResponse(callback);
    } else {
      console.log('This function is not supported on Android');
    }
  }

  static requestPermissions(permissions) {
    if (!checkIfInitialized()) return;

    var requestedPermissions = {};
    if (Platform.OS === 'ios') {
      if (permissions) {
        requestedPermissions = {
          alert: !!permissions.alert,
          badge: !!permissions.badge,
          sound: !!permissions.sound
        };
      } else {
        requestedPermissions = {
          alert: true,
          badge: true,
          sound: true
        };
      }
      RNCleverPush.requestPermissions(requestedPermissions);
    } else {
      console.log('This function is not supported on Android');
    }
  }

  static configure() {
    if (!checkIfInitialized()) return;

    RNCleverPush.configure();
  }

  static init(appId, iOSSettings) {
    if (Platform.OS === 'ios') {
      RNCleverPush.initWithAppId(appId, iOSSettings);
    } else {
      RNCleverPush.init(appId);
    }
  }

  static checkPermissions(callback: Function) {
    if (!checkIfInitialized()) return;

    if (Platform.OS === 'ios') {
      invariant(
        typeof callback === 'function',
        'Must provide a valid callback'
      );
      RNCleverPush.checkPermissions(callback);
    } else {
      console.log('This function is not supported on Android');
    }
  }

  static promptForPushNotificationPermissions(callback) {
    if (!checkIfInitialized()) return;

    if (Platform.OS === 'ios') {
      RNCleverPush.promptForPushNotificationPermissions(callback);
    } else {
      console.log('This function is not supported on Android');
    }
  }

  static getPermissionSubscriptionState(callback: Function) {
    if (!checkIfInitialized()) return;

    invariant(
      typeof callback === 'function',
      'Must provide a valid callback'
    );
    RNCleverPush.getPermissionSubscriptionState(callback);
  }

  static deleteTag(key) {
    if (!checkIfInitialized()) return;

    RNCleverPush.deleteTag(key);
  }

  static enableVibrate(enable) {
    if (!checkIfInitialized()) return;

    if (Platform.OS === 'android') {
      RNCleverPush.enableVibrate(enable);
    } else {
      console.log('This method is not supported on iOS');
    }
  }

  static enableSound(enable) {
    if (!checkIfInitialized()) return;

    if (Platform.OS === 'android') {
      RNCleverPush.enableSound(enable);
    } else {
      console.log('This method is not supported on iOS');
    }
  }

  static setLogLevel(nsLogLevel, visualLogLevel) {
    if (!checkIfInitialized()) return;

    RNCleverPush.setLogLevel(nsLogLevel, visualLogLevel);
  }

}

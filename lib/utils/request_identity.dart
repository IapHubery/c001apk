import '../constants/constants.dart';
import 'device_code.dart';
import 'ios_headers.dart';
import 'token_util.dart';

enum RequestIdentity { android, ios, device }

extension RequestIdentityInfo on RequestIdentity {
  String get storageKey {
    switch (this) {
      case RequestIdentity.android:
        return 'parameter_android';
      case RequestIdentity.ios:
        return 'parameter_ios';
      case RequestIdentity.device:
        return 'parameter_device';
    }
  }

  String get label {
    switch (this) {
      case RequestIdentity.android:
        return 'Android';
      case RequestIdentity.ios:
        return 'iOS';
      case RequestIdentity.device:
        return '跟随真实设备';
    }
  }
}

/// Android 请求身份的完整参数。
class AndroidParams {
  static final Map<String, String> _tokenCache = <String, String>{};

  String versionName;
  String apiVersion;
  String versionCode;
  String manufacturer;
  String brand;
  String model;
  String buildNumber;
  String sdkInt;
  String androidVersion;
  String szlmId;

  /// 已编码的 `X-App-Device`，与上面的机型字段保持一致。
  String appDevice;

  AndroidParams({
    required this.versionName,
    required this.apiVersion,
    required this.versionCode,
    required this.manufacturer,
    required this.brand,
    required this.model,
    required this.buildNumber,
    required this.sdkInt,
    required this.androidVersion,
    this.szlmId = '',
    required this.appDevice,
  });

  factory AndroidParams.defaults() {
    return AndroidParams(
      versionName: Constants.VERSION_NAME,
      apiVersion: Constants.API_VERSION,
      versionCode: Constants.VERSION_CODE,
      manufacturer: 'Google',
      brand: 'Google',
      model: 'Pixel 8',
      buildNumber: 'UQ1A.240205.004',
      sdkInt: '34',
      androidVersion: '14',
      appDevice: '',
    )..rebuildAppDevice();
  }

  factory AndroidParams.fromJson(Map<String, dynamic> json) {
    return AndroidParams(
      versionName: _string(json['versionName'], Constants.VERSION_NAME),
      apiVersion: _string(json['apiVersion'], Constants.API_VERSION),
      versionCode: _string(json['versionCode'], Constants.VERSION_CODE),
      manufacturer: _string(json['manufacturer'], 'Google'),
      brand: _string(json['brand'], 'Google'),
      model: _string(json['model'], 'Pixel 8'),
      buildNumber: _string(json['buildNumber'], 'UQ1A.240205.004'),
      sdkInt: _string(json['sdkInt'], '34'),
      androidVersion: _string(json['androidVersion'], '14'),
      szlmId: json['szlmId'] is String ? json['szlmId'] as String : '',
      appDevice: _string(json['appDevice'], ''),
    )..ensureAppDevice();
  }

  Map<String, dynamic> toJson() {
    return {
      'versionName': versionName,
      'apiVersion': apiVersion,
      'versionCode': versionCode,
      'manufacturer': manufacturer,
      'brand': brand,
      'model': model,
      'buildNumber': buildNumber,
      'sdkInt': sdkInt,
      'androidVersion': androidVersion,
      'szlmId': szlmId,
      'appDevice': appDevice,
    };
  }

  String get userAgent {
    return 'Dalvik/2.1.0 (Linux; U; Android $androidVersion; $model $buildNumber) '
        '(#Build; $brand; $model; $buildNumber; $androidVersion) '
        '+CoolMarket/$versionName-$versionCode-${Constants.MODE}';
  }

  Map<String, String> get headers {
    return {
      'User-Agent': userAgent,
      'X-Requested-With': 'XMLHttpRequest',
      'X-Sdk-Int': sdkInt,
      'X-Sdk-Locale': Constants.LOCALE,
      'X-App-Id': Constants.APP_ID,
      'X-App-Token': _tokenCache.putIfAbsent(
        appDevice,
        () => TokenUtils.getTokenV2(appDevice),
      ),
      'X-App-Version': versionName,
      'X-App-Code': versionCode,
      'X-Api-Version': apiVersion,
      'X-App-Device': appDevice,
      'X-Dark-Mode': Constants.DARK_MODE,
      'X-App-Channel': Constants.CHANNEL,
      'X-App-Mode': Constants.MODE,
      'X-App-Supported': Constants.APP_SUPPORTED,
    };
  }

  /// 只替换设备串骨架里的机型字段，保留服务端已登记的 MAC/尾部字段。
  void rebuildAppDevice() {
    final String deviceId = szlmId.replaceAll(';', '').trim();
    final String maker = manufacturer.replaceAll(';', '').trim();
    final String deviceBrand = brand.replaceAll(';', '').trim();
    final String deviceModel = model.replaceAll(';', '').trim();
    final String deviceBuild = buildNumber.replaceAll(';', '').trim();
    final List<String> parts =
        DeviceCode.decode(Constants.DEFAULT_ANDROID_DEVICE_CODE).split(';');
    if (parts.length >= 9) {
      parts[0] = deviceId;
      parts[4] = ' $maker';
      parts[5] = ' $deviceBrand';
      parts[6] = ' $deviceModel';
      parts[7] = ' $deviceBuild';
      appDevice = DeviceCode.encode(parts.join(';'));
    } else {
      appDevice = DeviceCode.encode(
        '$deviceId; ; ; ; $maker; $deviceBrand; $deviceModel; $deviceBuild; null',
      );
    }
  }

  void ensureAppDevice() {
    if (appDevice.isEmpty) {
      rebuildAppDevice();
    }
  }
}

/// iOS 请求身份的完整参数。
class IosParams {
  String id;
  String model;
  String hardwareId;
  String salesModel;
  String systemVersion;

  IosParams({
    required this.id,
    required this.model,
    required this.hardwareId,
    required this.salesModel,
    required this.systemVersion,
  });

  factory IosParams.fromDevice(IosDevice device) {
    return IosParams(
      id: device.id,
      model: device.model,
      hardwareId: device.hardwareId,
      salesModel: device.salesModel,
      systemVersion: device.systemVersion,
    );
  }

  factory IosParams.fromJson(Map<String, dynamic> json) {
    return IosParams(
      id: _string(json['id'], ''),
      model: _string(json['model'], 'iPhone 16'),
      hardwareId: _string(json['hardwareId'], 'iPhone17,3'),
      salesModel: json['salesModel'] is String
          ? json['salesModel'] as String
          : 'MYEV3CH/A',
      systemVersion: _string(json['systemVersion'], '26.7.1'),
    );
  }

  IosDevice toDevice() {
    return IosDevice(
      id: id,
      model: model,
      hardwareId: hardwareId,
      salesModel: salesModel,
      systemVersion: systemVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'hardwareId': hardwareId,
      'salesModel': salesModel,
      'systemVersion': systemVersion,
    };
  }

  String get userAgent => IosHeaders.userAgent(toDevice());

  String get appDevice => IosHeaders.appDevice(toDevice());

  Map<String, String> get headers => IosHeaders.headers(toDevice());
}

/// `parameter_android` / `parameter_ios` / `parameter_device` 的实际内容。
class RequestProfile {
  /// `android` 或 `ios`
  final String type;
  final AndroidParams? android;
  final IosParams? ios;

  const RequestProfile._({
    required this.type,
    this.android,
    this.ios,
  });

  factory RequestProfile.android(AndroidParams params) {
    return RequestProfile._(type: 'android', android: params);
  }

  factory RequestProfile.ios(IosParams params) {
    return RequestProfile._(type: 'ios', ios: params);
  }

  factory RequestProfile.fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'ios') {
      return RequestProfile.ios(IosParams.fromJson(json));
    }
    return RequestProfile.android(AndroidParams.fromJson(json));
  }

  bool get isIos => type == 'ios';

  Map<String, dynamic> toJson() {
    if (isIos) {
      return {'type': 'ios', ...ios!.toJson()};
    }
    return {'type': 'android', ...android!.toJson()};
  }

  String get userAgent {
    return isIos ? ios!.userAgent : android!.userAgent;
  }

  String get appDevice {
    return isIos ? ios!.appDevice : android!.appDevice;
  }

  Map<String, String> get headers {
    return isIos ? ios!.headers : android!.headers;
  }
}

String _string(dynamic value, String fallback) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return fallback;
}

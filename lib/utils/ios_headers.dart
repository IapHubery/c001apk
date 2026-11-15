import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// 酷安 iOS 客户端的设备身份。
///
/// 服务端会对「新伪造的 Android 设备串」要求人机验证
/// （`err_request_captcha_v2` / 「当前访问需要验证码」），
/// 而 iOS 身份只依赖设备 ID 与秒级时间戳，且不需要 Android 的
/// versionCode / szlmId，因此详情、评论等接口可以稳定通过校验。
class IosDevice {
  final String id;
  final String model;
  final String hardwareId;
  final String salesModel;
  final String systemVersion;

  const IosDevice({
    required this.id,
    required this.model,
    required this.hardwareId,
    required this.salesModel,
    required this.systemVersion,
  });

  IosDevice copyWith({
    String? id,
    String? model,
    String? hardwareId,
    String? salesModel,
    String? systemVersion,
  }) {
    return IosDevice(
      id: id ?? this.id,
      model: model ?? this.model,
      hardwareId: hardwareId ?? this.hardwareId,
      salesModel: salesModel ?? this.salesModel,
      systemVersion: systemVersion ?? this.systemVersion,
    );
  }
}

class IosHeaders {
  static const String bundleId = 'com.coolapk.app';
  static const String appVersion = '16.6.1';
  static const String appCode = '2610151';
  static const String apiVersion = '16';
  static const String sdkLocale = 'zh-HK';
  static const String acceptLanguage =
      'zh-Hans-HK;q=1.0, zh-Hant-HK;q=0.9, en-HK;q=0.8';

  /// iOS token 固定前缀（逆向自官方客户端，跨版本稳定）。
  static const String _tokenPrefix =
      'token://com.coolapk.app/1e7870f7312eb435aef6b59b211a9880?';

  /// 与参考实现一致的 iPhone 机型 / 硬件 ID / 销售型号组合。
  static const List<List<String>> _profiles = [
    ['iPhone 15', 'iPhone15,4', 'MTLD3CH/A'],
    ['iPhone 15', 'iPhone15,4', 'MTLG3CH/A'],
    ['iPhone 16', 'iPhone17,3', 'MYEV3CH/A'],
    ['iPhone 16', 'iPhone17,3', 'MYEW3CH/A'],
    ['iPhone 17', 'iPhone18,3', 'MG6W4CH/A'],
    ['iPhone 17', 'iPhone18,3', 'MG704CH/A'],
  ];

  static const List<String> _systemVersions = ['26.7', '26.7.1', '27.0.1'];

  /// 首次启动时生成一份持久化的 iOS 机型档案。
  static IosDevice createDevice({String? id}) {
    final random = Random();
    final profile = _profiles[random.nextInt(_profiles.length)];
    return IosDevice(
      id: id ?? const Uuid().v4().toUpperCase(),
      model: profile[0],
      hardwareId: profile[1],
      salesModel: profile[2],
      systemVersion: _systemVersions[random.nextInt(_systemVersions.length)],
    );
  }

  /// `X-App-Device`：标准 Base64 → 整串反转 → 去掉开头的 `=`。
  static String appDevice(IosDevice device) {
    final identity = device.salesModel.isEmpty
        ? device.hardwareId
        : '${device.hardwareId}/${device.salesModel}';
    final plain = [
      device.id,
      '',
      '',
      '',
      'Apple',
      'Apple',
      device.model,
      identity,
    ].join('; ');
    return base64Encode(utf8.encode(plain))
        .split('')
        .reversed
        .join()
        .replaceAll(RegExp(r'^=+'), '');
  }

  /// iOS 客户端 User-Agent；`iPhone OS 18_7` 为官方客户端的固定片段。
  static String userAgent(IosDevice device) {
    return 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 '
        '(#Build; Apple; ${device.hardwareId}; ${device.model}; '
        'iOS_${device.systemVersion}) '
        '+iCoolMarket/$appVersion-$appCode';
  }

  /// iOS `X-App-Token`：只依赖设备 ID 与秒级时间戳。
  static String appToken(IosDevice device, int timestampSeconds) {
    final timeMd5 = _md5Hex(timestampSeconds.toString());
    final material = '$_tokenPrefix$timeMd5\$${device.id}&$bundleId';
    final digest = _md5Hex(base64Encode(utf8.encode(material)));
    final low32 = timestampSeconds & 0xffffffff;
    return '$digest${device.id}0x${low32.toRadixString(16)}';
  }

  static Map<String, String> headers(
    IosDevice device, {
    int? timestampSeconds,
  }) {
    final seconds =
        timestampSeconds ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return {
      'Accept': '*/*',
      'Accept-Language': acceptLanguage,
      'User-Agent': userAgent(device),
      'X-Requested-With': 'XMLHttpRequest',
      'X-Sdk-Int': device.systemVersion,
      'X-Sdk-Locale': sdkLocale,
      'X-App-Id': bundleId,
      'X-App-Version': appVersion,
      'X-App-Code': appCode,
      'X-Api-Version': apiVersion,
      'X-App-Device': appDevice(device),
      'X-App-Token': appToken(device, seconds),
    };
  }

  static String _md5Hex(String input) {
    return md5.convert(utf8.encode(input)).toString().replaceAll('-', '');
  }
}

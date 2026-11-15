import 'dart:convert';

/// 酷安 Android `X-App-Device` 的编码/解码。
///
/// 明文形如：
/// `szlmId; ; ; mac; 厂商; 品牌; 型号; 版本号; 尾部64hex`
class DeviceCode {
  static String encode(String deviceInfo) {
    final String encoded = base64Encode(utf8.encode(deviceInfo));
    return encoded
        .split('')
        .reversed
        .join()
        .replaceAll(RegExp(r'(\r\n|\r|\n|=)'), '');
  }

  static String decode(String deviceCode) {
    final String reversed = deviceCode.split('').reversed.join();
    final int padding = (4 - reversed.length % 4) % 4;
    return utf8.decode(base64Decode(reversed + '=' * padding));
  }
}

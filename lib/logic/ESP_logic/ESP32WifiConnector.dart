import 'package:wifi_iot/wifi_iot.dart';

class ESP32WifiConnector {
  static Future<bool> connectToESP({
    String ssid = "ESP32_AP",
    String password = "12345678",
  }) async {
    try {
      bool connected = await WiFiForIoTPlugin.connect(
        ssid,
        password: password,
        joinOnce: true,
        security: NetworkSecurity.WPA,
      );
      print("📡 Wi-Fi Connected: $connected");
      return connected;
    } catch (e) {
      print("⚠️ Wi-Fi connect error: $e");
      return false;
    }
  }
}

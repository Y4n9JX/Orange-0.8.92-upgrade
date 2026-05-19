import 'dart:io';

import 'package:socks5_proxy/socks_client.dart';

/// Network helpers for XBoard's internal service channel.
///
/// XBoard service traffic (panel API, remote config, updates, websocket,
/// subscription bootstrap) must not be implicitly routed through FlClash's
/// global [HttpOverrides]. The user-facing proxy switch/node selection belongs
/// to user traffic, while XBoard bootstrap traffic is explicitly either DIRECT
/// or the configured bootstrap SOCKS5 proxy.
class XBoardNetworkUtils {
  XBoardNetworkUtils._();

  /// Force a client to ignore process/global proxy overrides.
  static void bypassGlobalProxy(HttpClient client) {
    client.findProxy = (_) => 'DIRECT';
  }

  /// Apply a SOCKS5 proxy explicitly to [client].
  static void applySocks5Proxy(HttpClient client, String proxyUrl) {
    final proxyConfig = parseProxyConfig(proxyUrl);
    final proxySettings = ProxySettings(
      InternetAddress(proxyConfig['host']!),
      int.parse(proxyConfig['port']!),
      username: proxyConfig['username'],
      password: proxyConfig['password'],
    );

    SocksTCPClient.assignToHttpClient(client, [proxySettings]);
  }

  /// Parse proxy URLs like:
  /// - socks5://user:pass@host:port
  /// - socks5://host:port
  /// - http://user:pass@host:port
  static Map<String, String?> parseProxyConfig(String proxyUrl) {
    String url = proxyUrl.trim();

    if (url.toLowerCase().startsWith('socks5://')) {
      url = url.substring(9);
    } else if (url.toLowerCase().startsWith('http://')) {
      url = url.substring(7);
    } else if (url.toLowerCase().startsWith('https://')) {
      url = url.substring(8);
    }

    String? username;
    String? password;
    String hostPort = url;

    if (url.contains('@')) {
      final atIndex = url.lastIndexOf('@');
      final authPart = url.substring(0, atIndex);
      hostPort = url.substring(atIndex + 1);

      if (authPart.contains(':')) {
        final colonIndex = authPart.indexOf(':');
        username = authPart.substring(0, colonIndex);
        password = authPart.substring(colonIndex + 1);
      }
    }

    final colonIndex = hostPort.lastIndexOf(':');
    if (colonIndex == -1) {
      throw FormatException('代理配置格式错误，缺少端口号: ${maskProxyUrl(proxyUrl)}');
    }

    final host = hostPort.substring(0, colonIndex);
    final port = hostPort.substring(colonIndex + 1);

    if (host.isEmpty || port.isEmpty) {
      throw FormatException('代理配置格式错误: ${maskProxyUrl(proxyUrl)}');
    }

    return {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
    };
  }

  /// Mask credentials before writing proxy URLs to logs.
  static String maskProxyUrl(String? proxyUrl) {
    if (proxyUrl == null || proxyUrl.isEmpty) return '';
    return proxyUrl.replaceFirst(RegExp(r'//([^:/@]+):([^@]+)@'), '//***:***@');
  }
}

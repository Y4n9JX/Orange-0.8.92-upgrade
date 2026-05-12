import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/xboard/features/invite/pages/invite_page.dart';
import 'package:fl_clash/xboard/features/online_support/presentation/pages/chatway_support_page.dart';
import 'package:fl_clash/xboard/features/payment/pages/plans.dart';
import 'package:fl_clash/xboard/features/subscription/pages/xboard_home_page.dart';
import 'package:flutter/material.dart';

class Navigation {
  static Navigation? _instance;

  List<NavigationItem> getItems({
    bool openLogs = false,
    bool hasProxies = false,
  }) {
    return [
      NavigationItem(
        icon: const Icon(Icons.home),
        label: PageLabel.xboard,
        builder: (_) =>
            const XBoardHomePage(key: GlobalObjectKey(PageLabel.xboard)),
        modes: const [NavigationItemMode.mobile, NavigationItemMode.desktop],
      ),
      NavigationItem(
        icon: const Icon(Icons.shopping_cart),
        label: PageLabel.plans,
        builder: (_) => const PlansView(key: GlobalObjectKey(PageLabel.plans)),
        modes: const [NavigationItemMode.desktop],
      ),
      NavigationItem(
        icon: const Icon(Icons.support_agent),
        label: PageLabel.onlineSupport,
        builder: (_) => const ChatwaySupportPage(
          key: GlobalObjectKey(PageLabel.onlineSupport),
        ),
        modes: const [NavigationItemMode.desktop],
      ),
      NavigationItem(
        icon: const Icon(Icons.people),
        label: PageLabel.invite,
        builder: (_) =>
            const InvitePage(key: GlobalObjectKey(PageLabel.invite)),
        modes: const [NavigationItemMode.mobile, NavigationItemMode.desktop],
      ),
    ];
  }

  Navigation._internal();

  factory Navigation() {
    _instance ??= Navigation._internal();
    return _instance!;
  }
}

final navigation = Navigation();

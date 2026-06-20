import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

abstract final class AppLucideIcons {
  static const IconData activity = LucideIcons.activity;
  static const IconData badgeCheck = LucideIcons.badgeCheck;
  static const IconData badgeInfo = LucideIcons.badgeInfo;
  static const IconData bell = LucideIcons.bell;
  static const IconData bike = LucideIcons.bike;
  static const IconData building = LucideIcons.building2;
  static const IconData calendar = LucideIcons.calendarDays;
  static const IconData calendarCheck = LucideIcons.calendarCheck;
  static const IconData calendarClock = LucideIcons.calendarClock;
  static const IconData calendarPlus = LucideIcons.calendarPlus;
  static const IconData chart = LucideIcons.chartNoAxesColumnIncreasing;
  static const IconData check = LucideIcons.check;
  static const IconData chevronLeft = LucideIcons.chevronLeft;
  static const IconData chevronRight = LucideIcons.chevronRight;
  static const IconData circleCheck = LucideIcons.circleCheck;
  static const IconData clock = LucideIcons.clock;
  static const IconData door = LucideIcons.doorOpen;
  static const IconData drink = LucideIcons.glassWater;
  static const IconData dumbbell = LucideIcons.dumbbell;
  static const IconData eye = LucideIcons.eye;
  static const IconData eyeOff = LucideIcons.eyeOff;
  static const IconData flame = LucideIcons.flame;
  static const IconData heart = LucideIcons.heart;
  static const IconData history = LucideIcons.history;
  static const IconData home = LucideIcons.home;
  static const IconData info = LucideIcons.info;
  static const IconData leaf = LucideIcons.leaf;
  static const IconData lock = LucideIcons.lock;
  static const IconData logIn = LucideIcons.logIn;
  static const IconData logOut = LucideIcons.logOut;
  static const IconData mail = LucideIcons.mail;
  static const IconData map = LucideIcons.map;
  static const IconData mapPin = LucideIcons.mapPin;
  static const IconData mapPinned = LucideIcons.mapPinned;
  static const IconData music = LucideIcons.music;
  static const IconData navigation = LucideIcons.navigation;
  static const IconData parking = LucideIcons.parkingCircle;
  static const IconData person = LucideIcons.userRound;
  static const IconData phone = LucideIcons.phone;
  static const IconData qrCode = LucideIcons.qrCode;
  static const IconData qrScanner = LucideIcons.scanQrCode;
  static const IconData search = LucideIcons.search;
  static const IconData security = LucideIcons.shieldCheck;
  static const IconData share = LucideIcons.share2;
  static const IconData shower = LucideIcons.showerHead;
  static const IconData sparkles = LucideIcons.sparkles;
  static const IconData star = LucideIcons.star;
  static const IconData timer = LucideIcons.timer;
  static const IconData userPlus = LucideIcons.userPlus;
  static const IconData users = LucideIcons.users;
  static const IconData wifi = LucideIcons.wifi;

  static IconData resolveGymIcon(String? key, {IconData fallback = dumbbell}) {
    final normalizedKey = _normalizeIconKey(key);

    return switch (normalizedKey) {
      'activity' || 'history' => activity,
      'apartment' || 'building' || 'branch' || 'location-branch' => building,
      'badge-check' ||
      'beginner-friendly' ||
      'check' ||
      'verified' ||
      'verified-user' => badgeCheck,
      'bike' || 'cardio' || 'cardio-zone' => bike,
      'calendar' || 'calendar-days' || 'calendar-month' => calendar,
      'calendar-check' || 'event-available' => calendarCheck,
      'calendar-clock' || 'schedule' => calendarClock,
      'chart' ||
      'condition' ||
      'conditioning' ||
      'progress' ||
      'progress-tracking' ||
      'show-chart' => chart,
      'clock' || 'duration' || 'time' || 'timer' => timer,
      'door' || 'door-front-door' || 'check-in' => door,
      'drink' || 'juice' || 'juice-bar' || 'water' => drink,
      'dumbbell' ||
      'fitness' ||
      'fitness-center' ||
      'free-weight' ||
      'gym' ||
      'gym-area' ||
      'heavy-lift' ||
      'strength' ||
      'strength-training' ||
      'weight-area' => dumbbell,
      'eco' || 'flexibility' || 'leaf' || 'yoga' => leaf,
      'fire' ||
      'burn' ||
      'fat-burn' ||
      'fat-loss' ||
      'flame' ||
      'hiit' => flame,
      'group' ||
      'groups' ||
      'class' ||
      'class-room' ||
      'class-studio' ||
      'group-class' ||
      'all-level' ||
      'users' => users,
      'heart' ||
      'low-impact' ||
      'mobility' ||
      'recovery' ||
      'recovery-area' => heart,
      'home' => home,
      'info' => info,
      'locker' || 'lock' => lock,
      'login' || 'log-in' => logIn,
      'logout' || 'log-out' => logOut,
      'map' => map,
      'map-pin' || 'location' || 'location-on' => mapPin,
      'music' || 'music-note' || 'dance' || 'cardio-dance' || 'zumba' => music,
      'navigation' || 'directions' => navigation,
      'parking' || 'local-parking' || 'basement-parking' || 'park' => parking,
      'person' || 'profile' || 'trainer' => person,
      'personal-trainer' || 'pt-session' || 'user-plus' => userPlus,
      'phone' || 'whatsapp' => phone,
      'qr-code' => qrCode,
      'qr-scanner' || 'qr-code-scanner' => qrScanner,
      'search' => search,
      'security' || 'shield' || 'shield-check' => security,
      'shower' || 'shower-room' || 'shower-head' => shower,
      'sparkles' ||
      'auto-awesome' ||
      'core-control' ||
      'high-energy' => sparkles,
      'star' || 'rating' => star,
      'wifi' || 'wi-fi' || 'free-wifi' || 'free-wi-fi' => wifi,
      _ => fallback,
    };
  }

  static String _normalizeIconKey(String? key) {
    return (key ?? '')
        .trim()
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match.group(1)}-${match.group(2)}',
        )
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const LAYOUT = _Paths.LAYOUT;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const CATEGORY = _Paths.CATEGORY; // Added
  static const DISH = _Paths.DISH;
  static const ALL_ORDER = _Paths.ALL_ORDER;
  static const STOCK = _Paths.STOCK;
  static const PEOPLE = _Paths.PEOPLE;
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const LAYOUT = '/layout';
  static const DASHBOARD = '/dashboard';
  static const CATEGORY = '/category'; // Added
  static const DISH = '/dish';
  static const ALL_ORDER = '/all-order';
  static const STOCK = '/stock';
  static const PEOPLE = '/people';
}

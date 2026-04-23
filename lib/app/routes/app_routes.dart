abstract class Routes {
  Routes._();

  static const LOGIN = _Paths.login;
  static const LAYOUT = _Paths.layout;
  static const DASHBOARD = _Paths.dashboard;
  static const CATEGORY = _Paths.category;
  static const DISH = _Paths.dish;
  static const QUOTATION = _Paths.quotation;
  static const ALL_ORDER = _Paths.allOrder;
  static const INVOICE = _Paths.invoice;
  static const STOCK = _Paths.stock;
  static const PAYMENT_HISTORY = _Paths.paymentHistory;
  static const EXPENSE = _Paths.expense;
  static const CREATE_INGREDIENT = _Paths.createIngredient;
  static const PEOPLE = _Paths.people;
  static const EVENT_SUMMARY = _Paths.eventSummary;
  static const GROUND_CHECKLIST = _Paths.groundChecklist;
}

abstract class _Paths {
  _Paths._();

  static const login = '/login';
  static const layout = '/layout';
  static const dashboard = '/dashboard';
  static const category = '/category';
  static const dish = '/dish';
  static const quotation = '/quotation';
  static const allOrder = '/all-order';
  static const invoice = '/invoice';
  static const stock = '/stock';
  static const paymentHistory = '/payment-history';
  static const expense = '/expense';
  static const createIngredient = '/create-ingredient';
  static const people = '/people';
  static const eventSummary = '/event-summary';
  static const groundChecklist = '/ground-checklist';
}

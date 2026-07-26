import '../state/aladin_app_prefs.dart';

class ParentalService {
  ParentalService._();
  static final ParentalService instance = ParentalService._();

  bool get isEnabled => AladinPrefs.instance.getBool('parental_enabled', def: false);
  String get _pin => AladinPrefs.instance.getString('parental_pin') ?? '0000';

  bool verifyPin(String pin) => pin == _pin;

  Future<void> setPin(String newPin) async {
    await AladinPrefs.instance.setString('parental_pin', newPin);
  }

  Future<void> setEnabled(bool enabled) async {
    await AladinPrefs.instance.setBool('parental_enabled', enabled);
  }

  bool isCategoryLocked(String categoryName) {
    if (!isEnabled) return false;
    final locked = AladinPrefs.instance.getString('locked_categories') ?? '';
    return locked.split(',').contains(categoryName);
  }

  Future<void> toggleCategoryLock(String categoryName) async {
    final lockedStr = AladinPrefs.instance.getString('locked_categories') ?? '';
    final locked = lockedStr.split(',').where((e) => e.isNotEmpty).toSet();
    
    if (locked.contains(categoryName)) {
      locked.remove(categoryName);
    } else {
      locked.add(categoryName);
    }
    
    await AladinPrefs.instance.setString('locked_categories', locked.join(','));
  }
}

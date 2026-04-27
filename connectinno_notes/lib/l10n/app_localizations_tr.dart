// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Connectinno Notlar';

  @override
  String get navNotes => 'Notlar';

  @override
  String get navLogout => 'Çıkış';

  @override
  String get authLogin => 'Giriş';

  @override
  String get authSignUp => 'Kayıt ol';

  @override
  String get authCreateAccount => 'Hesap oluştur';

  @override
  String get authEmail => 'E-posta';

  @override
  String get authPassword => 'Şifre';

  @override
  String get authConfirmPassword => 'Şifre (tekrar)';

  @override
  String get authNoAccount => 'Hesabın yok mu? Kayıt ol';

  @override
  String get authHasAccount => 'Hesabın var mı? Giriş yap';

  @override
  String get searchHint => 'Başlık veya içerikle ara';

  @override
  String get filterAll => 'Tümü';

  @override
  String get filterPinned => 'Sabit';

  @override
  String get noteDeleted => 'Not kaldırıldı';

  @override
  String get emptyNotesTitle => 'Henüz not yok';

  @override
  String get emptyNotesBody => 'Başlamak için bir not oluşturun.';

  @override
  String get addNote => 'Not ekle';

  @override
  String get editNote => 'Notu düzenle';

  @override
  String get newNote => 'Yeni not';

  @override
  String get noteTitle => 'Başlık';

  @override
  String get noteContent => 'İçerik';

  @override
  String get noteSaved => 'Kaydedildi';

  @override
  String get noteDelete => 'Sil';

  @override
  String get notePin => 'Sabitle';

  @override
  String get noteUnpin => 'Sabitlemeyi kaldır';

  @override
  String get undo => 'Geri al';

  @override
  String get errorGeneric => 'Bir şeyler ters gitti. Tekrar deneyin.';

  @override
  String get errorAuth => 'Giriş başarısız. Bilgilerinizi kontrol edin.';

  @override
  String get loading => 'Yükleniyor…';

  @override
  String get actionSave => 'Kaydet';

  @override
  String get actionCancel => 'İptal';
}

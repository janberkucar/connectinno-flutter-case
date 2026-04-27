// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Connectinno Notes';

  @override
  String get navNotes => 'Notes';

  @override
  String get navLogout => 'Log out';

  @override
  String get authLogin => 'Log in';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authNoAccount => 'No account? Sign up';

  @override
  String get authHasAccount => 'Already have an account? Log in';

  @override
  String get searchHint => 'Search by title or content';

  @override
  String get filterAll => 'All';

  @override
  String get filterPinned => 'Pinned';

  @override
  String get noteDeleted => 'Note removed';

  @override
  String get emptyNotesTitle => 'No notes yet';

  @override
  String get emptyNotesBody => 'Create a note to get started.';

  @override
  String get addNote => 'Add note';

  @override
  String get editNote => 'Edit note';

  @override
  String get newNote => 'New note';

  @override
  String get noteTitle => 'Title';

  @override
  String get noteContent => 'Content';

  @override
  String get noteSaved => 'Saved';

  @override
  String get noteDelete => 'Delete';

  @override
  String get notePin => 'Pin';

  @override
  String get noteUnpin => 'Unpin';

  @override
  String get undo => 'Undo';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorAuth => 'Sign in failed. Check your details.';

  @override
  String get loading => 'Loading…';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @quran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quran;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @hadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get hadith;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @prayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get prayer;

  /// No description provided for @prayer_times.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayer_times;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @account_settings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get account_settings;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// No description provided for @light_mode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get light_mode;

  /// No description provided for @dark_mode_description.
  ///
  /// In en, this message translates to:
  /// **'More comfortable display at night'**
  String get dark_mode_description;

  /// No description provided for @light_mode_description.
  ///
  /// In en, this message translates to:
  /// **'More comfortable display in the morning'**
  String get light_mode_description;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// No description provided for @upcoming_events.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcoming_events;

  /// No description provided for @no_upcoming_events.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events'**
  String get no_upcoming_events;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get see_all;

  /// No description provided for @hijri.
  ///
  /// In en, this message translates to:
  /// **'Hijri'**
  String get hijri;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @current_campaign.
  ///
  /// In en, this message translates to:
  /// **'Current Campaign'**
  String get current_campaign;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @donate_now.
  ///
  /// In en, this message translates to:
  /// **'Donate Now'**
  String get donate_now;

  /// No description provided for @calender.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calender;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @lecture.
  ///
  /// In en, this message translates to:
  /// **'Lecture'**
  String get lecture;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @announcement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get announcement;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @donations.
  ///
  /// In en, this message translates to:
  /// **'Donations'**
  String get donations;

  /// No description provided for @classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @q_and_a.
  ///
  /// In en, this message translates to:
  /// **'Q&A'**
  String get q_and_a;

  /// No description provided for @borrow_items.
  ///
  /// In en, this message translates to:
  /// **'Borrow Items'**
  String get borrow_items;

  /// No description provided for @available_items.
  ///
  /// In en, this message translates to:
  /// **'Available Items'**
  String get available_items;

  /// No description provided for @borrowed_items.
  ///
  /// In en, this message translates to:
  /// **'Borrowed Items'**
  String get borrowed_items;

  /// No description provided for @borrow.
  ///
  /// In en, this message translates to:
  /// **'Borrow'**
  String get borrow;

  /// No description provided for @return_item.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get return_item;

  /// No description provided for @current_time.
  ///
  /// In en, this message translates to:
  /// **'Current Time'**
  String get current_time;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @notif_on.
  ///
  /// In en, this message translates to:
  /// **'Notifications On'**
  String get notif_on;

  /// No description provided for @notif_off.
  ///
  /// In en, this message translates to:
  /// **'Notifications Off'**
  String get notif_off;

  /// No description provided for @quran_explanation.
  ///
  /// In en, this message translates to:
  /// **'Quran Explanation'**
  String get quran_explanation;

  /// No description provided for @continue_reading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continue_reading;

  /// No description provided for @delete_bookmark.
  ///
  /// In en, this message translates to:
  /// **'Delete Bookmark'**
  String get delete_bookmark;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @repreat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repreat;

  /// No description provided for @surah.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get surah;

  /// No description provided for @play_all.
  ///
  /// In en, this message translates to:
  /// **'Play All'**
  String get play_all;

  /// No description provided for @last_read.
  ///
  /// In en, this message translates to:
  /// **'Last Read'**
  String get last_read;

  /// No description provided for @success_last_read.
  ///
  /// In en, this message translates to:
  /// **'Successfully marked this verse as last read'**
  String get success_last_read;

  /// No description provided for @success_delete_bookmark.
  ///
  /// In en, this message translates to:
  /// **'Successfully deleted bookmark'**
  String get success_delete_bookmark;

  /// No description provided for @previous_surah.
  ///
  /// In en, this message translates to:
  /// **'Previous Surah'**
  String get previous_surah;

  /// No description provided for @next_surah.
  ///
  /// In en, this message translates to:
  /// **'Next Surah'**
  String get next_surah;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;

  /// No description provided for @surah_number.
  ///
  /// In en, this message translates to:
  /// **'Surah Number'**
  String get surah_number;

  /// No description provided for @ayah.
  ///
  /// In en, this message translates to:
  /// **'Verse'**
  String get ayah;

  /// No description provided for @success_copy_ayah.
  ///
  /// In en, this message translates to:
  /// **'Successfully copied verse to clipboard'**
  String get success_copy_ayah;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @save_last_read.
  ///
  /// In en, this message translates to:
  /// **'Save Last Read Successful'**
  String get save_last_read;

  /// No description provided for @weekly_short.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekly_short;

  /// No description provided for @monthly_short.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get monthly_short;

  /// No description provided for @yearly_short.
  ///
  /// In en, this message translates to:
  /// **'Y'**
  String get yearly_short;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get totalExpense;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @recentTransaction.
  ///
  /// In en, this message translates to:
  /// **'Recent Transaction'**
  String get recentTransaction;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @financeReport.
  ///
  /// In en, this message translates to:
  /// **'Finance Report'**
  String get financeReport;

  /// No description provided for @incomeVsExpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expense'**
  String get incomeVsExpense;

  /// No description provided for @no_transactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get no_transactions;

  /// No description provided for @latest_activity.
  ///
  /// In en, this message translates to:
  /// **'Latest Activity'**
  String get latest_activity;

  /// No description provided for @alarm_set.
  ///
  /// In en, this message translates to:
  /// **'Alarm set'**
  String get alarm_set;

  /// No description provided for @refresh_location.
  ///
  /// In en, this message translates to:
  /// **'Refresh Location'**
  String get refresh_location;

  /// No description provided for @select_date.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get select_date;

  /// No description provided for @time_pass.
  ///
  /// In en, this message translates to:
  /// **'time_passed'**
  String get time_pass;

  /// No description provided for @its_time_for.
  ///
  /// In en, this message translates to:
  /// **'It\'s time for'**
  String get its_time_for;

  /// No description provided for @prayer_at.
  ///
  /// In en, this message translates to:
  /// **'Prayer at'**
  String get prayer_at;

  /// No description provided for @set_alarm_for.
  ///
  /// In en, this message translates to:
  /// **'Set alarm for'**
  String get set_alarm_for;

  /// No description provided for @manage_alarm_for.
  ///
  /// In en, this message translates to:
  /// **'Manage alarm for'**
  String get manage_alarm_for;

  /// No description provided for @alarm_error.
  ///
  /// In en, this message translates to:
  /// **'Alarm Error'**
  String get alarm_error;

  /// No description provided for @alarm_already_set.
  ///
  /// In en, this message translates to:
  /// **'Alarm already set for'**
  String get alarm_already_set;

  /// No description provided for @cancel_next_prayer_alarm.
  ///
  /// In en, this message translates to:
  /// **'Cancel next prayer alarm'**
  String get cancel_next_prayer_alarm;

  /// No description provided for @set_next_prayer_alarm.
  ///
  /// In en, this message translates to:
  /// **'Set next prayer alarm'**
  String get set_next_prayer_alarm;

  /// No description provided for @would_you_like_to_set_alarm.
  ///
  /// In en, this message translates to:
  /// **'Would you like to set alarm for'**
  String get would_you_like_to_set_alarm;

  /// No description provided for @would_you_like_to_cancel_alarm.
  ///
  /// In en, this message translates to:
  /// **'Would you like to cancel this alarm?'**
  String get would_you_like_to_cancel_alarm;

  /// No description provided for @cancel_error.
  ///
  /// In en, this message translates to:
  /// **'Cancel Error'**
  String get cancel_error;

  /// No description provided for @prayer_time.
  ///
  /// In en, this message translates to:
  /// **'Prayer Time'**
  String get prayer_time;

  /// No description provided for @alarm_canceled.
  ///
  /// In en, this message translates to:
  /// **'Alarm Canceled'**
  String get alarm_canceled;

  /// No description provided for @prayer_time_for.
  ///
  /// In en, this message translates to:
  /// **'Prayer Time For'**
  String get prayer_time_for;

  /// No description provided for @loc_per_denied.
  ///
  /// In en, this message translates to:
  /// **'location permission denied'**
  String get loc_per_denied;

  /// No description provided for @loc_per_denied_2.
  ///
  /// In en, this message translates to:
  /// **'location permission denied, please enable it'**
  String get loc_per_denied_2;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @enter_email_for_password_reset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link'**
  String get enter_email_for_password_reset;

  /// No description provided for @invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalid_email;

  /// No description provided for @empty_email.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get empty_email;

  /// No description provided for @invalid_password.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid password'**
  String get invalid_password;

  /// No description provided for @empty_password.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get empty_password;

  /// No description provided for @password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get password_too_short;

  /// No description provided for @invalid_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid password confirmation'**
  String get invalid_confirm_password;

  /// No description provided for @empty_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation cannot be empty'**
  String get empty_confirm_password;

  /// No description provided for @password_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get password_not_match;

  /// No description provided for @invalid_username.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid username'**
  String get invalid_username;

  /// No description provided for @username_too_short.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get username_too_short;

  /// No description provided for @username_too_long.
  ///
  /// In en, this message translates to:
  /// **'Username must be at most 20 characters'**
  String get username_too_long;

  /// No description provided for @empty_username.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty'**
  String get empty_username;

  /// No description provided for @have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get have_account;

  /// No description provided for @no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get no_account;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgot_password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fill_email.
  ///
  /// In en, this message translates to:
  /// **'Fill your email'**
  String get fill_email;

  /// No description provided for @fill_name.
  ///
  /// In en, this message translates to:
  /// **'Fill your name'**
  String get fill_name;

  /// No description provided for @fill_password.
  ///
  /// In en, this message translates to:
  /// **'Fill your password'**
  String get fill_password;

  /// No description provided for @fill_username.
  ///
  /// In en, this message translates to:
  /// **'Fill your username'**
  String get fill_username;

  /// No description provided for @fill_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Fill your confirm password'**
  String get fill_confirm_password;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @sign_up_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Sign up to continue'**
  String get sign_up_to_continue;

  /// No description provided for @password_must_contain.
  ///
  /// In en, this message translates to:
  /// **'Password must contain'**
  String get password_must_contain;

  /// No description provided for @sign_in_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get sign_in_to_continue;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get sign_up;

  /// No description provided for @send_link_reset_password.
  ///
  /// In en, this message translates to:
  /// **'Send Password Reset Link'**
  String get send_link_reset_password;

  /// No description provided for @next_prayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get next_prayer;

  /// No description provided for @oops_something_went_wrong.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oops_something_went_wrong;

  /// No description provided for @app_encountered_error.
  ///
  /// In en, this message translates to:
  /// **'The app encountered an unexpected error. We\'re working on fixing it.'**
  String get app_encountered_error;

  /// No description provided for @please_restart_app.
  ///
  /// In en, this message translates to:
  /// **'Please try restarting the app'**
  String get please_restart_app;

  /// No description provided for @we_apologize_for_inconvenience.
  ///
  /// In en, this message translates to:
  /// **'We apologize for the inconvenience'**
  String get we_apologize_for_inconvenience;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @set_alarm.
  ///
  /// In en, this message translates to:
  /// **'Set Alarm'**
  String get set_alarm;

  /// No description provided for @cancel_alarm.
  ///
  /// In en, this message translates to:
  /// **'Cancel Alarm'**
  String get cancel_alarm;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @go_to_home.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get go_to_home;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

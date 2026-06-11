/// Lightweight in-app localization for SafeWear (en / fr / ar).
/// Usage: `tr(lang, 'home')` where lang is the user's language code.
library;

/// Active language code. Set at the app root (and during onboarding) before
/// the tree builds; widgets read it via [t].
String currentLang = 'en';

/// Translate [key] using the active language.
String t(String key) => tr(currentLang, key);

String tr(String lang, String key) {
  final entry = _strings[key];
  if (entry == null) return key;
  return entry[lang] ?? entry['en'] ?? key;
}

bool isRtl(String lang) => lang == 'ar';

const Map<String, Map<String, String>> _strings = {
  // ── Bottom navigation ──
  'home': {'en': 'Home', 'fr': 'Accueil', 'ar': 'الرئيسية'},
  'alerts': {'en': 'Alerts', 'fr': 'Alertes', 'ar': 'التنبيهات'},
  'device': {'en': 'Device', 'fr': 'Appareil', 'ar': 'الجهاز'},
  'profile': {'en': 'Profile', 'fr': 'Profil', 'ar': 'الملف الشخصي'},

  // ── Home tab ──
  'goodMorning': {'en': 'Good morning', 'fr': 'Bonjour', 'ar': 'صباح الخير'},
  'goodAfternoon': {
    'en': 'Good afternoon',
    'fr': 'Bon après-midi',
    'ar': 'نهارك سعيد'
  },
  'goodEvening': {'en': 'Good evening', 'fr': 'Bonsoir', 'ar': 'مساء الخير'},
  'protected': {'en': 'Protected', 'fr': 'Protégée', 'ar': 'في أمان'},
  'contacts': {'en': 'Contacts', 'fr': 'Contacts', 'ar': 'جهات الاتصال'},
  'safeDays': {'en': 'Safe Days', 'fr': 'Jours sûrs', 'ar': 'أيام آمنة'},
  'safeZones': {'en': 'Safe Zones', 'fr': 'Zones sûres', 'ar': 'مناطق آمنة'},
  'emergencySos': {
    'en': 'EMERGENCY SOS',
    'fr': "SOS D'URGENCE",
    'ar': 'استغاثة طوارئ'
  },
  'sosHint': {
    'en': 'Tap to start the 20-second countdown',
    'fr': 'Appuyez pour lancer le compte à rebours de 20 s',
    'ar': 'اضغط لبدء العد التنازلي (٢٠ ثانية)'
  },
  'modeContacts': {
    'en': 'Mode: Notify Contacts',
    'fr': 'Mode : Prévenir les contacts',
    'ar': 'الوضع: إخطار جهات الاتصال'
  },
  'modePolice': {
    'en': 'Mode: Contacts + Police',
    'fr': 'Mode : Contacts + Police',
    'ar': 'الوضع: جهات الاتصال + الشرطة'
  },
  'modeMax': {
    'en': 'Mode: Maximum Response',
    'fr': 'Mode : Réponse maximale',
    'ar': 'الوضع: استجابة قصوى'
  },
  'quickActions': {
    'en': 'Quick Actions',
    'fr': 'Actions rapides',
    'ar': 'إجراءات سريعة'
  },
  'riskMap': {
    'en': 'Risk Map',
    'fr': 'Carte des risques',
    'ar': 'خريطة المخاطر'
  },
  'medical': {'en': 'Medical', 'fr': 'Médical', 'ar': 'الملف الطبي'},
  'fakeCall': {'en': 'Fake Call', 'fr': 'Faux appel', 'ar': 'مكالمة وهمية'},
  'fakeCallSub': {
    'en': 'Get a realistic incoming call — a discreet way out.',
    'fr': 'Recevez un faux appel réaliste — une sortie discrète.',
    'ar': 'مكالمة واردة واقعية — مخرج سري من المواقف الخطرة.'
  },
  'ringNow': {'en': 'Ring Now', 'fr': 'Sonner', 'ar': 'رنّ الآن'},
  'recentActivity': {
    'en': 'Recent Activity',
    'fr': 'Activité récente',
    'ar': 'النشاط الأخير'
  },
  'viewAll': {'en': 'View All', 'fr': 'Tout voir', 'ar': 'عرض الكل'},
  'currentLocation': {
    'en': 'Current Location',
    'fr': 'Position actuelle',
    'ar': 'الموقع الحالي'
  },

  // ── Alerts tab ──
  'emergencyHub': {
    'en': 'Emergency Hub',
    'fr': "Centre d'urgence",
    'ar': 'مركز الطوارئ'
  },
  'hubSub': {
    'en': 'One tap alerts your entire network simultaneously.',
    'fr': 'Un seul geste alerte tout votre réseau en même temps.',
    'ar': 'لمسة واحدة تُنبّه شبكتك بالكامل في آنٍ واحد.'
  },
  'gpsActive': {'en': 'GPS active', 'fr': 'GPS actif', 'ar': 'GPS نشط'},
  'smartAlerts': {
    'en': 'Smart Alerts',
    'fr': 'Alertes intelligentes',
    'ar': 'تنبيهات ذكية'
  },
  'alertHistory': {
    'en': 'Alert History',
    'fr': 'Historique des alertes',
    'ar': 'سجل التنبيهات'
  },
  'trustedContacts': {
    'en': 'Trusted Contacts',
    'fr': 'Contacts de confiance',
    'ar': 'جهات الاتصال الموثوقة'
  },
  'manage': {'en': 'Manage', 'fr': 'Gérer', 'ar': 'إدارة'},

  // ── Device tab ──
  'myDevice': {'en': 'My Device', 'fr': 'Mon appareil', 'ar': 'جهازي'},
  'liveSensorData': {
    'en': 'Live Sensor Data',
    'fr': 'Capteurs en direct',
    'ar': 'بيانات المستشعرات المباشرة'
  },
  'heartRate': {
    'en': 'Heart Rate',
    'fr': 'Rythme cardiaque',
    'ar': 'نبض القلب'
  },
  'stepsToday': {
    'en': 'Steps Today',
    'fr': 'Pas aujourd’hui',
    'ar': 'خطوات اليوم'
  },
  'deviceActions': {
    'en': 'Device Actions',
    'fr': "Actions de l'appareil",
    'ar': 'إجراءات الجهاز'
  },

  // ── Profile tab ──
  'account': {'en': 'Account', 'fr': 'Compte', 'ar': 'الحساب'},
  'safety': {'en': 'Safety', 'fr': 'Sécurité', 'ar': 'الأمان'},
  'app': {'en': 'App', 'fr': 'Application', 'ar': 'التطبيق'},
  'subscription': {
    'en': 'Subscription',
    'fr': 'Abonnement',
    'ar': 'الاشتراك'
  },
  'editProfile': {
    'en': 'Edit Profile',
    'fr': 'Modifier le profil',
    'ar': 'تعديل الملف'
  },
  'language': {'en': 'Language', 'fr': 'Langue', 'ar': 'اللغة'},
  'medicalProfile': {
    'en': 'Medical Profile',
    'fr': 'Profil médical',
    'ar': 'الملف الطبي'
  },
  'emergencyMode': {
    'en': 'Emergency Mode',
    'fr': "Mode d'urgence",
    'ar': 'وضع الطوارئ'
  },
  'notifications': {
    'en': 'Notifications',
    'fr': 'Notifications',
    'ar': 'الإشعارات'
  },
  'privacySecurity': {
    'en': 'Privacy & Security',
    'fr': 'Confidentialité et sécurité',
    'ar': 'الخصوصية والأمان'
  },
  'helpSupport': {
    'en': 'Help & Support',
    'fr': 'Aide et assistance',
    'ar': 'المساعدة والدعم'
  },
  'upgradeToPro': {
    'en': 'Upgrade to Pro',
    'fr': 'Passer à Pro',
    'ar': 'الترقية إلى برو'
  },
  'signOut': {
    'en': 'Sign Out',
    'fr': 'Se déconnecter',
    'ar': 'تسجيل الخروج'
  },
  'freePlan': {
    'en': 'Free Plan',
    'fr': 'Forfait gratuit',
    'ar': 'الخطة المجانية'
  },
  'proPlan': {'en': 'Pro Plan', 'fr': 'Forfait Pro', 'ar': 'خطة برو'},
  'upgrade': {'en': 'Upgrade', 'fr': 'Améliorer', 'ar': 'ترقية'},

  // ── Onboarding ──
  'welcome': {
    'en': 'Welcome to SafeWear',
    'fr': 'Bienvenue sur SafeWear',
    'ar': 'مرحبًا بك في SafeWear'
  },
  'chooseLanguage': {
    'en': 'Choose your language',
    'fr': 'Choisissez votre langue',
    'ar': 'اختر لغتك'
  },
  'continue_': {'en': 'Continue', 'fr': 'Continuer', 'ar': 'متابعة'},
  'yourProfile': {
    'en': 'Your Profile',
    'fr': 'Votre profil',
    'ar': 'ملفك الشخصي'
  },
  'profileSub': {
    'en': 'Your name and phone number will be shared with contacts during alerts.',
    'fr': 'Votre nom et numéro seront partagés avec vos contacts pendant les alertes.',
    'ar': 'سيُشارك اسمك ورقم هاتفك مع جهات اتصالك أثناء التنبيهات.'
  },
  'fullName': {'en': 'Full Name', 'fr': 'Nom complet', 'ar': 'الاسم الكامل'},
  'phoneNumber': {
    'en': 'Phone Number',
    'fr': 'Numéro de téléphone',
    'ar': 'رقم الهاتف'
  },
  'contactsSub': {
    'en': 'Up to 5 people who will be alerted instantly in an emergency.',
    'fr': "Jusqu'à 5 personnes alertées instantanément en cas d'urgence.",
    'ar': 'حتى ٥ أشخاص يتم تنبيههم فورًا في حالات الطوارئ.'
  },
  'addContact': {
    'en': 'Add Contact',
    'fr': 'Ajouter un contact',
    'ar': 'إضافة جهة اتصال'
  },
  'skipForNow': {'en': 'Skip for now', 'fr': 'Passer', 'ar': 'تخطي الآن'},
  'silentAlertMode': {
    'en': 'Silent Alert Mode',
    'fr': "Mode d'alerte silencieuse",
    'ar': 'وضع التنبيه الصامت'
  },
  'silentModeSub': {
    'en': 'When you cannot speak or act, which response should fire automatically?',
    'fr': 'Si vous ne pouvez ni parler ni agir, quelle réponse se déclenche automatiquement ?',
    'ar': 'عندما لا تستطيعين التحدث أو التصرف، أي استجابة تنطلق تلقائيًا؟'
  },
  'confirmContinue': {
    'en': 'Confirm & Continue',
    'fr': 'Confirmer et continuer',
    'ar': 'تأكيد ومتابعة'
  },
  'safeZonesSub': {
    'en': 'Set locations (home, school, work) where you are expected to be safe.',
    'fr': 'Définissez les lieux (maison, école, travail) où vous êtes en sécurité.',
    'ar': 'حدّدي الأماكن (المنزل، المدرسة، العمل) التي تكونين فيها بأمان.'
  },
  'getStarted': {'en': 'Get Started', 'fr': 'Commencer', 'ar': 'ابدأ الآن'},

  // ── Emergency screen ──
  'alertIn': {'en': 'ALERT IN', 'fr': 'ALERTE DANS', 'ar': 'التنبيه خلال'},
  'imSafeCancel': {
    'en': "I'M SAFE — CANCEL",
    'fr': 'JE SUIS EN SÉCURITÉ — ANNULER',
    'ar': 'أنا بأمان — إلغاء'
  },
  'alertSent': {
    'en': 'ALERT SENT',
    'fr': 'ALERTE ENVOYÉE',
    'ar': 'تم إرسال التنبيه'
  },
  'imSafeNow': {
    'en': "I'M SAFE NOW",
    'fr': 'JE SUIS EN SÉCURITÉ',
    'ar': 'أنا بأمان الآن'
  },
  'liveStreaming': {
    'en': 'Live location & audio streaming active',
    'fr': 'Position en direct et audio actifs',
    'ar': 'بث الموقع المباشر والصوت نشط'
  },
  'notifyingContacts': {
    'en': 'Notifying your contacts',
    'fr': 'Notification de vos contacts',
    'ar': 'جارٍ إخطار جهات اتصالك'
  },
  'notifyingPolice': {
    'en': 'Notifying contacts + police',
    'fr': 'Notification contacts + police',
    'ar': 'إخطار جهات الاتصال + الشرطة'
  },
  'notifyingMax': {
    'en': 'Maximum response — all services',
    'fr': 'Réponse maximale — tous les services',
    'ar': 'استجابة قصوى — جميع الخدمات'
  },
};

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
  'unusualActivity': {
    'en': 'Unusual Activity',
    'fr': 'Activité inhabituelle',
    'ar': 'نشاط غير معتاد'
  },
  'unusualActivitySub': {
    'en': 'Alert when vitals spike unexpectedly',
    'fr': 'Alerter si les signes vitaux grimpent soudainement',
    'ar': 'تنبيه عند ارتفاع المؤشرات الحيوية فجأة'
  },
  'geofenceExit': {
    'en': 'Geofence Exit',
    'fr': 'Sortie de zone',
    'ar': 'مغادرة المنطقة الآمنة'
  },
  'geofenceExitSub': {
    'en': 'Alert when leaving safe zones',
    'fr': 'Alerter en quittant les zones sûres',
    'ar': 'تنبيه عند مغادرة المناطق الآمنة'
  },
  'deviceDisconnected': {
    'en': 'Device Disconnected',
    'fr': 'Appareil déconnecté',
    'ar': 'انقطاع اتصال الجهاز'
  },
  'deviceDisconnectedSub': {
    'en': 'Alert when watch loses connection',
    'fr': 'Alerter si la montre perd la connexion',
    'ar': 'تنبيه عند فقدان الساعة للاتصال'
  },
  'voiceTrigger': {
    'en': 'Voice Trigger',
    'fr': 'Déclencheur vocal',
    'ar': 'التفعيل الصوتي'
  },
  'voiceTriggerSub': {
    'en': '"SafeWear contacts" activates silent alert',
    'fr': '« SafeWear contacts » déclenche une alerte silencieuse',
    'ar': '«SafeWear contacts» تُفعّل تنبيهًا صامتًا'
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
  'connected': {'en': 'Connected', 'fr': 'Connecté', 'ar': 'متصل'},
  'skinTemp': {
    'en': 'Skin Temp',
    'fr': 'Temp. cutanée',
    'ar': 'حرارة الجلد'
  },
  'normalRange': {
    'en': 'Normal range',
    'fr': 'Plage normale',
    'ar': 'معدل طبيعي'
  },
  'normal': {'en': 'Normal', 'fr': 'Normal', 'ar': 'طبيعي'},
  'excellent': {'en': 'Excellent', 'fr': 'Excellent', 'ar': 'ممتاز'},
  'ofDailyGoal': {
    'en': '32% of daily goal',
    'fr': '32 % de l’objectif',
    'ar': '٣٢٪ من الهدف اليومي'
  },
  'scanDevices': {
    'en': 'Scan for Devices',
    'fr': 'Rechercher des appareils',
    'ar': 'البحث عن الأجهزة'
  },
  'scanDevicesSub': {
    'en': 'Find SafeWear devices nearby',
    'fr': 'Trouver les appareils SafeWear à proximité',
    'ar': 'العثور على أجهزة SafeWear القريبة'
  },
  'firmwareUpdate': {
    'en': 'Firmware Update',
    'fr': 'Mise à jour du firmware',
    'ar': 'تحديث النظام'
  },
  'upToDate': {
    'en': 'v2.1.0 — Up to date',
    'fr': 'v2.1.0 — À jour',
    'ar': 'v2.1.0 — محدّث'
  },
  'latest': {'en': 'Latest', 'fr': 'À jour', 'ar': 'الأحدث'},
  'testHaptics': {
    'en': 'Test Haptics',
    'fr': 'Tester les vibrations',
    'ar': 'اختبار الاهتزاز'
  },
  'testHapticsSub': {
    'en': 'Verify alert vibration patterns',
    'fr': "Vérifier les vibrations d'alerte",
    'ar': 'التحقق من أنماط اهتزاز التنبيه'
  },
  'unpairDevice': {
    'en': 'Unpair Device',
    'fr': "Dissocier l'appareil",
    'ar': 'إلغاء اقتران الجهاز'
  },
  'unpairDeviceSub': {
    'en': 'Remove this device from your account',
    'fr': 'Retirer cet appareil de votre compte',
    'ar': 'إزالة هذا الجهاز من حسابك'
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
  'darkMode': {'en': 'Dark Mode', 'fr': 'Mode sombre', 'ar': 'الوضع الداكن'},
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

  // ── Zone editor ──
  'newSafeZone': {
    'en': 'New Safe Zone',
    'fr': 'Nouvelle zone sûre',
    'ar': 'منطقة آمنة جديدة'
  },
  'zoneName': {
    'en': 'Zone name (e.g. Home, School)',
    'fr': 'Nom de la zone (ex. Maison, École)',
    'ar': 'اسم المنطقة (مثل المنزل، المدرسة)'
  },
  'circleMode': {'en': 'Circle', 'fr': 'Cercle', 'ar': 'دائرة'},
  'drawMode': {'en': 'Draw', 'fr': 'Dessiner', 'ar': 'رسم'},
  'circleHint': {
    'en': 'Drag on the map to position the zone, use the slider for size.',
    'fr': 'Faites glisser sur la carte pour placer la zone, ajustez la taille avec le curseur.',
    'ar': 'اسحبي على الخريطة لتحديد موقع المنطقة، واستخدمي الشريط لتغيير الحجم.'
  },
  'drawHint': {
    'en': 'Trace the zone outline with your finger.',
    'fr': 'Tracez le contour de la zone avec votre doigt.',
    'ar': 'ارسمي حدود المنطقة بإصبعك.'
  },
  'clearDrawing': {
    'en': 'Clear drawing',
    'fr': 'Effacer le dessin',
    'ar': 'مسح الرسم'
  },
  'saveZone': {
    'en': 'Save Zone',
    'fr': 'Enregistrer la zone',
    'ar': 'حفظ المنطقة'
  },
  'zoneNameRequired': {
    'en': 'Give the zone a name first',
    'fr': "Donnez d'abord un nom à la zone",
    'ar': 'أدخلي اسم المنطقة أولًا'
  },
  'drawZoneFirst': {
    'en': 'Draw the zone outline on the map first',
    'fr': "Dessinez d'abord le contour de la zone",
    'ar': 'ارسمي حدود المنطقة على الخريطة أولًا'
  },
  'drawnZone': {
    'en': 'Hand-drawn zone',
    'fr': 'Zone dessinée',
    'ar': 'منطقة مرسومة يدويًا'
  },

  // ── Watch demo ──
  'watchDemo': {
    'en': 'Watch Demo',
    'fr': 'Démo de la montre',
    'ar': 'عرض الساعة'
  },
  'watchDemoHint': {
    'en': 'Simulate sensor events to see how the watch detects danger and hands off to the phone.',
    'fr': 'Simulez des événements capteurs pour voir comment la montre détecte le danger et alerte le téléphone.',
    'ar': 'حاكي أحداث المستشعرات لترى كيف تكتشف الساعة الخطر وتسلّم الإنذار إلى الهاتف.'
  },
  'simulateFall': {
    'en': 'Simulate Fall',
    'fr': 'Simuler une chute',
    'ar': 'محاكاة سقوط'
  },
  'spikeHr': {
    'en': 'Spike Heart Rate',
    'fr': 'Accélérer le pouls',
    'ar': 'رفع نبض القلب'
  },
  'calmHr': {
    'en': 'Calm Heart Rate',
    'fr': 'Calmer le pouls',
    'ar': 'تهدئة النبض'
  },
  'fallDetected': {
    'en': 'Fall detected\nAre you OK?',
    'fr': 'Chute détectée\nÇa va ?',
    'ar': 'تم رصد سقوط\nهل أنتِ بخير؟'
  },
  'imOk': {'en': "I'M OK", 'fr': 'ÇA VA', 'ar': 'أنا بخير'},
  'phoneTakingOver': {
    'en': 'Phone is dispatching the alert…',
    'fr': "Le téléphone envoie l'alerte…",
    'ar': 'الهاتف يرسل التنبيه الآن…'
  },

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

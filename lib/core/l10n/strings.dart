class S {
  final bool isArabic;
  const S(this.isArabic);

  // App
  String get appName => isArabic ? 'وناسة' : 'Wannas';
  String get appTagline => isArabic ? 'أسئلة حقيقية. محادثات حقيقية.' : 'Real talk. Real fun.';
  String get whoIsPlaying => isArabic ? 'من يلعب الليلة؟' : "Who's playing tonight?";
  String get personaliseExp => isArabic ? 'سنخصّص التجربة لك.' : "We'll personalise the experience for you.";
  String get chooseMode => isArabic ? 'اختر وضع اللعب' : 'Choose a Mode';
  String get languageToggle => isArabic ? 'English' : 'العربية';

  // Mode names
  String get dateMode => isArabic ? 'وضع المواعد' : 'Date Mode';
  String get dateModeTagline =>
      isArabic ? 'اكتشفوا بعضكم بعمق أكبر' : 'Discover each other deeper';

  String get spiceMode => isArabic ? 'الأزواج والمتزوجون' : 'Couples / Married';
  String get spiceModeTagline =>
      isArabic ? 'أشعلوا الجذوة من جديد' : 'Reignite the spark';

  String get familyMode => isArabic ? 'وقت العائلة' : 'Family Heart to Heart';
  String get familyModeTagline =>
      isArabic ? 'لحظات حقيقية مع من تحب' : 'Real moments with those you love';

  String get sportMode => isArabic ? 'وضع الأصدقاء' : 'Friends Mode';
  String get sportModeTagline =>
      isArabic ? 'أسئلة ممتعة لأي مجموعة' : 'Fun questions for any group';

  // Vibe selector (Date Mode)
  String get whatsTheVibe   => isArabic ? 'ما هو المزاج الليلة؟'         : "What's the vibe tonight?";
  String get tapOneToCont   => isArabic ? 'اضغط على أحدها للمتابعة.'     : 'Tap one to continue.';
  String get vibeCurious    => isArabic ? 'فضولي وعميق'                   : 'Curious & Deep';
  String get vibePlayful    => isArabic ? 'مرح ومغازلة'                   : 'Playful & Flirty';
  String get vibeRomantic   => isArabic ? 'رومانسي'                       : 'Romantic';
  String get vibeDeep       => isArabic ? 'أسرار عميقة'                   : 'Deep Secrets';

  // Friends Mode
  String get friendsIntroTitle  => isArabic ? 'مستعدون للحديث؟'                               : 'Ready to get everyone talking?';
  String get friendsIntroSub    => isArabic ? 'اختر من 8 فئات — كرة، موسيقى، معلومات عامة والمزيد.' : 'Choose from 8 categories — Football, Music, General Knowledge & more.';
  String get pickACategory      => isArabic ? 'اختر فئة'                                      : 'Pick a Category →';
  String get friendsModeHeader  => isArabic ? 'وضع الأصدقاء'                                  : 'FRIENDS MODE';
  String get pickCategoryTitle  => isArabic ? 'اختر فئة'                                      : 'Pick a category';
  String get pickCategorySub    => isArabic ? 'اختر موضوعاً وابدأ اللعب.'                     : 'Choose a topic and start playing.';
  String get howManyPlaying     => isArabic ? 'كم لاعباً سيلعبون؟'                            : 'How many are playing?';
  String get trackScoreSub      => isArabic ? 'سنتابع نقاط الجميع.'                           : "We'll track everyone's score.";
  String get minMaxPlayers      => isArabic ? 'الحد الأدنى 2 — الحد الأقصى 8 لاعبين'        : 'Min 2 — Max 8 players';
  String get comingSoon         => isArabic ? 'قريباً...'                                      : 'Coming soon!';

  // Friends categories
  String get catFootball    => isArabic ? 'الكرة'              : 'Football';
  String get catTV          => isArabic ? 'التلفزيون والأفلام' : 'TV & Movies';
  String get catBeauty      => isArabic ? 'الجمال'             : 'Beauty';
  String get catMusic       => isArabic ? 'الموسيقى'           : 'Music';
  String get catGaming      => isArabic ? 'الألعاب'            : 'Gaming';
  String get catWYR         => isArabic ? 'معلومات عامة'        : 'General Knowledge';
  String get catTravel      => isArabic ? 'السفر'              : 'Travel';
  String get catFood        => isArabic ? 'الأكل والشرب'       : 'Food & Drink';

  // Level select
  String get selectLevel => isArabic ? 'اختر المستوى' : 'Select a Level';
  String get selectAgeGroup => isArabic ? 'اختر الفئة العمرية' : 'Select Age Group';
  String get selectLeague => isArabic ? 'اختر الدوري' : 'Select a League';

  // Sport leagues
  String get egyptianLeague => isArabic ? 'الدوري المصري' : 'Egyptian League';
  String get egyptianLeagueDesc => isArabic ? 'الأهلي، الزمالك والنجوم المصرية' : 'Al Ahly, Zamalek & Egyptian stars';
  String get premierLeague => isArabic ? 'الدوري الإنجليزي' : 'Premier League';
  String get premierLeagueDesc => isArabic ? 'أفضل دوري في العالم' : 'The world\'s greatest league';
  String get uclLeague => isArabic ? 'دوري أبطال أوروبا' : 'UEFA Champions League';
  String get uclLeagueDesc => isArabic ? 'أشرس منافسة أوروبية' : 'Europe\'s elite competition';
  String get worldCup => isArabic ? 'كأس العالم' : 'FIFA World Cup';
  String get worldCupDesc => isArabic ? 'أعظم بطولة في التاريخ' : 'The greatest tournament on earth';
  String get free => isArabic ? 'مجاني' : 'Free';
  String get premium => isArabic ? 'مميز' : 'Premium';
  String get premiumOnly => isArabic ? 'للمشتركين فقط' : 'Premium Only';
  String get locked => isArabic ? 'مقفل' : 'Locked';

  // Date levels
  String get light => isArabic ? 'خفيف' : 'Light';
  String get lightDesc =>
      isArabic ? 'أسئلة مرحة وسهلة للبداية' : 'Fun & easy to get started';
  String get medium => isArabic ? 'متوسط' : 'Medium';
  String get mediumDesc =>
      isArabic ? 'أسئلة شخصية أعمق' : 'More personal & meaningful';
  String get deep => isArabic ? 'عميق' : 'Deep';
  String get deepDesc =>
      isArabic ? 'محادثات حقيقية ومؤثرة' : 'Real, soul-level conversations';

  // Spice levels
  String get warm => isArabic ? 'دافئ' : 'Warm';
  String get warmDesc => isArabic ? 'عاطفي وحميمي' : 'Emotional & intimate';
  String get hot => isArabic ? 'ساخن' : 'Hot';
  String get hotDesc => isArabic ? 'مغازلة وجذب' : 'Flirty & playful';
  String get onFire => isArabic ? 'مشتعل' : 'On Fire';
  String get onFireDesc =>
      isArabic ? 'تحديات جريئة ومرحة' : 'Daring & fun challenges';

  // Family age groups
  String get littleOnes => isArabic ? 'الصغار' : 'Little Ones';
  String get littleOnesDesc => isArabic ? 'من 6 إلى 9 سنوات' : 'Ages 6 – 9';
  String get tweens => isArabic ? 'الأطفال الكبار' : 'Tweens';
  String get tweensDesc => isArabic ? 'من 10 إلى 12 سنة' : 'Ages 10 – 12';
  String get teens => isArabic ? 'المراهقون' : 'Teens';
  String get teensDesc => isArabic ? 'من 13 إلى 17 سنة' : 'Ages 13 – 17';

  // Game screen
  String get tapToFlip =>
      isArabic ? 'اضغط على البطاقة للكشف عن السؤال' : 'Tap the card to reveal';
  String get next => isArabic ? 'التالي' : 'Next';
  String get finish => isArabic ? 'إنهاء' : 'Finish';
  String cardOf(int current, int total) =>
      isArabic ? 'بطاقة $current من $total' : 'Card $current of $total';

  // Paywall
  String get unlockEverything =>
      isArabic ? 'افتح كل المحتوى' : 'Unlock Everything';
  String get paywallSubtitle =>
      isArabic ? 'دفعة واحدة — للأبد' : 'One-time purchase, forever';
  String get oneTimePurchase =>
      isArabic ? '\$2.99 — افتح كل شيء' : '\$2.99 — Unlock Forever';
  String get monthlySubscription =>
      isArabic ? 'أو \$1.99 / شهرياً' : 'Or \$1.99 / month';
  String get restorePurchases =>
      isArabic ? 'استعادة المشتريات' : 'Restore Purchases';
  String get noThanks => isArabic ? 'لا شكراً' : 'No Thanks';
  String get paywallFeature1 =>
      isArabic ? 'مئات الأسئلة في جميع الأوضاع' : 'Hundreds of questions across all modes';
  String get paywallFeature2 =>
      isArabic ? 'وضع "أضف التوابل" بالكامل' : 'Full access to Spice It Up';
  String get paywallFeature3 =>
      isArabic ? 'جميع الفئات العمرية لوقت العائلة' : 'All Family Heart to Heart age groups';

  // Settings
  String get settings       => isArabic ? 'الإعدادات'              : 'Settings';
  String get gameplay       => isArabic ? 'اللعب'                  : 'Gameplay';
  String get preferences    => isArabic ? 'التفضيلات'              : 'Preferences';
  String get cardTimer      => isArabic ? 'مؤقت البطاقة'           : 'Card Timer';
  String get savedCards     => isArabic ? 'البطاقات المحفوظة'      : 'Saved Cards';
  String get switchToDark   => isArabic ? 'التحويل للوضع الليلي'   : 'Switch to Dark Mode';
  String get switchToLight  => isArabic ? 'التحويل للوضع النهاري'  : 'Switch to Light Mode';
  String get privacyPolicy  => isArabic ? 'سياسة الخصوصية'         : 'Privacy Policy';
  String get termsOfService => isArabic ? 'شروط الخدمة'            : 'Terms of Service';
  String get rateTheApp     => isArabic ? 'قيّم التطبيق'           : 'Rate the App';

  // Friends Game Settings
  String get gameSettings       => isArabic ? 'إعدادات اللعبة'               : 'Game Settings';
  String get chooseDiffAndTimer => isArabic ? 'اختر الصعوبة والوقت.'         : 'Choose your difficulty and timer.';
  String get difficultyLabel    => isArabic ? 'الصعوبة'                       : 'DIFFICULTY';
  String get easyDiff           => isArabic ? 'سهل'                           : 'Easy';
  String get easyDiffDesc       => isArabic ? 'بدون وقت · سؤال فقط'          : 'No timer · Question only';
  String get mediumDiff         => isArabic ? 'متوسط'                         : 'Medium';
  String get mediumDiffDesc     => isArabic ? 'سؤال فقط'                      : 'Question only';
  String get hardDiff           => isArabic ? 'صعب'                           : 'Hard';
  String get hardDiffDesc       => isArabic ? 'سؤال فقط · 10 ثوانٍ'          : 'Question only · 10s timer';
  String get timerPerQuestion   => isArabic ? 'الوقت لكل سؤال'               : 'TIMER PER QUESTION';

  // Friends Player Names
  String get whatsEveryonesNames => isArabic ? 'ما هي أسماء اللاعبين؟'       : "What are everyone's names?";
  String get tapNameToEdit       => isArabic ? 'اضغط على الاسم لتعديله.'     : 'Tap a name to edit it.';
  String get startGame           => isArabic ? 'ابدأ اللعبة →'                : 'Start Game →';

  // Friends In-Game / Scoring
  String get discuss          => isArabic ? 'ناقشوا!'                          : 'DISCUSS!';
  String get shareYourAnswers => isArabic ? 'شاركوا إجاباتكم وقرروا من كان الأفضل.' : 'Share your answers and decide who had the best one.';
  String get whoGotItRight    => isArabic ? 'من أصاب؟ اضغط لمنح نقطة'        : 'WHO GOT IT RIGHT? TAP TO AWARD A POINT';
  String get noOneIsRight     => isArabic ? 'لا أحد أصاب'                     : 'No one is right';
  String get nextQuestion     => isArabic ? 'السؤال التالي →'                 : 'Next Question →';
  String get pts              => isArabic ? 'ن'                                : 'pts';
  String get finalScores      => isArabic ? 'النتائج النهائية'                : 'Final Scores';
  String get playAgain        => isArabic ? 'العب مجدداً'                     : 'Play Again';
  String get sec              => isArabic ? 'ث'                                : 'sec';

  // Misc
  String get backHome => isArabic ? 'العودة للرئيسية' : 'Back to Home';
  String get upgradeNow => isArabic ? 'ترقية الآن' : 'Upgrade Now';
}

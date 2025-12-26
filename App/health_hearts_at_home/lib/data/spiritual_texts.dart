// lib/data/spiritual_texts.dart
class SpiritualTexts {
  static String getBody(int index, String lang) {
    switch (index) {
      case 1:
        return lang == 'ar' ? one : oneEn;
      case 2:
        return lang == 'ar' ? two : twoEn;
      case 3:
        return lang == 'ar' ? three : threeEn;
      case 4:
        return lang == 'ar' ? four : fourEn;
      case 5:
        return lang == 'ar' ? five : fiveEn;
      case 6:
        return lang == 'ar' ? six : sixEn;
      case 7:
        return lang == 'ar' ? seven : sevenEn;
      case 8:
        return lang == 'ar' ? eight : eightEn;
      // ... up to 8
      default:
        return '';
    }
  }

  // ====== TEXTS ======
  static const String one = '''
{الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ}
[ الرعد: 28]
...
''';

  static const String oneEn = '''
Those who believe (in the Oneness of Allah - Islamic Monotheism), 
and whose hearts find rest in the remembrance of Allah, Verily, 
in the remembrance of Allah do hearts find rest.
''';

  static const String two = '''
فَإِنَّ مَعَ الْعُسْرِ يُسْرًا * إِنَّ مَعَ الْعُسْرِ يُسْرًا
''';

  static const String twoEn = '''
So verily, with the hardship, there is relief,
Verily, with the hardship, there is relief (i.e. there is one hardship with two reliefs, so one hardship cannot overcome two reliefs).
''';

  static const String three = '''
إِذْ يَقُولُ لِصَاحِبِهِ لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا
''';

  static const String threeEn = '''
and he (SAW) said to his companion (Abu Bakr): "Be not sad (or afraid), surely Allah is with us." ''';

  static const String four = '''
{قُل لَّن يُصِيبَنَا إِلَّا مَا كَتَبَ اللَّهُ لَنَا هُوَ مَوْلَانَا ۚ وَعَلَى اللَّهِ فَلْيَتَوَكَّلِ الْمُؤْمِنُونَ} 
[ التوبة: 51]
''';

  static const String fourEn = '''
Say: "Nothing shall ever happen to us except what Allah has ordained for us. He is our Maula (Lord, Helper and Protector)." And in Allah let the believers put their trust.
''';
  static const String five = '''
{يَا أَيَّتُهَا النَّفْسُ الْمُطْمَئِنَّةُ * ارْجِعِي إِلَىٰ رَبِّكِ رَاضِيَةً مَّرْضِيَّةً * فَادْخُلِي فِي عِبَادِي * وَادْخُلِي جَنَّتِي} 
[ الفجر: 27 - 30]
''';

  static const String fiveEn = '''
[To the righteous it will be said], "O reassured soul,
Return to your Lord, well-pleased and pleasing [to Him],
And enter among My [righteous] servants
And enter My Paradise."
''';
  static const String six = '''
{وَقَالُوا الْحَمْدُ لِلَّهِ الَّذِي أَذْهَبَ عَنَّا الْحَزَنَ ۖ إِنَّ رَبَّنَا لَغَفُورٌ شَكُورٌ} 
[ فاطر: 34]
  ''';

  static const String sixEn = '''
And they will say: "All the praises and thanks be to Allah, Who has removed from us (all) grief.
Verily, our Lord is indeed OftForgiving, Most Ready to appreciate (good deeds and to recompense).
''';

  static const String seven = '''
{إِنَّهُ لَا يَيْأَسُ مِن رَّوْحِ اللَّهِ إِلَّا الْقَوْمُ الْكَافِرُونَ}
[ يوسف: 87]
''';

  static const String sevenEn = '''
Certainly no one despairs of Allah's Mercy, except the people who disbelieve.
''';

  static const String eight = '''
{وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ لِّلْمُؤْمِنِينَ ۙ وَلَا يَزِيدُ الظَّالِمِينَ إِلَّا خَسَارًا}
[ سورة الإسراء: 82]
''';

  static const String eightEn = '''
And We send down of the Qur'an that which is healing and mercy for the believers, but it does not increase the wrongdoers except in loss.
''';
}

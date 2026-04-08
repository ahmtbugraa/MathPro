#!/usr/bin/env python3
"""
Generate App Store screenshots with localized title overlays for 50 languages.
Style: Bold text at top, floating on semi-transparent gradient overlay.
Inspired by Photomath/Gauth style — benefit-oriented short phrases.
"""

import os
import textwrap
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# RTL text support
try:
    import arabic_reshaper
    from bidi.algorithm import get_display
    HAS_BIDI = True
except ImportError:
    HAS_BIDI = False
    print("WARNING: arabic_reshaper / python-bidi not installed. RTL text may render incorrectly.")

# ── Paths ──────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
FINAL_DIR = os.path.join(BASE_DIR, "final")
OUTPUT_DIR = os.path.join(BASE_DIR, "titled")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Source screenshots (1290×2796)
SCREENSHOTS = [
    "01-solve-math.jpg",
    "02-learn-step-by-step.jpg",
    "03-master-any-level.jpg",
    "04-snap-crop-solve.jpg",
    "05-review-solutions.jpg",
]

# ── Font mapping per script ────────────────────────────────────
FONTS = {
    "latin": "/Library/Fonts/SF-Pro-Display-Heavy.otf",
    "latin-bold": "/Library/Fonts/SF-Pro-Display-Bold.otf",
    "cyrillic": "/Library/Fonts/SF-Pro-Display-Heavy.otf",
    "arabic": "/System/Library/Fonts/GeezaPro.ttc",
    "hebrew": "/System/Library/Fonts/SFHebrew.ttf",
    "japanese": "/System/Library/Fonts/Hiragino Sans GB.ttc",
    "korean": "/System/Library/Fonts/AppleSDGothicNeo.ttc",
    "chinese": "/System/Library/Fonts/Hiragino Sans GB.ttc",
    "thai": "/System/Library/Fonts/Supplemental/Thonburi.ttc",
    "devanagari": "/System/Library/Fonts/Supplemental/Devanagari Sangam MN.ttc",
    "bangla": "/System/Library/Fonts/KohinoorBangla.ttc",
    "gujarati": "/System/Library/Fonts/KohinoorGujarati.ttc",
    "kannada": "/System/Library/Fonts/Supplemental/Kannada Sangam MN.ttc",
    "malayalam": "/System/Library/Fonts/Supplemental/Malayalam Sangam MN.ttc",
    "odia": "/System/Library/Fonts/Supplemental/Oriya Sangam MN.ttc",
    "punjabi": "/System/Library/Fonts/Supplemental/Gurmukhi Sangam MN.ttc",
    "tamil": "/System/Library/Fonts/Supplemental/Tamil Sangam MN.ttc",
    "telugu": "/System/Library/Fonts/KohinoorTelugu.ttc",
    "urdu": "/System/Library/Fonts/GeezaPro.ttc",
    "greek": "/Library/Fonts/SF-Pro-Display-Heavy.otf",
    "fallback": "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
}

# Script detection per locale
LOCALE_SCRIPT = {
    "en-US": "latin", "en-GB": "latin", "en-AU": "latin", "en-CA": "latin",
    "fr-FR": "latin", "fr-CA": "latin", "de-DE": "latin", "es-ES": "latin",
    "es-MX": "latin", "pt-BR": "latin", "pt-PT": "latin", "it": "latin",
    "nl-NL": "latin", "tr": "latin", "hr": "latin", "cs": "latin",
    "da": "latin", "fi": "latin", "hu": "latin", "id": "latin",
    "ms": "latin", "no": "latin", "pl": "latin", "ro": "latin",
    "sk": "latin", "sv": "latin", "vi": "latin", "ca": "latin",
    "sl-SI": "latin",
    "ja": "japanese", "ko": "korean",
    "zh-Hans": "chinese", "zh-Hant": "chinese",
    "ar-SA": "arabic", "he": "hebrew", "ur-PK": "urdu",
    "ru": "cyrillic", "uk": "cyrillic",
    "el": "greek", "th": "thai",
    "hi": "devanagari", "mr-IN": "devanagari",
    "bn-BD": "bangla", "gu-IN": "gujarati", "kn-IN": "kannada",
    "ml-IN": "malayalam", "or-IN": "odia", "pa-IN": "punjabi",
    "ta-IN": "tamil", "te-IN": "telugu",
}

# RTL languages
RTL_LOCALES = {"ar-SA", "he", "ur-PK"}

# ══════════════════════════════════════════════════════════════
# 50 LANGUAGES × 5 SCREENSHOT TITLES
# Style: Short, benefit-oriented, Title Case (per Symbolab/Gauth style)
# ══════════════════════════════════════════════════════════════

TITLES = {
    "en-US": [
        "Snap a Photo,\nGet the Answer",
        "AI Step-by-Step\nExplanations",
        "From Elementary\nto University",
        "Crop Any\nMath Problem",
        "Track All\nYour Solutions",
    ],
    "en-GB": [
        "Snap a Photo,\nGet the Answer",
        "AI Step-by-Step\nExplanations",
        "From Primary\nto University",
        "Crop Any\nMaths Problem",
        "Track All\nYour Solutions",
    ],
    "en-AU": [
        "Snap a Photo,\nGet the Answer",
        "AI Step-by-Step\nExplanations",
        "From Primary\nto University",
        "Crop Any\nMaths Problem",
        "Track All\nYour Solutions",
    ],
    "en-CA": [
        "Snap a Photo,\nGet the Answer",
        "AI Step-by-Step\nExplanations",
        "From Elementary\nto University",
        "Crop Any\nMath Problem",
        "Track All\nYour Solutions",
    ],
    "tr": [
        "Fotoğraf Çek,\nCevabı Al",
        "AI ile Adım Adım\nÇözümler",
        "İlkokuldan\nÜniversiteye",
        "Problemi Kırp\nve Çöz",
        "Tüm Çözümlerini\nTakip Et",
    ],
    "de-DE": [
        "Foto Machen,\nAntwort Erhalten",
        "KI Schritt-für-Schritt\nErklärungen",
        "Von Grundschule\nbis Universität",
        "Aufgabe Zuschneiden\nund Lösen",
        "Alle Lösungen\nIm Überblick",
    ],
    "fr-FR": [
        "Prenez une Photo,\nObtenez la Réponse",
        "Explications IA\nÉtape par Étape",
        "Du Collège\nà l'Université",
        "Recadrez le\nProblème de Maths",
        "Suivez Toutes\nVos Solutions",
    ],
    "fr-CA": [
        "Prenez une Photo,\nObtenez la Réponse",
        "Explications IA\nÉtape par Étape",
        "Du Secondaire\nà l'Université",
        "Recadrez le\nProblème de Maths",
        "Suivez Toutes\nVos Solutions",
    ],
    "es-ES": [
        "Haz una Foto,\nObtén la Respuesta",
        "Explicaciones IA\nPaso a Paso",
        "De Primaria\na la Universidad",
        "Recorta Cualquier\nProblema de Mates",
        "Revisa Todas\nTus Soluciones",
    ],
    "es-MX": [
        "Toma una Foto,\nObtén la Respuesta",
        "Explicaciones IA\nPaso a Paso",
        "De la Prepa\na la Universidad",
        "Recorta Cualquier\nProblema de Mates",
        "Revisa Todas\nTus Soluciones",
    ],
    "pt-BR": [
        "Tire uma Foto,\nReceba a Resposta",
        "Explicações IA\nPasso a Passo",
        "Do Ensino Médio\nà Universidade",
        "Recorte Qualquer\nProblema de Matemática",
        "Acompanhe Todas\nas Suas Soluções",
    ],
    "pt-PT": [
        "Tire uma Foto,\nReceba a Resposta",
        "Explicações IA\nPasso a Passo",
        "Do Secundário\nà Universidade",
        "Recorte Qualquer\nProblema de Matemática",
        "Acompanhe Todas\nas Suas Soluções",
    ],
    "it": [
        "Scatta una Foto,\nOttieni la Risposta",
        "Spiegazioni IA\nPasso Dopo Passo",
        "Dalla Scuola\nall'Università",
        "Ritaglia Qualsiasi\nProblema di Matematica",
        "Controlla Tutte\nle Tue Soluzioni",
    ],
    "nl-NL": [
        "Maak een Foto,\nKrijg het Antwoord",
        "AI Stap-voor-Stap\nUitleg",
        "Van Basisschool\ntot Universiteit",
        "Snijd Elk\nWiskundeprobleem Bij",
        "Bekijk Al Je\nOplossingen",
    ],
    "ja": [
        "写真を撮って\n答えをゲット",
        "AIがステップごとに\n解説",
        "小学校から\n大学まで対応",
        "問題を切り取って\n解決",
        "すべての解答を\n記録・管理",
    ],
    "ko": [
        "사진을 찍으면\n답이 나온다",
        "AI 단계별\n풀이 설명",
        "초등학교부터\n대학교까지",
        "문제를 잘라서\n바로 풀기",
        "모든 풀이를\n한눈에 관리",
    ],
    "zh-Hans": [
        "拍照即得\n答案",
        "AI 分步\n详细解答",
        "小学到大学\n全面覆盖",
        "裁剪任意\n数学题目",
        "追踪所有\n解题记录",
    ],
    "zh-Hant": [
        "拍照即得\n答案",
        "AI 分步\n詳細解答",
        "國小到大學\n全面涵蓋",
        "裁剪任意\n數學題目",
        "追蹤所有\n解題記錄",
    ],
    "ar-SA": [
        "صوّر المسألة\nواحصل على الحل",
        "شرح بالذكاء\nالاصطناعي خطوة بخطوة",
        "من الابتدائية\nإلى الجامعة",
        "قص أي مسألة\nرياضيات",
        "تابع جميع\nحلولك",
    ],
    "ru": [
        "Сфотографируй\nи Получи Ответ",
        "ИИ Пошаговые\nОбъяснения",
        "От Школы\nдо Университета",
        "Обрежь Любую\nЗадачу",
        "Все Решения\nпод Контролем",
    ],
    "hi": [
        "फोटो लो,\nजवाब पाओ",
        "AI स्टेप-बाय-स्टेप\nसमाधान",
        "स्कूल से\nयूनिवर्सिटी तक",
        "किसी भी सवाल को\nक्रॉप करो",
        "सभी हल\nट्रैक करो",
    ],
    "he": [
        "צלמו תמונה,\nקבלו את התשובה",
        "הסברי AI\nצעד אחר צעד",
        "מיסודי\nעד אוניברסיטה",
        "חתכו כל\nבעיית מתמטיקה",
        "עקבו אחר כל\nהפתרונות שלכם",
    ],
    "hr": [
        "Slikajte i\nDobijte Odgovor",
        "AI Objašnjenja\nKorak po Korak",
        "Od Osnovne\ndo Fakulteta",
        "Izrežite Bilo Koji\nMatematički Problem",
        "Pratite Sva\nVaša Rješenja",
    ],
    "cs": [
        "Vyfoťte a\nZískejte Odpověď",
        "AI Vysvětlení\nKrok za Krokem",
        "Od Základky\npo Univerzitu",
        "Ořežte Jakýkoliv\nPříklad",
        "Sledujte Všechna\nVaše Řešení",
    ],
    "da": [
        "Tag et Foto,\nFå Svaret",
        "AI Trin-for-Trin\nForklaringer",
        "Fra Folkeskole\ntil Universitet",
        "Beskær Ethvert\nMatematikproblem",
        "Hold Styr på Alle\nDine Løsninger",
    ],
    "fi": [
        "Ota Kuva,\nSaa Vastaus",
        "AI Vaihe Vaiheelta\nSelitykset",
        "Peruskoulusta\nYliopistoon",
        "Rajaa Mikä Tahansa\nTehtävä",
        "Seuraa Kaikkia\nRatkaisujasi",
    ],
    "el": [
        "Τραβήξτε Φωτό,\nΠάρτε την Απάντηση",
        "AI Εξηγήσεις\nΒήμα προς Βήμα",
        "Από το Δημοτικό\nως το Πανεπιστήμιο",
        "Περικόψτε Οποιοδήποτε\nΜαθηματικό Πρόβλημα",
        "Παρακολουθήστε Όλες\nτις Λύσεις σας",
    ],
    "hu": [
        "Fényképezd le,\nKapd meg a Választ",
        "AI Lépésről Lépésre\nMagyarázatok",
        "Általánostól\naz Egyetemig",
        "Vágd ki Bármely\nMatekfeladatot",
        "Kövesd az Összes\nMegoldásodat",
    ],
    "id": [
        "Ambil Foto,\nDapatkan Jawaban",
        "Penjelasan AI\nLangkah demi Langkah",
        "Dari SD\nsampai Universitas",
        "Potong Soal\nMatematika Apapun",
        "Lacak Semua\nSolusi Anda",
    ],
    "ms": [
        "Ambil Gambar,\nDapatkan Jawapan",
        "Penerangan AI\nLangkah demi Langkah",
        "Dari Sekolah Rendah\nke Universiti",
        "Pangkas Sebarang\nMasalah Matematik",
        "Jejaki Semua\nPenyelesaian Anda",
    ],
    "no": [
        "Ta et Bilde,\nFå Svaret",
        "AI Steg-for-Steg\nForklaringer",
        "Fra Barneskole\ntil Universitet",
        "Beskjær Ethvert\nMatteproblem",
        "Hold Oversikt Over\nAlle Løsningene",
    ],
    "pl": [
        "Zrób Zdjęcie,\nOtrzymaj Odpowiedź",
        "Wyjaśnienia AI\nKrok po Kroku",
        "Od Podstawówki\ndo Uniwersytetu",
        "Przytnij Dowolne\nZadanie z Matematyki",
        "Śledź Wszystkie\nSwoje Rozwiązania",
    ],
    "ro": [
        "Fă o Poză,\nPrimește Răspunsul",
        "Explicații AI\nPas cu Pas",
        "De la Școală\nla Universitate",
        "Decupează Orice\nProblemă de Matematică",
        "Urmărește Toate\nSoluțiile Tale",
    ],
    "sk": [
        "Odfoťte a\nZískajte Odpoveď",
        "AI Vysvetlenia\nKrok za Krokom",
        "Od Základky\npo Univerzitu",
        "Orežte Akýkoľvek\nPríklad",
        "Sledujte Všetky\nVaše Riešenia",
    ],
    "sv": [
        "Ta ett Foto,\nFå Svaret",
        "AI Steg-för-Steg\nFörklaringar",
        "Från Grundskola\ntill Universitet",
        "Beskär Vilket\nMatteproblem som Helst",
        "Håll Koll på Alla\nDina Lösningar",
    ],
    "th": [
        "ถ่ายรูป\nรับคำตอบทันที",
        "AI อธิบาย\nทีละขั้นตอน",
        "ตั้งแต่ประถม\nถึงมหาวิทยาลัย",
        "ครอปโจทย์เลข\nได้ทุกแบบ",
        "ติดตามคำตอบ\nทั้งหมดของคุณ",
    ],
    "uk": [
        "Сфотографуйте\nі Отримайте Відповідь",
        "AI Покрокові\nПояснення",
        "Від Школи\nдо Університету",
        "Обріжте Будь-яку\nЗадачу",
        "Відстежуйте Всі\nВаші Розвʼязки",
    ],
    "vi": [
        "Chụp Ảnh,\nNhận Đáp Án",
        "AI Giải Thích\nTừng Bước",
        "Từ Tiểu Học\nđến Đại Học",
        "Cắt Bất Kỳ\nBài Toán Nào",
        "Theo Dõi Tất Cả\nLời Giải Của Bạn",
    ],
    "ca": [
        "Fes una Foto,\nObtingues la Resposta",
        "Explicacions IA\nPas a Pas",
        "De Primària\na la Universitat",
        "Retalla Qualsevol\nProblema de Mates",
        "Segueix Totes\nles Teves Solucions",
    ],
    "bn-BD": [
        "ছবি তুলুন,\nউত্তর পান",
        "AI ধাপে ধাপে\nব্যাখ্যা",
        "প্রাথমিক থেকে\nবিশ্ববিদ্যালয় পর্যন্ত",
        "যেকোনো সমস্যা\nক্রপ করুন",
        "সব সমাধান\nট্র্যাক করুন",
    ],
    "gu-IN": [
        "ફોટો લો,\nજવાબ મેળવો",
        "AI પગલે પગલે\nસમજૂતી",
        "પ્રાથમિકથી\nયુનિવર્સિટી સુધી",
        "કોઈપણ સમસ્યા\nક્રોપ કરો",
        "બધા ઉકેલો\nટ્રેક કરો",
    ],
    "kn-IN": [
        "ಫೋಟೋ ತೆಗೆಯಿರಿ,\nಉತ್ತರ ಪಡೆಯಿರಿ",
        "AI ಹಂತ ಹಂತವಾಗಿ\nವಿವರಣೆ",
        "ಪ್ರಾಥಮಿಕದಿಂದ\nವಿಶ್ವವಿದ್ಯಾಲಯದವರೆಗೆ",
        "ಯಾವುದೇ ಸಮಸ್ಯೆಯನ್ನು\nಕ್ರಾಪ್ ಮಾಡಿ",
        "ಎಲ್ಲಾ ಪರಿಹಾರಗಳನ್ನು\nಟ್ರ್ಯಾಕ್ ಮಾಡಿ",
    ],
    "ml-IN": [
        "ഫോട്ടോ എടുക്കൂ,\nഉത്തരം നേടൂ",
        "AI ഘട്ടം ഘട്ടമായി\nവിശദീകരണം",
        "പ്രൈമറി മുതൽ\nയൂണിവേഴ്സിറ്റി വരെ",
        "ഏത് പ്രശ്നവും\nക്രോപ്പ് ചെയ്യൂ",
        "എല്ലാ പരിഹാരങ്ങളും\nട്രാക്ക് ചെയ്യൂ",
    ],
    "mr-IN": [
        "फोटो काढा,\nउत्तर मिळवा",
        "AI टप्प्याटप्प्याने\nस्पष्टीकरण",
        "शाळेपासून\nविद्यापीठापर्यंत",
        "कोणतीही समस्या\nक्रॉप करा",
        "सर्व उत्तरे\nट्रॅक करा",
    ],
    "or-IN": [
        "ଫଟୋ ନିଅନ୍ତୁ,\nଉତ୍ତର ପାଆନ୍ତୁ",
        "AI ସୋପାନ ସୋପାନ\nବ୍ୟାଖ୍ୟା",
        "ପ୍ରାଥମିକରୁ\nବିଶ୍ୱବିଦ୍ୟାଳୟ ପର୍ଯ୍ୟନ୍ତ",
        "ଯେକୌଣସି ସମସ୍ୟା\nକ୍ରପ କରନ୍ତୁ",
        "ସମସ୍ତ ସମାଧାନ\nଟ୍ରାକ କରନ୍ତୁ",
    ],
    "pa-IN": [
        "ਫੋਟੋ ਖਿੱਚੋ,\nਜਵਾਬ ਪਾਓ",
        "AI ਕਦਮ ਦਰ ਕਦਮ\nਵਿਆਖਿਆ",
        "ਸਕੂਲ ਤੋਂ\nਯੂਨੀਵਰਸਿਟੀ ਤੱਕ",
        "ਕੋਈ ਵੀ ਸਵਾਲ\nਕ੍ਰੌਪ ਕਰੋ",
        "ਸਾਰੇ ਹੱਲ\nਟ੍ਰੈਕ ਕਰੋ",
    ],
    "sl-SI": [
        "Fotografirajte,\nDobite Odgovor",
        "AI Razlage\npo Korakih",
        "Od Osnovne Šole\ndo Univerze",
        "Obrežite Katerikoli\nMatematični Problem",
        "Spremljajte Vse\nVaše Rešitve",
    ],
    "ta-IN": [
        "புகைப்படம் எடுங்கள்,\nபதில் பெறுங்கள்",
        "AI படிப்படியான\nவிளக்கங்கள்",
        "பள்ளி முதல்\nபல்கலை வரை",
        "எந்த கணிதமும்\nகிராப் செய்யுங்கள்",
        "அனைத்து தீர்வுகளையும்\nகண்காணியுங்கள்",
    ],
    "te-IN": [
        "ఫోటో తీయండి,\nసమాధానం పొందండి",
        "AI దశల వారీ\nవివరణలు",
        "స్కూల్ నుండి\nయూనివర్సిటీ వరకు",
        "ఏ సమస్యనైనా\nక్రాప్ చేయండి",
        "అన్ని పరిష్కారాలను\nట్రాక్ చేయండి",
    ],
    "ur-PK": [
        "تصویر لیں،\nجواب حاصل کریں",
        "AI قدم بہ قدم\nوضاحت",
        "سکول سے\nیونیورسٹی تک",
        "کوئی بھی سوال\nکراپ کریں",
        "تمام حل\nٹریک کریں",
    ],
}


def get_font(locale, size):
    """Get the appropriate font for a locale."""
    script = LOCALE_SCRIPT.get(locale, "latin")
    font_path = FONTS.get(script, FONTS["fallback"])
    try:
        return ImageFont.truetype(font_path, size)
    except Exception:
        return ImageFont.truetype(FONTS["fallback"], size)


def reshape_rtl_text(text):
    """Reshape Arabic/Hebrew/Urdu text for correct Pillow rendering."""
    if not HAS_BIDI:
        return text
    # Process each line separately
    lines = text.split("\n")
    reshaped_lines = []
    for line in lines:
        reshaped = arabic_reshaper.reshape(line)
        bidi_text = get_display(reshaped)
        reshaped_lines.append(bidi_text)
    return "\n".join(reshaped_lines)


def draw_text_with_shadow(draw, position, text, font, fill=(255, 255, 255), shadow_color=(0, 0, 0, 200), shadow_offset=6):
    """Draw text with a strong drop shadow for readability."""
    x, y = position
    # Double shadow for more depth
    draw.text((x + shadow_offset + 2, y + shadow_offset + 2), text, font=font, fill=(0, 0, 0, 100))
    draw.text((x + shadow_offset, y + shadow_offset), text, font=font, fill=shadow_color)
    # Main text
    draw.text((x, y), text, font=font, fill=fill)


def get_text_dimensions(draw, text, font):
    """Get text bounding box dimensions."""
    bbox = draw.textbbox((0, 0), text, font=font)
    return bbox[2] - bbox[0], bbox[3] - bbox[1]


# Per-screenshot safe zones: (text_position, max_y_for_text, gradient_from)
# text_position: "top" or "bottom"
# SS01: Phone starts ~528px → top text, safe up to ~480px
# SS02: Phone starts ~300px → bottom text (phone is high)
# SS03: Phone starts ~466px → top text, safe up to ~430px
# SS04: Phone at very top → bottom text
# SS05: Phone at very top → bottom text
SCREENSHOT_LAYOUT = {
    "01-solve-math.jpg":        {"position": "top",    "safe_end": 480,  "gradient_height": 550},
    "02-learn-step-by-step.jpg": {"position": "bottom", "safe_start": 2350, "gradient_height": 500},
    "03-master-any-level.jpg":  {"position": "top",    "safe_end": 420,  "gradient_height": 500},
    "04-snap-crop-solve.jpg":   {"position": "bottom", "safe_start": 2350, "gradient_height": 500},
    "05-review-solutions.jpg":  {"position": "bottom", "safe_start": 2350, "gradient_height": 500},
}


def add_title_overlay(img, title_text, locale, font_size, ss_file):
    """Add a bold, eye-catching title overlay that avoids the phone mockup."""
    img = img.copy().convert("RGBA")
    w, h = img.size  # 1290 x 2796

    layout = SCREENSHOT_LAYOUT.get(ss_file, {"position": "top", "safe_end": 480, "gradient_height": 550})
    position = layout["position"]
    gradient_height = layout.get("gradient_height", 550)

    # Create gradient overlay
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)

    if position == "top":
        # Gradient from top (dark) to transparent
        for y_pos in range(gradient_height):
            progress = y_pos / gradient_height
            alpha = int(230 * (1 - progress) ** 1.3)
            overlay_draw.line([(0, y_pos), (w, y_pos)], fill=(0, 0, 0, alpha))
    else:
        # Gradient from bottom (dark) to transparent
        for y_pos in range(gradient_height):
            progress = y_pos / gradient_height
            alpha = int(230 * (1 - progress) ** 1.3)
            actual_y = h - 1 - y_pos
            overlay_draw.line([(0, actual_y), (w, actual_y)], fill=(0, 0, 0, alpha))

    img = Image.alpha_composite(img, overlay)

    # Draw text
    draw = ImageDraw.Draw(img)
    font = get_font(locale, font_size)

    # Reshape RTL text for correct rendering
    is_rtl = locale in RTL_LOCALES
    if is_rtl:
        title_text = reshape_rtl_text(title_text)

    lines = title_text.split("\n")

    # Calculate total text height
    line_heights = []
    line_widths = []
    for line in lines:
        tw, th = get_text_dimensions(draw, line, font)
        line_widths.append(tw)
        line_heights.append(th)

    line_spacing = 24
    total_height = sum(line_heights) + line_spacing * (len(lines) - 1)

    if position == "top":
        # Center text vertically within safe top zone
        safe_end = layout.get("safe_end", 480)
        y_start = max(60, (safe_end - total_height) // 2)
    else:
        # Center text vertically within safe bottom zone
        safe_start = layout.get("safe_start", 2350)
        available = h - safe_start
        y_start = safe_start + max(30, (available - total_height) // 2)

    for i, line in enumerate(lines):
        tw = line_widths[i]
        x = (w - tw) // 2  # Center horizontally

        draw_text_with_shadow(
            draw,
            (x, y_start),
            line,
            font,
            fill=(255, 255, 255),
            shadow_color=(0, 0, 0, 200),
            shadow_offset=6,
        )
        y_start += line_heights[i] + line_spacing

    return img.convert("RGB")


def main():
    print("=" * 60)
    print("MathPro - Titled Screenshot Generator")
    print(f"  Languages: {len(TITLES)}")
    print(f"  Screenshots: {len(SCREENSHOTS)}")
    print(f"  Total images: {len(TITLES) * len(SCREENSHOTS)}")
    print("=" * 60)

    total = 0
    errors = 0

    for locale, titles in sorted(TITLES.items()):
        locale_dir = os.path.join(OUTPUT_DIR, locale)
        os.makedirs(locale_dir, exist_ok=True)

        print(f"\n  [{locale}]", end="", flush=True)

        for idx, (ss_file, title) in enumerate(zip(SCREENSHOTS, titles)):
            src_path = os.path.join(FINAL_DIR, ss_file)
            if not os.path.exists(src_path):
                print(f" ✗{idx+1}", end="", flush=True)
                errors += 1
                continue

            try:
                img = Image.open(src_path)

                # BIGGER font sizes — eye-catching and bold
                script = LOCALE_SCRIPT.get(locale, "latin")
                if script in ("chinese", "japanese", "korean"):
                    font_size = 130
                elif script in ("arabic", "urdu", "hebrew"):
                    font_size = 110
                elif script in ("thai",):
                    font_size = 105
                elif script in ("bangla", "devanagari", "gujarati", "kannada", "malayalam", "odia", "punjabi", "tamil", "telugu"):
                    font_size = 100
                elif script in ("cyrillic", "greek"):
                    font_size = 115
                else:
                    font_size = 120

                result = add_title_overlay(img, title, locale, font_size, ss_file)

                out_path = os.path.join(locale_dir, ss_file)
                result.save(out_path, "JPEG", quality=95)
                total += 1
                print(f" ✓{idx+1}", end="", flush=True)

            except Exception as e:
                print(f" ✗{idx+1}({e})", end="", flush=True)
                errors += 1

    print(f"\n\n{'=' * 60}")
    print(f"DONE! ✓ {total} generated, ✗ {errors} errors")
    print(f"Output: {OUTPUT_DIR}/")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()

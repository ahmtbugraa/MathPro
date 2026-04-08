#!/usr/bin/env python3
"""
App Store Connect - 11 New Languages Metadata Uploader
Adds complete metadata (title, subtitle, keywords, promo, description) for:
Bangla, Gujarati, Kannada, Malayalam, Marathi, Odia, Punjabi, Slovenian, Tamil, Telugu, Urdu
"""

import jwt, time, requests, os, sys, json

KEY_ID = "F45A64X9CT"
ISSUER_ID = "aa8b074b-c562-463d-86e6-30dd31eb8ef8"
P8_PATH = "/Users/abk/Downloads/AuthKey_F45A64X9CT.p8"
BUNDLE_ID = "com.ahmetbugrakacdi.MathPro"
BASE = "https://api.appstoreconnect.apple.com/v1"

with open(P8_PATH, "r") as f:
    PRIVATE_KEY = f.read()

PRIVACY_URL = "https://www.notion.so/MathPro-Privacy-Policy-32f3887142058088b5f3eae284b4515a"
TERMS_URL = "https://www.notion.so/MathPro-Terms-of-Use-32f38871420580daaf10e5412a61d0e9"


def token():
    now = int(time.time())
    return jwt.encode(
        {"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
        PRIVATE_KEY, algorithm="ES256",
        headers={"alg": "ES256", "kid": KEY_ID, "typ": "JWT"},
    )


def hdrs():
    return {"Authorization": f"Bearer {token()}", "Content-Type": "application/json"}


def api_get(path, params=None):
    resp = requests.get(f"{BASE}{path}", headers=hdrs(), params=params or {})
    return resp.json() if resp.status_code == 200 else None


def api_get_all(path, params=None):
    results = []
    url = f"{BASE}{path}"
    p = params or {}
    p["limit"] = 50
    while url:
        resp = requests.get(url, headers=hdrs(), params=p)
        if resp.status_code != 200:
            break
        data = resp.json()
        results.extend(data.get("data", []))
        url = data.get("links", {}).get("next")
        p = {}
    return results


def api_patch(path, data):
    resp = requests.patch(f"{BASE}{path}", headers=hdrs(), json=data)
    return resp.status_code == 200, resp


def api_post(path, data):
    resp = requests.post(f"{BASE}{path}", headers=hdrs(), json=data)
    return resp.status_code in (200, 201), resp


# ══════════════════════════════════════════════════════════════
# 11 NEW LANGUAGES — Full metadata in native language
# ══════════════════════════════════════════════════════════════

LOCALES = {
    # ── Bangla (Bengali) ──────────────────────────────────────
    "bn-BD": {
        "name": "AI গণিত সমাধান - ফটো স্ক্যানার",
        "subtitle": "ধাপে ধাপে সমাধান সহায়ক",
        "keywords": "MathPro,গণিত,সমীকরণ,বীজগণিত,জ্যামিতি,ক্যালকুলেটর,পরীক্ষা,সূত্র,ক্যামেরা,পড়াশোনা,উত্তর,ক্যালকুলাস",
        "promoText": "যেকোনো গণিত সমস্যার ছবি তুলুন এবং AI থেকে তাৎক্ষণিক ধাপে ধাপে সমাধান পান। স্কুল থেকে বিশ্ববিদ্যালয় পর্যন্ত — আপনার ব্যক্তিগত গণিত শিক্ষক!",
        "description": f"""যেকোনো গণিত সমস্যা তাৎক্ষণিক সমাধান করুন — শুধু একটি ছবি তুলুন!

AI গণিত সমাধান উন্নত কৃত্রিম বুদ্ধিমত্তা ব্যবহার করে ছবি থেকে গণিত সমস্যা স্ক্যান, চিনতে এবং সমাধান করে। পাঠ্যবইয়ের প্রশ্ন হোক, হাতে লেখা সমীকরণ হোক বা হোমওয়ার্ক — ক্যামেরা তাক করুন এবং কয়েক সেকেন্ডে বিস্তারিত ধাপে ধাপে সমাধান পান।

আপনি যা করতে পারেন:
- যেকোনো গণিত সমস্যার ছবি তুলুন বা গ্যালারি থেকে আমদানি করুন
- যে সমস্যাটি সমাধান করতে চান সেটি ক্রপ করে নির্বাচন করুন
- সম্পূর্ণ ধাপে ধাপে ব্যাখ্যাসহ তাৎক্ষণিক AI সমাধান পান
- অনুসন্ধানযোগ্য ইতিহাসে আপনার সমস্ত সমাধান দেখুন
- সুন্দর ছবি হিসেবে সমাধান শেয়ার করুন

গণিত বিষয়সমূহ:
- পাটিগণিত ও মৌলিক গণিত
- বীজগণিত ও রৈখিক বীজগণিত
- জ্যামিতি ও ত্রিকোণমিতি
- ক্যালকুলাস ও ডিফারেনশিয়াল সমীকরণ
- পরিসংখ্যান ও সম্ভাব্যতা
- সমস্যা সমাধান

আপনার স্তরে মানানসই:
আপনার শিক্ষাগত স্তর বেছে নিন — প্রাথমিক, মাধ্যমিক, উচ্চ মাধ্যমিক বা বিশ্ববিদ্যালয় — এবং AI তার ব্যাখ্যা সামঞ্জস্য করে।

সাবস্ক্রিপশন তথ্য:
কিছু বৈশিষ্ট্য সম্পূর্ণ অ্যাক্সেসের জন্য সক্রিয় সাবস্ক্রিপশন প্রয়োজন।
- সাবস্ক্রিপশন বিকল্প: সাপ্তাহিক এবং বার্ষিক প্ল্যান উপলব্ধ
- ক্রয় নিশ্চিত করার সময় আপনার Apple ID অ্যাকাউন্ট থেকে অর্থ কাটা হয়
- বর্তমান সময়কাল শেষ হওয়ার কমপক্ষে 24 ঘণ্টা আগে বাতিল না করলে সাবস্ক্রিপশন স্বয়ংক্রিয়ভাবে পুনর্নবীকরণ হয়
- ক্রয়ের পরে Apple ID অ্যাকাউন্ট সেটিংসে আপনার সাবস্ক্রিপশন পরিচালনা ও বাতিল করতে পারেন

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",
    },

    # ── Gujarati ──────────────────────────────────────────────
    "gu-IN": {
        "name": "AI ગણિત સોલ્વર - ફોટો સ્કેનર",
        "subtitle": "પગલે પગલે ઉકેલ સહાયક",
        "keywords": "MathPro,ગણિત,સમીકરણ,બીજગણિત,ભૂમિતિ,કેલ્ક્યુલેટર,પરીક્ષા,સૂત્ર,કેમેરા,અભ્યાસ,જવાબ,બોર્ડ",
        "promoText": "કોઈપણ ગણિતના પ્રશ્નનો ફોટો લો અને AI થી તરત જ પગલે પગલે ઉકેલ મેળવો. શાળાથી યુનિવર્સિટી સુધી — તમારા અંગત ગણિત શિક્ષક!",
        "description": f"""કોઈપણ ગણિત સમસ્યા તરત જ ઉકેલો — ફક્ત ફોટો લો!

AI ગણિત સોલ્વર અદ્યતન કૃત્રિમ બુદ્ધિનો ઉપયોગ કરીને ફોટોમાંથી ગણિત સમસ્યાઓ સ્કેન, ઓળખ અને ઉકેલ કરે છે. પાઠ્યપુસ્તકનો પ્રશ્ન હોય, હાથે લખેલું સમીકરણ હોય કે હોમવર્ક — કેમેરા નિર્દેશ કરો અને સેકન્ડોમાં વિગતવાર પગલે પગલે ઉકેલ મેળવો.

તમે શું કરી શકો:
- કોઈપણ ગણિત સમસ્યાનો ફોટો લો અથવા ગેલેરીમાંથી આયાત કરો
- જે સમસ્યા ઉકેલવી છે તે ક્રોપ કરીને પસંદ કરો
- સંપૂર્ણ પગલે પગલે સમજૂતી સાથે AI ઉકેલ મેળવો
- શોધી શકાય તેવા ઇતિહાસમાં બધી ઉકેલાયેલી સમસ્યાઓ જુઓ
- સુંદર ચિત્રો તરીકે ઉકેલ શેર કરો

ગણિત વિષયો:
- અંકગણિત અને મૂળ ગણિત
- બીજગણિત અને રેખીય બીજગણિત
- ભૂમિતિ અને ત્રિકોણમિતિ
- કલનશાસ્ત્ર અને વિકલ સમીકરણો
- આંકડાશાસ્ત્ર અને સંભાવના
- શાબ્દિક સમસ્યાઓ

તમારા સ્તર મુજબ:
તમારું શિક્ષણ સ્તર પસંદ કરો — પ્રાથમિક, માધ્યમિક, ઉચ્ચતર માધ્યમિક અથવા યુનિવર્સિટી — અને AI તેની સમજૂતી ગોઠવે છે.

GSEB અને બોર્ડ પરીક્ષાની તૈયારી માટે આદર્શ!

સબ્સ્ક્રિપ્શન માહિતી:
કેટલીક સુવિધાઓ માટે સંપૂર્ણ ઍક્સેસ માટે સક્રિય સબ્સ્ક્રિપ્શન જરૂરી છે.
- સબ્સ્ક્રિપ્શન વિકલ્પો: સાપ્તાહિક અને વાર્ષિક યોજનાઓ ઉપલબ્ધ
- ખરીદીની પુષ્ટિ પર તમારા Apple ID ખાતામાંથી ચુકવણી કરવામાં આવે છે
- વર્તમાન સમયગાળો સમાપ્ત થાય તેના ઓછામાં ઓછા 24 કલાક પહેલાં રદ ન કરવામાં આવે ત્યાં સુધી સબ્સ્ક્રિપ્શન આપમેળે રિન્યૂ થાય છે
- ખરીદી પછી Apple ID એકાઉન્ટ સેટિંગ્સમાં તમારી સબ્સ્ક્રિપ્શન્સ મેનેજ અને રદ કરી શકો છો

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",
    },

    # ── Kannada ────────────────────────────────────────────────
    "kn-IN": {
        "name": "AI ಗಣಿತ ಸಾಲ್ವರ್ - ಫೋಟೋ ಸ್ಕ್ಯಾನರ್",
        "subtitle": "ಹಂತ ಹಂತವಾಗಿ ಪರಿಹಾರ",
        "keywords": "MathPro,ಗಣಿತ,ಸಮೀಕರಣ,ಬೀಜಗಣಿತ,ರೇಖಾಗಣಿತ,ಕ್ಯಾಲ್ಕುಲೇಟರ್,ಪರೀಕ್ಷೆ,ಸೂತ್ರ,ಕ್ಯಾಮೆರಾ,ಅಧ್ಯಯನ,SSLC,PUC",
        "promoText": "ಯಾವುದೇ ಗಣಿತ ಸಮಸ್ಯೆಯ ಫೋಟೋ ತೆಗೆಯಿರಿ ಮತ್ತು AI ಯಿಂದ ತಕ್ಷಣ ಹಂತ ಹಂತವಾಗಿ ಪರಿಹಾರ ಪಡೆಯಿರಿ. ಶಾಲೆಯಿಂದ ವಿಶ್ವವಿದ್ಯಾಲಯದವರೆಗೆ!",
        "description": f"""ಯಾವುದೇ ಗಣಿತ ಸಮಸ್ಯೆಯನ್ನು ತಕ್ಷಣ ಪರಿಹರಿಸಿ — ಫೋಟೋ ತೆಗೆಯಿರಿ!

AI ಗಣಿತ ಸಾಲ್ವರ್ ಮುಂದುವರಿದ ಕೃತಕ ಬುದ್ಧಿಮತ್ತೆಯನ್ನು ಬಳಸಿ ಫೋಟೋದಿಂದ ಗಣಿತ ಸಮಸ್ಯೆಗಳನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಿ, ಗುರುತಿಸಿ ಮತ್ತು ಪರಿಹರಿಸುತ್ತದೆ. ಪಠ್ಯಪುಸ್ತಕದ ಪ್ರಶ್ನೆ, ಕೈಬರಹದ ಸಮೀಕರಣ ಅಥವಾ ಮನೆಕೆಲಸ — ಕ್ಯಾಮೆರಾ ತೋರಿಸಿ ಸೆಕೆಂಡುಗಳಲ್ಲಿ ವಿವರವಾದ ಹಂತ ಹಂತ ಪರಿಹಾರ ಪಡೆಯಿರಿ.

ನೀವು ಏನು ಮಾಡಬಹುದು:
- ಯಾವುದೇ ಗಣಿತ ಸಮಸ್ಯೆಯ ಫೋಟೋ ತೆಗೆಯಿರಿ ಅಥವಾ ಗ್ಯಾಲರಿಯಿಂದ ಆಮದು ಮಾಡಿ
- ಪರಿಹರಿಸಬೇಕಾದ ಸಮಸ್ಯೆಯನ್ನು ಕ್ರಾಪ್ ಮಾಡಿ ಆಯ್ಕೆ ಮಾಡಿ
- ಸಂಪೂರ್ಣ ಹಂತ ಹಂತ ವಿವರಣೆಯೊಂದಿಗೆ AI ಪರಿಹಾರಗಳನ್ನು ಪಡೆಯಿರಿ
- ಹುಡುಕಬಹುದಾದ ಇತಿಹಾಸದಲ್ಲಿ ಎಲ್ಲಾ ಪರಿಹಾರಗಳನ್ನು ನೋಡಿ
- ಸುಂದರ ಚಿತ್ರಗಳಾಗಿ ಪರಿಹಾರಗಳನ್ನು ಹಂಚಿಕೊಳ್ಳಿ

ಗಣಿತ ವಿಷಯಗಳು:
- ಅಂಕಗಣಿತ ಮತ್ತು ಮೂಲ ಗಣಿತ
- ಬೀಜಗಣಿತ ಮತ್ತು ರೇಖಾತ್ಮಕ ಬೀಜಗಣಿತ
- ರೇಖಾಗಣಿತ ಮತ್ತು ತ್ರಿಕೋನಮಿತಿ
- ಕಲನಶಾಸ್ತ್ರ ಮತ್ತು ಡಿಫರೆನ್ಶಿಯಲ್ ಸಮೀಕರಣಗಳು
- ಸಂಖ್ಯಾಶಾಸ್ತ್ರ ಮತ್ತು ಸಂಭಾವ್ಯತೆ

SSLC ಮತ್ತು PUC ಪರೀಕ್ಷೆಗಳ ತಯಾರಿಗೆ ಅತ್ಯುತ್ತಮ!

ಚಂದಾದಾರಿಕೆ ಮಾಹಿತಿ:
ಕೆಲವು ವೈಶಿಷ್ಟ್ಯಗಳಿಗೆ ಸಂಪೂರ್ಣ ಪ್ರವೇಶಕ್ಕಾಗಿ ಸಕ್ರಿಯ ಚಂದಾದಾರಿಕೆ ಅಗತ್ಯ.
- ಚಂದಾದಾರಿಕೆ ಆಯ್ಕೆಗಳು: ಸಾಪ್ತಾಹಿಕ ಮತ್ತು ವಾರ್ಷಿಕ ಯೋಜನೆಗಳು ಲಭ್ಯ
- ಖರೀದಿ ದೃಢೀಕರಣದ ಸಮಯದಲ್ಲಿ ನಿಮ್ಮ Apple ID ಖಾತೆಯಿಂದ ಪಾವತಿ ಮಾಡಲಾಗುತ್ತದೆ
- ಪ್ರಸ್ತುತ ಅವಧಿ ಮುಗಿಯುವ ಕನಿಷ್ಠ 24 ಗಂಟೆ ಮೊದಲು ರದ್ದುಗೊಳಿಸದಿದ್ದರೆ ಚಂದಾದಾರಿಕೆ ಸ್ವಯಂಚಾಲಿತವಾಗಿ ನವೀಕರಣಗೊಳ್ಳುತ್ತದೆ
- ಖರೀದಿಯ ನಂತರ Apple ID ಖಾತೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ನಿಮ್ಮ ಚಂದಾದಾರಿಕೆಗಳನ್ನು ನಿರ್ವಹಿಸಬಹುದು ಮತ್ತು ರದ್ದುಗೊಳಿಸಬಹುದು

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",
    },

    # ── Malayalam ──────────────────────────────────────────────
    "ml-IN": {
        "name": "AI ഗണിത സോൾവർ - ഫോട്ടോ സ്കാനർ",
        "subtitle": "ഘട്ടം ഘട്ടമായി പരിഹാരം",
        "keywords": "MathPro,ഗണിതം,സമവാക്യം,ബീജഗണിതം,ജ്യാമിതി,കാൽക്കുലേറ്റർ,പരീക്ഷ,ക്യാമറ,പഠനം,SSLC,Plus Two",
        "promoText": "ഏത് ഗണിത പ്രശ്നത്തിന്റെയും ഫോട്ടോ എടുക്കൂ, AI യിൽ നിന്ന് ഉടൻ ഘട്ടം ഘട്ടമായി പരിഹാരം നേടൂ. സ്കൂൾ മുതൽ യൂണിവേഴ്സിറ്റി വരെ!",
        "description": f"""ഏത് ഗണിത പ്രശ്നവും ഉടൻ പരിഹരിക്കൂ — ഒരു ഫോട്ടോ എടുക്കൂ!

AI ഗണിത സോൾവർ നൂതന നിർമ്മിത ബുദ്ധി ഉപയോഗിച്ച് ഫോട്ടോയിൽ നിന്ന് ഗണിത പ്രശ്നങ്ങൾ സ്കാൻ ചെയ്യുകയും, തിരിച്ചറിയുകയും, പരിഹരിക്കുകയും ചെയ്യുന്നു. പാഠപുസ്തക ചോദ്യം, കൈയെഴുത്ത് സമവാക്യം അല്ലെങ്കിൽ ഹോംവർക്ക് — ക്യാമറ ചൂണ്ടൂ, സെക്കന്റുകൾക്കുള്ളിൽ വിശദമായ ഘട്ടം ഘട്ടം പരിഹാരം നേടൂ.

നിങ്ങൾക്ക് എന്ത് ചെയ്യാം:
- ഏത് ഗണിത പ്രശ്നത്തിന്റെയും ഫോട്ടോ എടുക്കുക അല്ലെങ്കിൽ ഗാലറിയിൽ നിന്ന് ഇറക്കുമതി ചെയ്യുക
- പരിഹരിക്കേണ്ട പ്രശ്നം ക്രോപ്പ് ചെയ്ത് തിരഞ്ഞെടുക്കുക
- പൂർണ്ണ ഘട്ടം ഘട്ടം വിശദീകരണത്തോടെ AI പരിഹാരങ്ങൾ നേടുക
- തിരയാനാകുന്ന ചരിത്രത്തിൽ എല്ലാ പരിഹാരങ്ങളും കാണുക
- മനോഹരമായ ചിത്രങ്ങളായി പരിഹാരങ്ങൾ പങ്കിടുക

ഗണിത വിഷയങ്ങൾ:
- ഗണിതവും അടിസ്ഥാന ഗണിതവും
- ബീജഗണിതവും രേഖീയ ബീജഗണിതവും
- ജ്യാമിതിയും ത്രികോണമിതിയും
- കാൽക്കുലസും ഡിഫറൻഷ്യൽ സമവാക്യങ്ങളും
- സ്ഥിതിവിവരക്കണക്കും സംഭാവ്യതയും

SSLC, Plus Two പരീക്ഷകൾക്ക് തയ്യാറാകാൻ മികച്ചത്!

സബ്സ്ക്രിപ്ഷൻ വിവരങ്ങൾ:
ചില ഫീച്ചറുകൾക്ക് പൂർണ്ണ ആക്സസ്സിന് സജീവ സബ്സ്ക്രിപ്ഷൻ ആവശ്യമാണ്.
- സബ്സ്ക്രിപ്ഷൻ ഓപ്ഷനുകൾ: പ്രതിവാര, വാർഷിക പ്ലാനുകൾ ലഭ്യമാണ്
- വാങ്ങൽ സ്ഥിരീകരിക്കുമ്പോൾ നിങ്ങളുടെ Apple ID അക്കൗണ്ടിൽ നിന്ന് പേയ്മെന്റ് ഈടാക്കുന്നു
- നിലവിലെ കാലയളവ് അവസാനിക്കുന്നതിന് കുറഞ്ഞത് 24 മണിക്കൂർ മുമ്പ് റദ്ദാക്കിയില്ലെങ്കിൽ സബ്സ്ക്രിപ്ഷൻ സ്വയമേവ പുതുക്കും
- വാങ്ങലിന് ശേഷം Apple ID അക്കൗണ്ട് സെറ്റിംഗ്സിൽ നിങ്ങളുടെ സബ്സ്ക്രിപ്ഷനുകൾ നിയന്ത്രിക്കാനും റദ്ദാക്കാനും കഴിയും

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",
    },

    # ── Marathi ────────────────────────────────────────────────
    "mr-IN": {
        "name": "AI गणित सोल्व्हर - फोटो स्कॅनर",
        "subtitle": "टप्प्याटप्प्याने उत्तर सहाय्यक",
        "keywords": "MathPro,गणित,समीकरण,बीजगणित,भूमिती,कॅल्क्युलेटर,परीक्षा,सूत्र,कॅमेरा,अभ्यास,SSC,HSC,उत्तर",
        "promoText": "कोणत्याही गणिताच्या प्रश्नाचा फोटो काढा आणि AI कडून लगेच टप्प्याटप्प्याने उत्तर मिळवा. शाळेपासून विद्यापीठापर्यंत — तुमचा वैयक्तिक गणित शिक्षक!",
        "description": f"""कोणतीही गणित समस्या लगेच सोडवा — फक्त फोटो काढा!

AI गणित सोल्व्हर प्रगत कृत्रिम बुद्धिमत्ता वापरून फोटोमधून गणित समस्या स्कॅन, ओळख आणि सोडवते. पाठ्यपुस्तकाचा प्रश्न असो, हस्तलिखित समीकरण असो किंवा गृहपाठ — कॅमेरा दाखवा आणि सेकंदात तपशीलवार टप्प्याटप्प्याने उत्तर मिळवा.

तुम्ही काय करू शकता:
- कोणत्याही गणित समस्येचा फोटो काढा किंवा गॅलरीतून आयात करा
- सोडवायच्या समस्येला क्रॉप करून निवडा
- संपूर्ण टप्प्याटप्प्याने स्पष्टीकरणासह AI उत्तरे मिळवा
- शोधता येणाऱ्या इतिहासात सर्व सोडवलेल्या समस्या पहा
- सुंदर प्रतिमा म्हणून उत्तरे शेअर करा

गणित विषय:
- अंकगणित आणि मूलभूत गणित
- बीजगणित आणि रेखीय बीजगणित
- भूमिती आणि त्रिकोणमिती
- कलनशास्त्र आणि विभेदक समीकरणे
- सांख्यिकी आणि संभाव्यता
- शाब्दिक समस्या

SSC, HSC आणि बोर्ड परीक्षांच्या तयारीसाठी उत्तम!

सदस्यता माहिती:
काही वैशिष्ट्यांसाठी पूर्ण प्रवेशासाठी सक्रिय सदस्यता आवश्यक आहे.
- सदस्यता पर्याय: साप्ताहिक आणि वार्षिक योजना उपलब्ध
- खरेदीच्या पुष्टीकरणावर तुमच्या Apple ID खात्यातून देयक आकारले जाते
- चालू कालावधी संपण्यापूर्वी किमान 24 तास आधी रद्द केले नाही तर सदस्यता स्वयंचलितपणे नूतनीकृत होते
- खरेदीनंतर Apple ID खाते सेटिंग्जमध्ये तुमच्या सदस्यता व्यवस्थापित आणि रद्द करू शकता

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",
    },

    # ── Odia ───────────────────────────────────────────────────
    "or-IN": {
        "name": "AI ଗଣିତ ସମାଧାନ - ଫଟୋ ସ୍କାନର",
        "subtitle": "ସୋପାନ ସୋପାନ ସମାଧାନ",
        "keywords": "MathPro,ଗଣିତ,ସମୀକରଣ,ବୀଜଗଣିତ,ଜ୍ୟାମିତି,କ୍ୟାଲକୁଲେଟର,ପରୀକ୍ଷା,ସୂତ୍ର,କ୍ୟାମେରା,ଅଧ୍ୟୟନ,ବୋର୍ଡ,ଉତ୍ତର",
        "promoText": "ଯେକୌଣସି ଗଣିତ ସମସ୍ୟାର ଫଟୋ ନିଅନ୍ତୁ ଏବଂ AI ରୁ ତୁରନ୍ତ ସୋପାନ ସୋପାନ ସମାଧାନ ପାଆନ୍ତୁ। ସ୍କୁଲରୁ ୟୁନିଭର୍ସିଟି ପର୍ଯ୍ୟନ୍ତ!",
        "description": f"""ଯେକୌଣସି ଗଣିତ ସମସ୍ୟା ତୁରନ୍ତ ସମାଧାନ କରନ୍ତୁ — କେବଳ ଏକ ଫଟୋ ନିଅନ୍ତୁ!

AI ଗଣିତ ସମାଧାନ ଉନ୍ନତ କୃତ୍ରିମ ବୁଦ୍ଧିମତ୍ତା ବ୍ୟବହାର କରି ଫଟୋରୁ ଗଣିତ ସମସ୍ୟାକୁ ସ୍କାନ, ଚିହ୍ନଟ ଏବଂ ସମାଧାନ କରେ। ପାଠ୍ୟପୁସ୍ତକର ପ୍ରଶ୍ନ, ହାତରେ ଲେଖା ସମୀକରଣ କିମ୍ବା ଗୃହକାର୍ଯ୍ୟ — କ୍ୟାମେରା ଦେଖାନ୍ତୁ ଏବଂ ସେକେଣ୍ଡରେ ବିସ୍ତୃତ ସୋପାନ ସୋପାନ ସମାଧାନ ପାଆନ୍ତୁ।

ଆପଣ କଣ କରିପାରିବେ:
- ଯେକୌଣସି ଗଣିତ ସମସ୍ୟାର ଫଟୋ ନିଅନ୍ତୁ କିମ୍ବା ଗ୍ୟାଲେରୀରୁ ଆମଦାନି କରନ୍ତୁ
- ସମାଧାନ କରିବାକୁ ଥିବା ସମସ୍ୟାକୁ କ୍ରପ କରି ବାଛନ୍ତୁ
- ସମ୍ପୂର୍ଣ୍ଣ ସୋପାନ ସୋପାନ ବ୍ୟାଖ୍ୟା ସହ AI ସମାଧାନ ପାଆନ୍ତୁ
- ସନ୍ଧାନ କରିଯୋଗ୍ୟ ଇତିହାସରେ ସମସ୍ତ ସମାଧାନ ଦେଖନ୍ତୁ
- ସୁନ୍ଦର ଛବି ଭାବରେ ସମାଧାନ ସେୟାର କରନ୍ତୁ

ଗଣିତ ବିଷୟ:
- ଅଙ୍କଗଣିତ ଏବଂ ମୌଳିକ ଗଣିତ
- ବୀଜଗଣିତ ଏବଂ ରେଖୀୟ ବୀଜଗଣିତ
- ଜ୍ୟାମିତି ଏବଂ ତ୍ରିକୋଣମିତି
- କଳନଶାସ୍ତ୍ର ଏବଂ ଅବକଳ ସମୀକରଣ
- ପରିସଂଖ୍ୟାନ ଏବଂ ସମ୍ଭାବନା

ବୋର୍ଡ ପରୀକ୍ଷା ପ୍ରସ୍ତୁତି ପାଇଁ ଆଦର୍ଶ!

ସଦସ୍ୟତା ସୂଚନା:
କିଛି ବୈଶିଷ୍ଟ୍ୟ ପୂର୍ଣ୍ଣ ପ୍ରବେଶ ପାଇଁ ସକ୍ରିୟ ସଦସ୍ୟତା ଆବଶ୍ୟକ।
- ସଦସ୍ୟତା ବିକଳ୍ପ: ସାପ୍ତାହିକ ଏବଂ ବାର୍ଷିକ ଯୋଜନା ଉପಲବ୍ଧ
- କ୍ରୟ ନିଶ୍ଚିତ ସମୟରେ ଆପଣଙ୍କ Apple ID ଆକାଉଣ୍ଟରୁ ଦେୟ ଆଦାୟ ହୁଏ
- ବର୍ତ୍ତମାନ ଅବଧି ଶେଷ ହେବାର ଅତି କମରେ 24 ଘଣ୍ଟା ପୂର୍ବରୁ ବାତିଲ ନ ହେଲେ ସଦସ୍ୟତା ସ୍ୱତଃ ନବୀକରଣ ହୁଏ
- କ୍ରୟ ପରେ Apple ID ଆକାଉଣ୍ଟ ସେଟିଂସରେ ଆପଣଙ୍କ ସଦସ୍ୟତା ପରିଚାଳନା ଏବଂ ବାତିଲ କରିପାରିବେ

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",
    },

    # ── Punjabi ────────────────────────────────────────────────
    "pa-IN": {
        "name": "AI ਗਣਿਤ ਸੌਲਵਰ - ਫੋਟੋ ਸਕੈਨਰ",
        "subtitle": "ਕਦਮ ਦਰ ਕਦਮ ਹੱਲ ਸਹਾਇਕ",
        "keywords": "MathPro,ਗਣਿਤ,ਸਮੀਕਰਨ,ਬੀਜਗਣਿਤ,ਜਿਓਮੈਟਰੀ,ਕੈਲਕੁਲੇਟਰ,ਪ੍ਰੀਖਿਆ,ਫਾਰਮੂਲਾ,ਕੈਮਰਾ,ਪੜ੍ਹਾਈ,PSEB,ਬੋਰਡ",
        "promoText": "ਕਿਸੇ ਵੀ ਗਣਿਤ ਸਮੱਸਿਆ ਦੀ ਫੋਟੋ ਖਿੱਚੋ ਅਤੇ AI ਤੋਂ ਤੁਰੰਤ ਕਦਮ ਦਰ ਕਦਮ ਹੱਲ ਪ੍ਰਾਪਤ ਕਰੋ। ਸਕੂਲ ਤੋਂ ਯੂਨੀਵਰਸਿਟੀ ਤੱਕ!",
        "description": f"""ਕੋਈ ਵੀ ਗਣਿਤ ਸਮੱਸਿਆ ਤੁਰੰਤ ਹੱਲ ਕਰੋ — ਬੱਸ ਫੋਟੋ ਖਿੱਚੋ!

AI ਗਣਿਤ ਸੌਲਵਰ ਅਡਵਾਂਸ ਆਰਟੀਫਿਸ਼ੀਅਲ ਇੰਟੈਲੀਜੈਂਸ ਦੀ ਵਰਤੋਂ ਕਰਕੇ ਫੋਟੋ ਤੋਂ ਗਣਿਤ ਸਮੱਸਿਆਵਾਂ ਨੂੰ ਸਕੈਨ, ਪਛਾਣ ਅਤੇ ਹੱਲ ਕਰਦਾ ਹੈ। ਪਾਠ-ਪੁਸਤਕ ਦਾ ਸਵਾਲ ਹੋਵੇ, ਹੱਥ ਨਾਲ ਲਿਖਿਆ ਸਮੀਕਰਨ ਹੋਵੇ ਜਾਂ ਹੋਮਵਰਕ — ਕੈਮਰਾ ਦਿਖਾਓ ਅਤੇ ਸਕਿੰਟਾਂ ਵਿੱਚ ਵਿਸਤ੍ਰਿਤ ਕਦਮ ਦਰ ਕਦਮ ਹੱਲ ਪ੍ਰਾਪਤ ਕਰੋ।

ਤੁਸੀਂ ਕੀ ਕਰ ਸਕਦੇ ਹੋ:
- ਕਿਸੇ ਵੀ ਗਣਿਤ ਸਮੱਸਿਆ ਦੀ ਫੋਟੋ ਖਿੱਚੋ ਜਾਂ ਗੈਲਰੀ ਤੋਂ ਇੰਪੋਰਟ ਕਰੋ
- ਹੱਲ ਕਰਨ ਵਾਲੀ ਸਮੱਸਿਆ ਨੂੰ ਕ੍ਰੌਪ ਕਰਕੇ ਚੁਣੋ
- ਪੂਰੇ ਕਦਮ ਦਰ ਕਦਮ ਸਪੱਸ਼ਟੀਕਰਨ ਨਾਲ AI ਹੱਲ ਪ੍ਰਾਪਤ ਕਰੋ
- ਖੋਜਣਯੋਗ ਇਤਿਹਾਸ ਵਿੱਚ ਸਾਰੀਆਂ ਹੱਲ ਕੀਤੀਆਂ ਸਮੱਸਿਆਵਾਂ ਦੇਖੋ
- ਸੁੰਦਰ ਚਿੱਤਰਾਂ ਵਜੋਂ ਹੱਲ ਸਾਂਝੇ ਕਰੋ

ਗਣਿਤ ਵਿਸ਼ੇ:
- ਅੰਕ ਗਣਿਤ ਅਤੇ ਮੁੱਢਲਾ ਗਣਿਤ
- ਬੀਜਗਣਿਤ ਅਤੇ ਰੇਖਿਕ ਬੀਜਗਣਿਤ
- ਜਿਓਮੈਟਰੀ ਅਤੇ ਤ੍ਰਿਕੋਣਮਿਤੀ
- ਕੈਲਕੁਲਸ ਅਤੇ ਡਿਫਰੈਂਸ਼ੀਅਲ ਸਮੀਕਰਨ
- ਅੰਕੜਾ ਵਿਗਿਆਨ ਅਤੇ ਸੰਭਾਵਨਾ

PSEB ਬੋਰਡ ਪ੍ਰੀਖਿਆ ਦੀ ਤਿਆਰੀ ਲਈ ਸਹੀ!

ਸਬਸਕ੍ਰਿਪਸ਼ਨ ਜਾਣਕਾਰੀ:
ਕੁਝ ਵਿਸ਼ੇਸ਼ਤਾਵਾਂ ਲਈ ਪੂਰੀ ਪਹੁੰਚ ਲਈ ਸਰਗਰਮ ਸਬਸਕ੍ਰਿਪਸ਼ਨ ਲੋੜੀਂਦੀ ਹੈ।
- ਸਬਸਕ੍ਰਿਪਸ਼ਨ ਵਿਕਲਪ: ਹਫ਼ਤਾਵਾਰੀ ਅਤੇ ਸਾਲਾਨਾ ਯੋਜਨਾਵਾਂ ਉਪਲਬਧ
- ਖਰੀਦ ਦੀ ਪੁਸ਼ਟੀ 'ਤੇ ਤੁਹਾਡੇ Apple ID ਖਾਤੇ ਤੋਂ ਭੁਗਤਾਨ ਲਿਆ ਜਾਂਦਾ ਹੈ
- ਮੌਜੂਦਾ ਅਵਧੀ ਖਤਮ ਹੋਣ ਤੋਂ ਘੱਟੋ ਘੱਟ 24 ਘੰਟੇ ਪਹਿਲਾਂ ਰੱਦ ਨਾ ਕੀਤੀ ਜਾਵੇ ਤਾਂ ਸਬਸਕ੍ਰਿਪਸ਼ਨ ਆਪਣੇ ਆਪ ਨਵਿਆਈ ਜਾਂਦੀ ਹੈ
- ਖਰੀਦ ਤੋਂ ਬਾਅਦ Apple ID ਖਾਤਾ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਆਪਣੀਆਂ ਸਬਸਕ੍ਰਿਪਸ਼ਨਾਂ ਦਾ ਪ੍ਰਬੰਧਨ ਅਤੇ ਰੱਦ ਕਰ ਸਕਦੇ ਹੋ

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",
    },

    # ── Slovenian ──────────────────────────────────────────────
    "sl-SI": {
        "name": "AI Resevanje Matematike - Sken",
        "subtitle": "Resitve po Korakih",
        "keywords": "MathPro,algebra,enacba,geometrija,kalkulator,naloga,matura,formula,ucenje,foto,racunanje,izpit",
        "promoText": "Fotografirajte katerikoli matematicni problem in dobite AI resitve po korakih. Od osnovne sole do mature — vas osebni ucitelj!",
        "description": f"""Rešite katerikoli matematicni problem takoj — samo fotografirajte!

AI Resevanje Matematike uporablja napredno umetno inteligenco za skeniranje, prepoznavanje in resevanje matematicnih problemov s fotografije. Bodisi je vprasanje iz ucbenika, rocno napisana enacba ali domaca naloga — usmerite kamero in v sekundah dobite podrobno resitev po korakih.

KAJ LAHKO STORITE:
- Fotografirajte katerikoli matematicni problem ali uvozite iz galerije
- Obrezhite in izberite natancno problem, ki ga zelite resiti
- Dobite takojsnje AI resitve s popolnimi razlagami po korakih
- Preglejte vse resene probleme v iskalnem zgodovini
- Delite resitve kot lepe slike

MATEMATICNE TEME:
- Aritmetika in osnovna matematika
- Algebra in linearna algebra
- Geometrija in trigonometrija
- Analiza in diferencialne enacbe
- Statistika in verjetnost
- Besedilne naloge

PRILAGODI SE VASI RAVNI:
Izberite svojo raven izobrazbe — Osnovna sola, Srednja sola, Matura ali Univerza — in AI prilagodi svoje razlage. Preprost jezik za mlajse ucence, podrobni dokazi za napredne.

Idealno za pripravo na maturo!

INFORMACIJE O NAROCNINI:
Nekatere funkcije zahtevajo aktivno narocnino za poln dostop.
- Moznosti narocnine: na voljo Tedenska in Letna narocnina
- Placilo se zaracuna na vas racun Apple ID ob potrditvi nakupa
- Narocnina se samodejno obnovi, razen ce je preklicana vsaj 24 ur pred koncem tekocega obdobja
- Vas racun bo bremenjen za obnovo v 24 urah pred koncem tekocega obdobja
- Svoje narocnine lahko upravljate in preklicete v nastavitvah racuna Apple ID po nakupu

Politika zasebnosti: {PRIVACY_URL}
Pogoji uporabe: {TERMS_URL}""",
    },

    # ── Tamil ──────────────────────────────────────────────────
    "ta-IN": {
        "name": "AI கணிதம் தீர்வு - புகைப்பட ஸ்கேனர்",
        "subtitle": "படிப்படியான தீர்வு உதவி",
        "keywords": "MathPro,கணிதம்,சமன்பாடு,இயற்கணிதம்,வடிவியல்,கால்குலேட்டர்,தேர்வு,சூத்திரம்,கேமரா,படிப்பு,TNPSC,பதில்",
        "promoText": "எந்த கணிதப் பிரச்சனையின் புகைப்படமும் எடுங்கள், AI யிலிருந்து உடனடி படிப்படியான தீர்வு பெறுங்கள். பள்ளி முதல் பல்கலைக்கழகம் வரை!",
        "description": f"""எந்த கணிதப் பிரச்சனையையும் உடனடியாக தீர்க்கவும் — புகைப்படம் எடுங்கள்!

AI கணிதம் தீர்வு மேம்பட்ட செயற்கை நுண்ணறிவைப் பயன்படுத்தி புகைப்படத்திலிருந்து கணிதப் பிரச்சனைகளை ஸ்கேன் செய்து, அடையாளம் கண்டு, தீர்க்கிறது. பாடநூல் கேள்வி, கையெழுத்து சமன்பாடு அல்லது வீட்டுப்பாடம் — கேமராவை நோக்குங்கள், நொடிகளில் விரிவான படிப்படியான தீர்வு பெறுங்கள்.

நீங்கள் என்ன செய்யலாம்:
- எந்த கணிதப் பிரச்சனையின் புகைப்படமும் எடுக்கலாம் அல்லது கேலரியிலிருந்து இறக்குமதி செய்யலாம்
- தீர்க்க வேண்டிய பிரச்சனையை வெட்டி தேர்ந்தெடுக்கலாம்
- முழுமையான படிப்படியான விளக்கத்துடன் AI தீர்வுகள் பெறலாம்
- தேடக்கூடிய வரலாற்றில் அனைத்து தீர்வுகளையும் பார்க்கலாம்
- அழகான படங்களாக தீர்வுகளைப் பகிரலாம்

கணிதப் பொருட்கள்:
- எண்கணிதம் மற்றும் அடிப்படை கணிதம்
- இயற்கணிதம் மற்றும் நேரியல் இயற்கணிதம்
- வடிவியல் மற்றும் முக்கோணவியல்
- நுண்கணிதம் மற்றும் வகையீட்டு சமன்பாடுகள்
- புள்ளியியல் மற்றும் நிகழ்தகவு

10th, 12th மற்றும் போர்டு தேர்வுக்கு தயாராக சிறந்தது!

சந்தா தகவல்:
சில அம்சங்களுக்கு முழு அணுகலுக்கு செயலில் உள்ள சந்தா தேவை.
- சந்தா விருப்பங்கள்: வாராந்திர மற்றும் வருடாந்திர திட்டங்கள் கிடைக்கும்
- வாங்குதல் உறுதிப்படுத்தலின் போது உங்கள் Apple ID கணக்கிலிருந்து பணம் வசூலிக்கப்படும்
- தற்போதைய காலம் முடிவதற்கு குறைந்தது 24 மணி நேரத்திற்கு முன் ரத்து செய்யாவிடில் சந்தா தானாகவே புதுப்பிக்கப்படும்
- வாங்கிய பிறகு Apple ID கணக்கு அமைப்புகளில் உங்கள் சந்தாக்களை நிர்வகிக்கலாம் மற்றும் ரத்து செய்யலாம்

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",
    },

    # ── Telugu ─────────────────────────────────────────────────
    "te-IN": {
        "name": "AI గణితం సాల్వర్ - ఫోటో స్కానర్",
        "subtitle": "దశల వారీగా పరిష్కారం",
        "keywords": "MathPro,గణితం,సమీకరణం,బీజగణితం,జ్యామితి,కాలిక్యులేటర్,పరీక్ష,సూత్రం,కెమెరా,చదువు,AP,TS,బోర్డు",
        "promoText": "ఏ గణిత సమస్య ఫోటో తీయండి మరియు AI నుండి వెంటనే దశల వారీగా పరిష్కారం పొందండి. స్కూల్ నుండి యూనివర్సిటీ వరకు!",
        "description": f"""ఏ గణిత సమస్యనైనా వెంటనే పరిష్కరించండి — ఫోటో తీయండి!

AI గణితం సాల్వర్ అధునాతన కృత్రిమ మేధస్సును ఉపయోగించి ఫోటో నుండి గణిత సమస్యలను స్కాన్ చేసి, గుర్తించి, పరిష్కరిస్తుంది. పాఠ్యపుస్తక ప్రశ్న, చేతిరాత సమీకరణం లేదా హోమ్‌వర్క్ — కెమెరా చూపించండి, సెకన్లలో వివరమైన దశల వారీ పరిష్కారం పొందండి.

మీరు ఏమి చేయవచ్చు:
- ఏ గణిత సమస్య ఫోటో అయినా తీయండి లేదా గ్యాలరీ నుండి దిగుమతి చేయండి
- పరిష్కరించాల్సిన సమస్యను క్రాప్ చేసి ఎంచుకోండి
- పూర్తి దశల వారీ వివరణతో AI పరిష్కారాలు పొందండి
- శోధించగల చరిత్రలో అన్ని పరిష్కారాలు చూడండి
- అందమైన చిత్రాలుగా పరిష్కారాలు షేర్ చేయండి

గణిత అంశాలు:
- అంకగణితం మరియు ప్రాథమిక గణితం
- బీజగణితం మరియు సరళ బీజగణితం
- జ్యామితి మరియు త్రికోణమితి
- కాలిక్యులస్ మరియు అవకలన సమీకరణాలు
- గణాంకశాస్త్రం మరియు సంభావ్యత

AP/TS బోర్డు పరీక్షల తయారీకి అద్భుతం!

సబ్‌స్క్రిప్షన్ సమాచారం:
కొన్ని ఫీచర్లకు పూర్తి యాక్సెస్ కోసం యాక్టివ్ సబ్‌స్క్రిప్షన్ అవసరం.
- సబ్‌స్క్రిప్షన్ ఎంపికలు: వారపు మరియు వార్షిక ప్లాన్‌లు అందుబాటులో ఉన్నాయి
- కొనుగోలు నిర్ధారణ సమయంలో మీ Apple ID ఖాతా నుండి చెల్లింపు వసూలు చేయబడుతుంది
- ప్రస్తుత వ్యవధి ముగియడానికి కనీసం 24 గంటల ముందు రద్దు చేయకపోతే సబ్‌స్క్రిప్షన్ స్వయంచాలకంగా రెన్యూ అవుతుంది
- కొనుగోలు తర్వాత Apple ID ఖాతా సెట్టింగ్‌లలో మీ సబ్‌స్క్రిప్షన్‌లను నిర్వహించవచ్చు మరియు రద్దు చేయవచ్చు

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",
    },

    # ── Urdu ───────────────────────────────────────────────────
    "ur-PK": {
        "name": "AI ریاضی حل کرنے والا - فوٹو اسکینر",
        "subtitle": "قدم بہ قدم حل معاون",
        "keywords": "MathPro,ریاضی,مساوات,الجبرا,جیومیٹری,کیلکولیٹر,امتحان,فارمولا,کیمرہ,پڑھائی,بورڈ,جواب,میٹرک",
        "promoText": "کسی بھی ریاضی کے مسئلے کی تصویر لیں اور AI سے فوری قدم بہ قدم حل حاصل کریں۔ سکول سے یونیورسٹی تک — آپ کا ذاتی ریاضی استاد!",
        "description": f"""کوئی بھی ریاضی کا مسئلہ فوری طور پر حل کریں — بس ایک تصویر لیں!

AI ریاضی حل کرنے والا جدید مصنوعی ذہانت استعمال کرتے ہوئے تصویر سے ریاضی کے مسائل کو سکین، پہچان اور حل کرتا ہے۔ نصابی کتاب کا سوال ہو، ہاتھ سے لکھی مساوات ہو یا ہوم ورک — کیمرہ دکھائیں اور سیکنڈوں میں تفصیلی قدم بہ قدم حل حاصل کریں۔

آپ کیا کر سکتے ہیں:
- کسی بھی ریاضی کے مسئلے کی تصویر لیں یا گیلری سے درآمد کریں
- حل کرنے والے مسئلے کو کراپ کرکے منتخب کریں
- مکمل قدم بہ قدم وضاحت کے ساتھ AI حل حاصل کریں
- تلاش کے قابل تاریخ میں تمام حل شدہ مسائل دیکھیں
- خوبصورت تصاویر کے طور پر حل شیئر کریں

ریاضی کے موضوعات:
- حساب اور بنیادی ریاضی
- الجبرا اور لکیری الجبرا
- جیومیٹری اور مثلثیات
- کیلکولس اور تفاضلی مساوات
- شماریات اور امکانات
- لفظی مسائل

میٹرک، انٹرمیڈیٹ اور بورڈ امتحانات کی تیاری کے لیے بہترین!

سبسکرپشن معلومات:
کچھ خصوصیات کے لیے مکمل رسائی کے لیے فعال سبسکرپشن ضروری ہے۔
- سبسکرپشن اختیارات: ہفتہ وار اور سالانہ پلان دستیاب ہیں
- خریداری کی تصدیق پر آپ کے Apple ID اکاؤنٹ سے ادائیگی وصول کی جاتی ہے
- موجودہ مدت ختم ہونے سے کم از کم 24 گھنٹے پہلے منسوخ نہ کیا جائے تو سبسکرپشن خود بخود تجدید ہوتی ہے
- خریداری کے بعد Apple ID اکاؤنٹ سیٹنگز میں اپنی سبسکرپشنز کا انتظام اور منسوخی کر سکتے ہیں

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",
    },
}


def main():
    print("=" * 60)
    print("MathPro - 11 New Languages Metadata Uploader")
    print(f"  Languages: {', '.join(sorted(LOCALES.keys()))}")
    print("=" * 60)

    # Get IDs
    print("\n[1] Finding app...")
    data = api_get("/apps", {"filter[bundleId]": BUNDLE_ID})
    app_id = data["data"][0]["id"]
    print(f"  App: {data['data'][0]['attributes']['name']} ({app_id})")

    print("\n[2] Getting App Info...")
    data = api_get(f"/apps/{app_id}/appInfos")
    app_info_id = data["data"][0]["id"]

    print("\n[3] Getting Version...")
    data = api_get(f"/apps/{app_id}/appStoreVersions", {"filter[platform]": "IOS", "limit": 1})
    version_id = data["data"][0]["id"]
    print(f"  Version: {data['data'][0]['attributes']['versionString']}")

    # Get existing localizations
    print("\n[4] Getting existing localizations...")
    info_locs = {}
    ver_locs = {}

    # App Info localizations
    all_info = []
    url = f"{BASE}/appInfos/{app_info_id}/appInfoLocalizations"
    params = {"limit": 50}
    while url:
        resp = requests.get(url, headers=hdrs(), params=params)
        if resp.status_code != 200:
            break
        rdata = resp.json()
        all_info.extend(rdata.get("data", []))
        url = rdata.get("links", {}).get("next")
        params = {}
    info_locs = {l["attributes"]["locale"]: l["id"] for l in all_info}

    # Version localizations
    all_ver = []
    url = f"{BASE}/appStoreVersions/{version_id}/appStoreVersionLocalizations"
    params = {"limit": 50}
    while url:
        resp = requests.get(url, headers=hdrs(), params=params)
        if resp.status_code != 200:
            break
        rdata = resp.json()
        all_ver.extend(rdata.get("data", []))
        url = rdata.get("links", {}).get("next")
        params = {}
    ver_locs = {l["attributes"]["locale"]: l["id"] for l in all_ver}

    print(f"  Info localizations: {len(info_locs)}")
    print(f"  Version localizations: {len(ver_locs)}")

    # Update/Create each locale
    print("\n[5] Uploading metadata for 11 new languages...")
    print("-" * 60)

    ok = 0
    fail = 0

    for locale, meta in sorted(LOCALES.items()):
        print(f"\n  [{locale}]")
        print(f"    Title: {meta['name']}")
        print(f"    Subtitle: {meta['subtitle']}")

        errors = False

        # ── App Info Localization (title + subtitle) ──
        if locale in info_locs:
            loc_id = info_locs[locale]
            success, resp = api_patch(f"/appInfoLocalizations/{loc_id}", {
                "data": {"type": "appInfoLocalizations", "id": loc_id,
                         "attributes": {"name": meta["name"], "subtitle": meta["subtitle"]}}
            })
            print(f"    {'✓' if success else '✗'} Title/Subtitle updated")
            if not success:
                errors = True
                try: print(f"      → {resp.json()['errors'][0]['detail']}")
                except: pass
        else:
            success, resp = api_post("/appInfoLocalizations", {
                "data": {"type": "appInfoLocalizations",
                         "attributes": {"locale": locale, "name": meta["name"], "subtitle": meta["subtitle"]},
                         "relationships": {"appInfo": {"data": {"type": "appInfos", "id": app_info_id}}}}
            })
            print(f"    {'✓' if success else '✗'} Title/Subtitle created")
            if not success:
                errors = True
                try: print(f"      → {resp.json()['errors'][0]['detail']}")
                except: print(f"      → {resp.text[:300]}")

        time.sleep(0.3)

        # Re-fetch version localizations (ASC may auto-create them)
        if locale not in ver_locs:
            time.sleep(1)
            all_ver2 = []
            url = f"{BASE}/appStoreVersions/{version_id}/appStoreVersionLocalizations"
            params = {"limit": 50}
            while url:
                resp = requests.get(url, headers=hdrs(), params=params)
                if resp.status_code != 200:
                    break
                rdata = resp.json()
                all_ver2.extend(rdata.get("data", []))
                url = rdata.get("links", {}).get("next")
                params = {}
            ver_locs = {l["attributes"]["locale"]: l["id"] for l in all_ver2}

        # ── Version Localization (keywords + promo + description) ──
        if locale in ver_locs:
            loc_id = ver_locs[locale]
            success, resp = api_patch(f"/appStoreVersionLocalizations/{loc_id}", {
                "data": {"type": "appStoreVersionLocalizations", "id": loc_id,
                         "attributes": {
                             "keywords": meta["keywords"],
                             "promotionalText": meta["promoText"],
                             "description": meta["description"],
                         }}
            })
            print(f"    {'✓' if success else '✗'} Keywords/Promo/Desc updated")
            if not success:
                errors = True
                try: print(f"      → {resp.json()['errors'][0]['detail']}")
                except: print(f"      → {resp.text[:300]}")
        else:
            # Create new version localization
            success, resp = api_post("/appStoreVersionLocalizations", {
                "data": {"type": "appStoreVersionLocalizations",
                         "attributes": {
                             "locale": locale,
                             "keywords": meta["keywords"],
                             "promotionalText": meta["promoText"],
                             "description": meta["description"],
                         },
                         "relationships": {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}}}}
            })
            print(f"    {'✓' if success else '✗'} Keywords/Promo/Desc created")
            if not success:
                errors = True
                try: print(f"      → {resp.json()['errors'][0]['detail']}")
                except: print(f"      → {resp.text[:300]}")

        if errors:
            fail += 1
        else:
            ok += 1

        time.sleep(0.3)

    print("\n" + "=" * 60)
    print(f"DONE! ✓ {ok} succeeded, ✗ {fail} failed (out of {len(LOCALES)} locales)")
    print("=" * 60)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
App Store Connect - Full Metadata Updater
Updates title, subtitle, keywords, promotional text, and description for all 39 locales.
Removes brand name from title (moves to keywords) to maximize keyword space.
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


def api_get_all(path, params=None):
    """GET with pagination."""
    results = []
    url = f"{BASE}{path}"
    p = params or {}
    p["limit"] = 50
    while url:
        resp = requests.get(url, headers=hdrs(), params=p)
        if resp.status_code != 200:
            return results
        data = resp.json()
        results.extend(data.get("data", []))
        url = data.get("links", {}).get("next")
        p = {}  # params only for first request
    return results


def api_patch(path, data):
    resp = requests.patch(f"{BASE}{path}", headers=hdrs(), json=data)
    return resp.status_code == 200, resp


def api_post(path, data):
    resp = requests.post(f"{BASE}{path}", headers=hdrs(), json=data)
    return resp.status_code in (200, 201), resp


# ══════════════════════════════════════════════════════════════
# METADATA DEFINITIONS - All 39 locales
# Strategy: No brand in title → more keywords. Brand goes to keyword field.
# Title/subtitle use competitor keyword combinations (rearranged).
# ══════════════════════════════════════════════════════════════

LOCALES = {
    "en-US": {
        "name": "AI Math Solver - Photo Scanner",  # 30 chars | Symbolab "AI Math Solver" + Mathway "scanner"
        "subtitle": "Step-by-Step Homework Helper",  # 27 chars | Photomath "step-by-step" + Mathway "homework"
        "keywords": "MathPro,problem,calculator,equation,algebra,calculus,geometry,tutor,camera,learn,practice,study,answer,trigonometry",
        "promoText": "Snap a photo of any math problem and get instant AI-powered step-by-step solutions. From algebra to calculus — your personal math tutor is here!",
    },
    "en-GB": {
        "name": "AI Maths Solver - Photo Scanner",  # 31 → trim
        "subtitle": "Step-by-Step Homework Helper",
        "keywords": "MathPro,problem,calculator,GCSE,A-level,revision,equation,algebra,calculus,tutor,camera,learn,answer",
        "promoText": "Snap a photo of any maths problem and get instant AI-powered step-by-step solutions. From GCSE to A-level — your personal maths tutor is here!",
    },
    "en-AU": {
        "name": "AI Maths Solver - Photo Scanner",
        "subtitle": "Step-by-Step Homework Helper",
        "keywords": "MathPro,problem,calculator,HSC,VCE,ATAR,equation,algebra,calculus,tutor,camera,learn,answer",
        "promoText": "Snap a photo of any maths problem and get instant AI-powered step-by-step solutions. From Year 7 to university — your personal maths tutor!",
    },
    "en-CA": {
        "name": "AI Math Solver - Photo Scanner",
        "subtitle": "Step-by-Step Homework Helper",
        "keywords": "MathPro,problem,calculator,equation,algebra,calculus,geometry,tutor,camera,learn,practice,study,answer",
        "promoText": "Snap a photo of any math problem and get instant AI-powered step-by-step solutions. From algebra to calculus — your personal math tutor is here!",
    },
    "fr-FR": {
        "name": "Solveur Maths IA - Photo Scan",  # 29
        "subtitle": "Solutions Pas-a-Pas & Devoirs",  # 29
        "keywords": "MathPro,exercice,BAC,brevet,algebre,equation,geometrie,calcul,lycee,college,resoudre,aide,formule,camera",
        "promoText": "Prenez en photo un probleme de maths et obtenez des solutions detaillees etape par etape grace a l'IA. Du college au BAC, votre tuteur personnel!",
    },
    "fr-CA": {
        "name": "Solveur Maths IA - Photo Scan",
        "subtitle": "Solutions Pas-a-Pas & Devoirs",
        "keywords": "MathPro,exercice,algebre,equation,geometrie,calcul,secondaire,cegep,resoudre,aide,formule,camera,tuteur",
        "promoText": "Prenez en photo un probleme de maths et obtenez des solutions detaillees etape par etape grace a l'IA. Du secondaire au CEGEP, votre tuteur!",
    },
    "de-DE": {
        "name": "KI Mathe Loser - Foto Scanner",  # 29
        "subtitle": "Schritt-fur-Schritt Losungen",  # 28
        "keywords": "MathPro,Abitur,Aufgaben,Gleichung,Algebra,Rechner,Hausaufgaben,Geometrie,Nachhilfe,Formel,lernen,Klausur",
        "promoText": "Fotografiere jede Matheaufgabe und erhalte sofort KI-gestutzte Schritt-fur-Schritt-Losungen. Vom Gymnasium bis zum Abitur — dein Mathe-Nachhilfelehrer!",
    },
    "es-ES": {
        "name": "Resolver Mates IA - Escaner",  # 27
        "subtitle": "Soluciones Paso a Paso Tareas",  # 29
        "keywords": "MathPro,algebra,ecuacion,geometria,calculo,foto,examen,selectividad,tutor,ayuda,ejercicio,formula,camara",
        "promoText": "Haz una foto de cualquier problema de mates y obtiene soluciones paso a paso con IA. De la ESO a Selectividad, tu tutor de matematicas personal!",
    },
    "es-MX": {
        "name": "Resolver Mates IA - Escaner",
        "subtitle": "Paso a Paso Tareas y Ayuda",  # 26
        "keywords": "MathPro,algebra,ecuacion,geometria,calculo,foto,examen,prepa,UNAM,tutor,ejercicio,formula,camara",
        "promoText": "Toma una foto de cualquier problema de mates y obtiene soluciones paso a paso con IA. De la prepa a la universidad, tu tutor personal!",
    },
    "pt-BR": {
        "name": "Resolver Matematica IA - Foto",  # 29
        "subtitle": "Solucoes Passo a Passo Dever",  # 28
        "keywords": "MathPro,ENEM,vestibular,algebra,equacao,geometria,calculo,exercicio,formula,prova,estudar,camera,calculadora",
        "promoText": "Tire uma foto de qualquer problema de matematica e receba solucoes passo a passo com IA. Do ensino medio ao ENEM — seu tutor pessoal!",
    },
    "pt-PT": {
        "name": "Resolver Matematica IA - Foto",
        "subtitle": "Solucoes Passo a Passo",  # 22
        "keywords": "MathPro,algebra,equacao,geometria,calculo,exercicio,formula,exame,estudar,explicacoes,TPC,camera,calculadora",
        "promoText": "Tire uma foto de qualquer problema de matematica e receba solucoes passo a passo com IA. Do secundario ao exame — o seu explicador pessoal!",
    },
    "it": {
        "name": "Risolutore Mate IA - Scanner",  # 28
        "subtitle": "Soluzioni Passo Dopo Passo",  # 26
        "keywords": "MathPro,algebra,equazione,geometria,calcolo,foto,compiti,esercizio,maturita,formula,studio,aiuto,camera",
        "promoText": "Scatta una foto di qualsiasi problema di matematica e ottieni soluzioni passo dopo passo con l'IA. Dalla scuola alla maturita — il tuo tutor!",
    },
    "nl-NL": {
        "name": "AI Wiskunde Oplosser - Scanner",  # 30
        "subtitle": "Stap-voor-Stap Oplossingen",  # 26
        "keywords": "MathPro,algebra,vergelijking,meetkunde,rekenen,foto,huiswerk,eindexamen,formule,studeren,VWO,HAVO,camera",
        "promoText": "Maak een foto van elk wiskundeprobleem en krijg direct AI-gestuurde stap-voor-stap oplossingen. Van HAVO tot VWO — jouw persoonlijke bijles!",
    },
    "ja": {
        "name": "AI数学ソルバー 写真スキャナー",  # ~15 chars
        "subtitle": "ステップごと宿題ヘルパー",  # ~12
        "keywords": "MathPro,計算,方程式,関数,微積分,幾何,受験,共通テスト,数学アプリ,解き方,公式,勉強,代数,三角関数,カメラ",
        "promoText": "数学の問題を写真に撮るだけで、AIがステップごとに解説。小学校から大学まで、あなた専属の数学チューター!",
    },
    "ko": {
        "name": "AI 수학 풀이 - 사진 스캐너",  # ~15
        "subtitle": "단계별 풀이 숙제 도우미",  # ~12
        "keywords": "MathPro,수능,내신,방정식,함수,미적분,기하,기출,공부,공식,학원,콴다,대수,삼각함수,카메라,사진",
        "promoText": "수학 문제를 사진으로 찍으면 AI가 단계별로 풀이해드립니다. 중학교부터 수능까지, 나만의 수학 과외 선생님!",
    },
    "zh-Hans": {
        "name": "AI数学解题器 - 拍照搜题",  # ~12
        "subtitle": "分步解答 作业帮手",  # ~8
        "keywords": "MathPro,高考,中考,方程,代数,几何,微积分,公式,练习,计算器,小猿,函数,三角,统计,考试,辅导,答案,学习",
        "promoText": "拍照即可解题，AI智能分步解答。从小学到高考，你的专属数学辅导老师！",
    },
    "zh-Hant": {
        "name": "AI數學解題器 - 拍照搜題",
        "subtitle": "分步解答 作業幫手",
        "keywords": "MathPro,學測,指考,方程式,代數,幾何,微積分,公式,練習,計算機,作業,補習,國中,高中,函數,三角,統計",
        "promoText": "拍照即可解題，AI智慧分步解答。從國中到學測，你的專屬數學輔導老師！",
    },
    "ar-SA": {
        "name": "حل مسائل رياضيات AI - ماسح",  # ~27
        "subtitle": "حلول خطوة بخطوة واجبات",  # ~22
        "keywords": "MathPro,جبر,هندسة,معادلة,حساب,كاميرا,ثانوية,تفاضل,امتحان,قدرات,تحصيلي,صورة,دراسة,آلة حاسبة",
        "promoText": "صور اي مسألة رياضيات واحصل على حلول فورية خطوة بخطوة بالذكاء الاصطناعي. من الابتدائية الى الجامعة!",
    },
    "tr": {
        "name": "AI Matematik Cozucu - Tarayici",  # 30
        "subtitle": "Adim Adim Cozum & Odev Yardim",  # 29
        "keywords": "MathPro,YKS,TYT,AYT,denklem,geometri,cebir,foto,sinav,formul,ders,calisma,LGS,universite,hesap",
        "promoText": "Matematik problemini fotografla, AI aninda adim adim cozum uretsin. Ilkokuldan YKS'ye kadar — senin kisisel matematik ogretmenin!",
    },
    "ru": {
        "name": "AI Решатель Математики Скан",  # ~27
        "subtitle": "Пошаговые Решения и ГДЗ",  # 23
        "keywords": "MathPro,ЕГЭ,ОГЭ,алгебра,уравнение,геометрия,фото,формула,задача,калькулятор,учёба,репетитор,камера",
        "promoText": "Сфотографируйте любую задачу по математике и получите пошаговое решение с помощью ИИ. От школы до ЕГЭ — ваш персональный репетитор!",
    },
    "hi": {
        "name": "AI Math Solver - Photo Scanner",
        "subtitle": "Step-by-Step Homework Helper",
        "keywords": "MathPro,JEE,NEET,algebra,equation,geometry,calculus,CBSE,ICSE,padhai,ganit,kaksha,board,camera",
        "promoText": "Kisi bhi math problem ki photo lo aur AI se turant step-by-step solution pao. School se JEE tak — aapka personal math tutor!",
    },
    "he": {
        "name": "פותר מתמטיקה AI - סורק תמונות",  # ~18
        "subtitle": "פתרונות צעד אחר צעד",  # 19
        "keywords": "MathPro,אלגברה,משוואה,גיאומטריה,חשבון,שיעורי בית,בגרות,נוסחה,לימודים,חדו״א,טריגו,מצלמה",
        "promoText": "צלמו כל בעיית מתמטיקה וקבלו פתרון מיידי צעד אחר צעד בעזרת AI. מחטיבה ועד בגרות — המורה הפרטי שלכם!",
    },
    "hr": {
        "name": "AI Rjesavac Matematike - Sken",  # 29
        "subtitle": "Rjesenja Korak po Korak",  # 23
        "keywords": "MathPro,algebra,jednadzba,geometrija,kalkulator,zadaca,matura,formula,ucenje,foto,racun,ispit,kamera",
        "promoText": "Fotografirajte matematicki problem i dobijte AI rjesenja korak po korak. Od osnovne do mature — vas osobni tutor!",
    },
    "cs": {
        "name": "AI Resite Matematiky - Skener",  # 29
        "subtitle": "Reseni Krok za Krokem",  # 21
        "keywords": "MathPro,algebra,rovnice,geometrie,kalkulacka,ukol,maturita,vzorec,studium,foto,pocty,zkouska,kamera",
        "promoText": "Vyfoťte jakýkoliv matematicky priklad a ziskejte AI reseni krok za krokem. Od zakladky po maturitu — vas osobni doučovatel!",
    },
    "da": {
        "name": "AI Matematik Loser - Skanner",  # 28
        "subtitle": "Trin-for-Trin Losninger",  # 23
        "keywords": "MathPro,algebra,ligning,geometri,lommeregner,lektier,eksamen,formel,studie,foto,beregning,HF,STX,kamera",
        "promoText": "Tag et foto af ethvert matematikproblem og fa AI-drevne losninger trin for trin. Fra folkeskole til gymnasium — din personlige tutor!",
    },
    "fi": {
        "name": "AI Matikan Ratkaisija - Skanneri",  # 31 → needs trim
        "subtitle": "Vaihe Vaiheelta Ratkaisut",  # 25
        "keywords": "MathPro,algebra,yhtalot,geometria,laskin,lasky,ylioppilaskoe,kaava,opiskelu,kuva,matematiikka,kamera",
        "promoText": "Ota kuva mista tahansa matikkaongelmasta ja saat AI-ratkaisun vaihe vaiheelta. Peruskoulusta ylioppilaaseen — oma matikkaopettajasi!",
    },
    "el": {
        "name": "AI Λύτης Μαθηματικών Σαρωτής",  # ~18
        "subtitle": "Λύσεις Βήμα προς Βήμα",  # ~14
        "keywords": "MathPro,άλγεβρα,εξίσωση,γεωμετρία,αριθμομηχανή,Πανελλήνιες,τύπος,μελέτη,φωτο,λύκειο,ασκηση,κάμερα",
        "promoText": "Φωτογραφίστε οποιοδήποτε μαθηματικό πρόβλημα και λάβετε λύσεις βήμα προς βήμα με AI. Από το γυμνάσιο ως τις Πανελλήνιες!",
    },
    "hu": {
        "name": "AI Matek Megoldo - Szkenner",  # 27
        "subtitle": "Lepesrol Lepesre Megoldasok",  # 27
        "keywords": "MathPro,algebra,egyenlet,geometria,szamologep,hazitanulas,erettsegi,keplet,tanulas,foto,kamera",
        "promoText": "Fotózd le bármely matekfeladatot és kapj AI-alapú megoldást lépésről lépésre. Általánostól az érettségiig — személyes tanárod!",
    },
    "id": {
        "name": "AI Pemecah Matematika - Scan",  # 28
        "subtitle": "Solusi Langkah demi Langkah",  # 27
        "keywords": "MathPro,aljabar,persamaan,geometri,kalkulator,PR,UTBK,rumus,belajar,foto,soal,ujian,les,SNBT,kamera",
        "promoText": "Foto soal matematika apapun dan dapatkan solusi langkah demi langkah dengan AI. Dari SD sampai UTBK — tutor pribadi kamu!",
    },
    "ms": {
        "name": "AI Penyelesai Matematik - Scan",  # 30
        "subtitle": "Penyelesaian Langkah demi",  # 24
        "keywords": "MathPro,algebra,persamaan,geometri,kalkulator,kerja rumah,SPM,formula,belajar,foto,soalan,UPSR,kamera",
        "promoText": "Ambil gambar sebarang masalah matematik dan dapatkan penyelesaian langkah demi langkah dengan AI. Dari UPSR ke SPM — tutor peribadi anda!",
    },
    "no": {
        "name": "AI Matte Loser - Foto Skanner",  # 29
        "subtitle": "Steg-for-Steg Losninger",  # 23
        "keywords": "MathPro,algebra,likning,geometri,kalkulator,lekser,eksamen,formel,studie,matte,beregning,VGS,kamera",
        "promoText": "Ta bilde av et hvilket som helst matteproblem og fa AI-drevne losninger steg for steg. Fra ungdomsskole til VGS — din personlige tutor!",
    },
    "pl": {
        "name": "AI Rozwiaz Matematyke - Skan",  # 28
        "subtitle": "Rozwiazania Krok po Kroku",  # 25
        "keywords": "MathPro,algebra,rownanie,geometria,kalkulator,zadanie,matura,wzor,nauka,zdjecie,rachunek,egzamin,kamera",
        "promoText": "Zrob zdjecie dowolnego zadania z matematyki i uzyskaj rozwiazania AI krok po kroku. Od podstawowki do matury — Twoj osobisty korepetytor!",
    },
    "ro": {
        "name": "AI Rezolvator Mate - Scanner",  # 28
        "subtitle": "Solutii Pas cu Pas",  # 18
        "keywords": "MathPro,algebra,ecuatie,geometrie,calculator,tema,BAC,formula,studiu,foto,exercitiu,examen,camera",
        "promoText": "Fotografiaza orice problema de matematica si obtii solutii pas cu pas cu AI. De la generala pana la BAC — tutorele tau personal!",
    },
    "sk": {
        "name": "AI Riesitel Matematiky - Sken",  # 29
        "subtitle": "Riesenia Krok za Krokom",  # 23
        "keywords": "MathPro,algebra,rovnica,geometria,kalkulacka,uloha,maturita,vzorec,studium,foto,pocty,skuska,kamera",
        "promoText": "Odfoťte akýkoľvek matematický príklad a získajte AI riešenia krok za krokom. Od základky po maturitu — váš osobný doučovateľ!",
    },
    "sv": {
        "name": "AI Matte Losare - Foto Skanner",  # 30
        "subtitle": "Steg-for-Steg Losningar",  # 23
        "keywords": "MathPro,algebra,ekvation,geometri,kalkylator,laxor,prov,formel,studera,matte,berakning,NP,kamera",
        "promoText": "Ta en bild pa vilket matteproblem som helst och fa AI-drivna losningar steg for steg. Fran hogstadiet till NP — din personliga mattelektor!",
    },
    "th": {
        "name": "AI แก้โจทย์เลข - สแกนรูป",
        "subtitle": "เฉลยทีละขั้นตอน",
        "keywords": "MathPro,คณิตศาสตร์,สมการ,เรขาคณิต,เครื่องคิดเลข,การบ้าน,สอบ,สูตร,เรียน,GAT,PAT,O-NET,กล้อง,แคลคูลัส",
        "promoText": "ถ่ายรูปโจทย์เลขแล้วได้เฉลยทีละขั้นตอนจาก AI ทันที ตั้งแต่ประถมถึงมหาวิทยาลัย — ติวเตอร์ส่วนตัวของคุณ!",
    },
    "uk": {
        "name": "AI Розвʼязувач Матем - Скан",  # ~18
        "subtitle": "Покрокові Розвʼязки і ДПА",  # ~16
        "keywords": "MathPro,ЗНО,НМТ,алгебра,рівняння,геометрія,фото,формула,задача,калькулятор,навчання,урок,камера",
        "promoText": "Сфотографуйте будь-яку задачу з математики та отримайте покрокове розвʼязання з AI. Від школи до НМТ — ваш персональний репетитор!",
    },
    "vi": {
        "name": "AI Giai Toan - May Quet Anh",  # 27
        "subtitle": "Giai Chi Tiet Tung Buoc",  # 23
        "keywords": "MathPro,dai so,phuong trinh,hinh hoc,may tinh,bai tap,thi,cong thuc,hoc,THPT,lop,camera,anh",
        "promoText": "Chup anh bat ky bai toan nao va nhan loi giai chi tiet tung buoc tu AI. Tu cap 2 den THPT — gia su rieng cua ban!",
    },
    "ca": {
        "name": "AI Resol Matematiques - Scan",  # 28
        "subtitle": "Solucions Pas a Pas",  # 19
        "keywords": "MathPro,algebra,equacio,geometria,calculadora,deures,selectivitat,formula,estudi,foto,exercici,PAU,camera",
        "promoText": "Fes una foto de qualsevol problema de mates i obtingues solucions pas a pas amb IA. De l'ESO a la Selectivitat — el teu tutor personal!",
    },
}


# ══════════════════════════════════════════════════════════════
# DESCRIPTION TEMPLATES
# ══════════════════════════════════════════════════════════════

DESCRIPTIONS = {
    "en-US": """Solve any math problem instantly — just snap a photo!

AI Math Solver uses advanced artificial intelligence to scan, recognize, and solve math problems from a photo. Whether it's a textbook question, a handwritten equation, or a homework worksheet — point your camera and get a detailed step-by-step solution in seconds.

WHAT YOU CAN DO:
- Snap a photo of any math problem or import from your gallery
- Crop and select exactly the problem you want to solve
- Get instant AI-powered solutions with full step-by-step explanations
- Review all your solved problems in a searchable history
- Share solutions as beautiful images

MATH TOPICS COVERED:
- Arithmetic & Basic Math
- Algebra & Linear Algebra
- Geometry & Trigonometry
- Calculus & Differential Equations
- Statistics & Probability
- Word Problems & Data Sufficiency

ADAPTS TO YOUR LEVEL:
Choose your education level — Elementary, Middle School, High School, or University — and the AI adapts its explanations to match. Simple language for younger students, detailed proofs for advanced learners.

MULTI-LANGUAGE SUPPORT:
Solutions are delivered in your device's language. The AI understands and explains math in 10+ languages including English, Turkish, German, French, Spanish, Arabic, Chinese, Japanese, Korean, Russian, and more.

SUBSCRIPTION INFORMATION:
Some features require an active subscription to unlock full access.
- Subscription options: Weekly and Annual plans available
- Payment is charged to your Apple ID account at confirmation of purchase
- Subscription automatically renews unless canceled at least 24 hours before the end of the current period
- Your account will be charged for renewal within 24 hours prior to the end of the current period
- You can manage and cancel your subscriptions in your Apple ID Account Settings after purchase

Privacy Policy: {privacy}
Terms of Use: {terms}""".format(privacy=PRIVACY_URL, terms=TERMS_URL),

    "tr": """Herhangi bir matematik problemini aninda coz — sadece bir fotograf cek!

AI Matematik Cozucu, gelismis yapay zeka kullanarak fotograftan matematik problemlerini tarar, tanir ve cozer. Ister ders kitabi sorusu, ister el yazisi denklem, ister odev — kamerani dogrult ve saniyelerde detayli adim adim cozum al.

NELER YAPABiLiRSiN:
- Herhangi bir matematik probleminin fotografini cek veya galerinden yukle
- Cozemek istedigin problemi kirp ve sec
- AI destekli aninda cozumler al, tam adim adim aciklamalarla
- Cozulmus tum problemlerini aranabilir gecmiste incele
- Cozumleri guzel gorseller olarak paylas

KAPSANAN MATEMATiK KONULARI:
- Aritmetik ve Temel Matematik
- Cebir ve Lineer Cebir
- Geometri ve Trigonometri
- Kalkulus ve Diferansiyel Denklemler
- Istatistik ve Olasilik
- Sozel Problemler

SEViYENE UYUM SAGLAR:
Egitim seviyeni sec — Ilkokul, Ortaokul, Lise veya Universite — ve yapay zeka aciklamalarini seviyene gore uyarlar. Kucuk ogrenciler icin basit dil, ileri duzey ogrenciler icin detayli ispatlar.

YKS, TYT, AYT ve LGS hazirliginda sana yardimci olur!

ABONELiK BiLGiLERi:
Bazi ozellikler tam erisim icin aktif bir abonelik gerektirir.
- Abonelik secenekleri: Haftalik ve Yillik planlar mevcuttur
- Odeme, satin alma onayinda Apple Kimliginiz hesabinizdan tahsil edilir
- Abonelik, mevcut donem bitmeden en az 24 saat once iptal edilmedikce otomatik olarak yenilenir
- Hesabinizdan mevcut donemin bitiminden 24 saat once yenileme ucreti tahsil edilir
- Aboneliklerinizi satin alma sonrasinda Apple Kimliginiz Hesap Ayarlarindan yonetebilir ve iptal edebilirsiniz

Gizlilik Politikasi: {privacy}
Kullanim Kosullari: {terms}""".format(privacy=PRIVACY_URL, terms=TERMS_URL),
}

# For non-EN/TR locales, use English description as fallback
DEFAULT_DESC = DESCRIPTIONS["en-US"]


def main():
    print("=" * 60)
    print("MathPro - Full Metadata Updater (Title + Subtitle + Keywords")
    print("          + Promotional Text + Description)")
    print("=" * 60)

    # Get IDs
    print("\n[1] Finding app...")
    data = requests.get(f"{BASE}/apps", headers=hdrs(), params={"filter[bundleId]": BUNDLE_ID}).json()
    app_id = data["data"][0]["id"]
    print(f"  App: {data['data'][0]['attributes']['name']} ({app_id})")

    print("\n[2] Getting App Info...")
    data = requests.get(f"{BASE}/apps/{app_id}/appInfos", headers=hdrs()).json()
    app_info_id = data["data"][0]["id"]

    print("\n[3] Getting Version...")
    data = requests.get(f"{BASE}/apps/{app_id}/appStoreVersions", headers=hdrs(),
                        params={"filter[platform]": "IOS", "limit": 1}).json()
    version_id = data["data"][0]["id"]
    print(f"  Version: {data['data'][0]['attributes']['versionString']}")

    # Get existing localizations
    print("\n[4] Getting existing localizations...")
    info_locs = {l["attributes"]["locale"]: l["id"] for l in api_get_all(f"/appInfos/{app_info_id}/appInfoLocalizations")}
    ver_locs = {l["attributes"]["locale"]: l["id"] for l in api_get_all(f"/appStoreVersions/{version_id}/appStoreVersionLocalizations")}
    print(f"  Info: {len(info_locs)}, Version: {len(ver_locs)}")

    # Update each locale
    print("\n[5] Updating metadata...")
    print("-" * 60)

    ok = 0
    fail = 0

    for locale, meta in sorted(LOCALES.items()):
        print(f"\n  [{locale}]")
        name = meta["name"]
        subtitle = meta["subtitle"]
        keywords = meta["keywords"]
        promo = meta["promoText"]
        desc = DESCRIPTIONS.get(locale, DEFAULT_DESC)

        errors = False

        # Update App Info (name + subtitle)
        if locale in info_locs:
            success, resp = api_patch(f"/appInfoLocalizations/{info_locs[locale]}", {
                "data": {"type": "appInfoLocalizations", "id": info_locs[locale],
                         "attributes": {"name": name, "subtitle": subtitle}}
            })
            print(f"    {'✓' if success else '✗'} Title/Subtitle {'updated' if success else 'FAILED'}")
            if not success:
                errors = True
                # Try to show error detail
                try:
                    err = resp.json()["errors"][0]["detail"]
                    print(f"      → {err}")
                except:
                    pass
        else:
            success, resp = api_post("/appInfoLocalizations", {
                "data": {"type": "appInfoLocalizations",
                         "attributes": {"locale": locale, "name": name, "subtitle": subtitle},
                         "relationships": {"appInfo": {"data": {"type": "appInfos", "id": app_info_id}}}}
            })
            print(f"    {'✓' if success else '✗'} Title/Subtitle {'created' if success else 'FAILED'}")
            if not success:
                errors = True

        # Update Version (keywords + promo + description)
        if locale in ver_locs:
            attrs = {"keywords": keywords, "promotionalText": promo}
            if desc:
                attrs["description"] = desc
            success, resp = api_patch(f"/appStoreVersionLocalizations/{ver_locs[locale]}", {
                "data": {"type": "appStoreVersionLocalizations", "id": ver_locs[locale],
                         "attributes": attrs}
            })
            print(f"    {'✓' if success else '✗'} Keywords/Promo/Desc {'updated' if success else 'FAILED'}")
            if not success:
                errors = True
                try:
                    err = resp.json()["errors"][0]["detail"]
                    print(f"      → {err}")
                except:
                    pass

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

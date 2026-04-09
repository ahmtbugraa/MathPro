#!/usr/bin/env python3
"""
App Store Connect - Localized Description & Promotional Text Uploader
Uploads native-language descriptions for ALL 39 locales.
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
        p = {}
    return results


def api_patch(path, data):
    resp = requests.patch(f"{BASE}{path}", headers=hdrs(), json=data)
    return resp.status_code == 200, resp


# ══════════════════════════════════════════════════════════════
# ALL DESCRIPTIONS — Each in its native language
# ══════════════════════════════════════════════════════════════

DESCRIPTIONS = {
    "en-US": f"""Solve any math problem instantly — just snap a photo!

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

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",

    "en-GB": f"""Solve any maths problem instantly — just snap a photo!

AI Maths Solver uses advanced artificial intelligence to scan, recognise, and solve maths problems from a photo. Whether it's a textbook question, a handwritten equation, or a homework worksheet — point your camera and get a detailed step-by-step solution in seconds.

WHAT YOU CAN DO:
- Snap a photo of any maths problem or import from your gallery
- Crop and select exactly the problem you want to solve
- Get instant AI-powered solutions with full step-by-step explanations
- Review all your solved problems in a searchable history
- Share solutions as beautiful images

MATHS TOPICS COVERED:
- Arithmetic & Basic Maths
- Algebra & Linear Algebra
- Geometry & Trigonometry
- Calculus & Differential Equations
- Statistics & Probability
- Word Problems & Data Sufficiency

ADAPTS TO YOUR LEVEL:
Choose your education level — Primary, Secondary, GCSE, A-Level, or University — and the AI adapts its explanations to match. Simple language for younger pupils, detailed proofs for advanced learners.

SUBSCRIPTION INFORMATION:
Some features require an active subscription to unlock full access.
- Subscription options: Weekly and Annual plans available
- Payment is charged to your Apple ID account at confirmation of purchase
- Subscription automatically renews unless cancelled at least 24 hours before the end of the current period
- Your account will be charged for renewal within 24 hours prior to the end of the current period
- You can manage and cancel your subscriptions in your Apple ID Account Settings after purchase

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",

    "en-AU": f"""Solve any maths problem instantly — just snap a photo!

AI Maths Solver uses advanced artificial intelligence to scan, recognise, and solve maths problems from a photo. Whether it's a textbook question, a handwritten equation, or a homework worksheet — point your camera and get a detailed step-by-step solution in seconds.

WHAT YOU CAN DO:
- Snap a photo of any maths problem or import from your gallery
- Crop and select exactly the problem you want to solve
- Get instant AI-powered solutions with full step-by-step explanations
- Review all your solved problems in a searchable history
- Share solutions as beautiful images

MATHS TOPICS COVERED:
- Arithmetic & Basic Maths
- Algebra & Linear Algebra
- Geometry & Trigonometry
- Calculus & Differential Equations
- Statistics & Probability
- Word Problems & Data Sufficiency

ADAPTS TO YOUR LEVEL:
Choose your education level — Primary, Year 7-10, HSC/VCE, or University — and the AI adapts its explanations to match. Simple language for younger students, detailed proofs for advanced learners.

SUBSCRIPTION INFORMATION:
Some features require an active subscription to unlock full access.
- Subscription options: Weekly and Annual plans available
- Payment is charged to your Apple ID account at confirmation of purchase
- Subscription automatically renews unless cancelled at least 24 hours before the end of the current period
- Your account will be charged for renewal within 24 hours prior to the end of the current period
- You can manage and cancel your subscriptions in your Apple ID Account Settings after purchase

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",

    "en-CA": f"""Solve any math problem instantly — just snap a photo!

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

SUBSCRIPTION INFORMATION:
Some features require an active subscription to unlock full access.
- Subscription options: Weekly and Annual plans available
- Payment is charged to your Apple ID account at confirmation of purchase
- Subscription automatically renews unless canceled at least 24 hours before the end of the current period
- Your account will be charged for renewal within 24 hours prior to the end of the current period
- You can manage and cancel your subscriptions in your Apple ID Account Settings after purchase

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",

    "fr-FR": f"""Resolvez n'importe quel probleme de maths instantanement — prenez simplement une photo !

Ce solveur de maths IA utilise l'intelligence artificielle avancee pour scanner, reconnaitre et resoudre les problemes de maths a partir d'une photo. Question de manuel, equation manuscrite ou feuille de devoirs — pointez votre camera et obtenez une solution detaillee etape par etape en quelques secondes.

CE QUE VOUS POUVEZ FAIRE :
- Prenez une photo de n'importe quel probleme de maths ou importez depuis votre galerie
- Recadrez et selectionnez exactement le probleme a resoudre
- Obtenez des solutions instantanees avec des explications completes etape par etape
- Consultez tous vos problemes resolus dans un historique consultable
- Partagez les solutions sous forme de belles images

SUJETS DE MATHS COUVERTS :
- Arithmetique et Maths de base
- Algebre et Algebre lineaire
- Geometrie et Trigonometrie
- Calcul differentiel et Equations differentielles
- Statistiques et Probabilites
- Problemes de raisonnement

S'ADAPTE A VOTRE NIVEAU :
Choisissez votre niveau — College, Lycee, BAC ou Universite — et l'IA adapte ses explications. Langage simple pour les plus jeunes, demonstrations detaillees pour les avances.

INFORMATIONS SUR L'ABONNEMENT :
Certaines fonctionnalites necessitent un abonnement actif pour un acces complet.
- Options d'abonnement : forfaits Hebdomadaire et Annuel disponibles
- Le paiement est debite de votre compte Apple ID lors de la confirmation d'achat
- L'abonnement se renouvelle automatiquement sauf annulation au moins 24 heures avant la fin de la periode en cours
- Votre compte sera debite du renouvellement dans les 24 heures precedant la fin de la periode en cours
- Vous pouvez gerer et annuler vos abonnements dans les Reglages de votre identifiant Apple apres achat

Politique de confidentialite : {PRIVACY_URL}
Conditions d'utilisation : {TERMS_URL}""",

    "fr-CA": f"""Resolvez n'importe quel probleme de maths instantanement — prenez simplement une photo !

Ce solveur de maths IA utilise l'intelligence artificielle avancee pour scanner, reconnaitre et resoudre les problemes de maths a partir d'une photo. Question de manuel, equation manuscrite ou feuille de devoirs — pointez votre camera et obtenez une solution detaillee etape par etape en quelques secondes.

CE QUE VOUS POUVEZ FAIRE :
- Prenez une photo de n'importe quel probleme de maths ou importez depuis votre galerie
- Recadrez et selectionnez exactement le probleme a resoudre
- Obtenez des solutions instantanees avec des explications completes etape par etape
- Consultez tous vos problemes resolus dans un historique consultable
- Partagez les solutions sous forme de belles images

SUJETS DE MATHS COUVERTS :
- Arithmetique et Maths de base
- Algebre et Algebre lineaire
- Geometrie et Trigonometrie
- Calcul differentiel et Equations differentielles
- Statistiques et Probabilites
- Problemes de raisonnement

S'ADAPTE A VOTRE NIVEAU :
Choisissez votre niveau — Primaire, Secondaire, CEGEP ou Universite — et l'IA adapte ses explications. Langage simple pour les plus jeunes, demonstrations detaillees pour les avances.

INFORMATIONS SUR L'ABONNEMENT :
Certaines fonctionnalites necessitent un abonnement actif pour un acces complet.
- Options d'abonnement : forfaits Hebdomadaire et Annuel disponibles
- Le paiement est debite de votre compte Apple ID lors de la confirmation d'achat
- L'abonnement se renouvelle automatiquement sauf annulation au moins 24 heures avant la fin de la periode en cours
- Votre compte sera debite du renouvellement dans les 24 heures precedant la fin de la periode en cours
- Vous pouvez gerer et annuler vos abonnements dans les Reglages de votre identifiant Apple apres achat

Politique de confidentialite : {PRIVACY_URL}
Conditions d'utilisation : {TERMS_URL}""",

    "de-DE": f"""Lose jede Matheaufgabe sofort — mach einfach ein Foto!

Der KI Mathe Loser nutzt fortschrittliche kuenstliche Intelligenz, um Matheaufgaben von einem Foto zu scannen, zu erkennen und zu loesen. Ob Lehrbuchfrage, handgeschriebene Gleichung oder Hausaufgabenblatt — richte deine Kamera darauf und erhalte in Sekunden eine detaillierte Schritt-fuer-Schritt-Loesung.

WAS DU TUN KANNST:
- Mach ein Foto von jeder Matheaufgabe oder importiere aus deiner Galerie
- Schneide genau das Problem zu, das du loesen moechtest
- Erhalte sofortige KI-gestuetzte Loesungen mit vollstaendigen Schritt-fuer-Schritt-Erklaerungen
- Ueberpreufe alle geloesten Aufgaben in einem durchsuchbaren Verlauf
- Teile Loesungen als schoene Bilder

ABGEDECKTE MATHE-THEMEN:
- Arithmetik und Grundlagen
- Algebra und Lineare Algebra
- Geometrie und Trigonometrie
- Analysis und Differentialgleichungen
- Statistik und Wahrscheinlichkeit
- Textaufgaben

PASST SICH DEINEM NIVEAU AN:
Waehle dein Bildungsniveau — Grundschule, Mittelstufe, Oberstufe/Abitur oder Universitaet — und die KI passt ihre Erklaerungen an. Einfache Sprache fuer juengere Schueler, detaillierte Beweise fuer Fortgeschrittene.

Perfekt fuer die Abiturvorbereitung!

ABONNEMENT-INFORMATIONEN:
Einige Funktionen erfordern ein aktives Abonnement fuer den vollen Zugang.
- Abonnementoptionen: Woechentliche und Jaehrliche Plaene verfuegbar
- Die Zahlung wird bei Kaufbestaetiung Ihrem Apple-ID-Konto belastet
- Das Abonnement verlaengert sich automatisch, sofern es nicht mindestens 24 Stunden vor Ablauf des aktuellen Zeitraums gekuendigt wird
- Ihrem Konto wird die Verlaengerung innerhalb von 24 Stunden vor Ablauf des aktuellen Zeitraums berechnet
- Sie koennen Ihre Abonnements nach dem Kauf in den Apple-ID-Kontoeinstellungen verwalten und kuendigen

Datenschutzrichtlinie: {PRIVACY_URL}
Nutzungsbedingungen: {TERMS_URL}""",

    "es-ES": f"""Resuelve cualquier problema de matematicas al instante — solo haz una foto!

El Resolvedor de Mates con IA utiliza inteligencia artificial avanzada para escanear, reconocer y resolver problemas matematicos desde una foto. Ya sea una pregunta del libro, una ecuacion escrita a mano o una hoja de deberes — apunta tu camara y obtiene una solucion detallada paso a paso en segundos.

LO QUE PUEDES HACER:
- Haz una foto de cualquier problema de mates o importa desde tu galeria
- Recorta y selecciona exactamente el problema que quieres resolver
- Obtiene soluciones instantaneas con explicaciones completas paso a paso
- Revisa todos tus problemas resueltos en un historial con busqueda
- Comparte soluciones como imagenes

TEMAS DE MATEMATICAS:
- Aritmetica y Matematicas basicas
- Algebra y Algebra lineal
- Geometria y Trigonometria
- Calculo y Ecuaciones diferenciales
- Estadistica y Probabilidad
- Problemas de razonamiento

SE ADAPTA A TU NIVEL:
Elige tu nivel educativo — Primaria, ESO, Bachillerato/Selectividad o Universidad — y la IA adapta sus explicaciones. Lenguaje sencillo para los mas jovenes, demostraciones detalladas para los avanzados.

INFORMACION DE SUSCRIPCION:
Algunas funciones requieren una suscripcion activa para acceso completo.
- Opciones de suscripcion: planes Semanal y Anual disponibles
- El pago se carga a tu cuenta de Apple ID al confirmar la compra
- La suscripcion se renueva automaticamente a menos que se cancele al menos 24 horas antes del final del periodo actual
- Se te cobrara la renovacion dentro de las 24 horas anteriores al final del periodo actual
- Puedes gestionar y cancelar tus suscripciones en los Ajustes de tu Apple ID tras la compra

Politica de Privacidad: {PRIVACY_URL}
Terminos de Uso: {TERMS_URL}""",

    "es-MX": f"""Resuelve cualquier problema de matematicas al instante — solo toma una foto!

El Resolvedor de Mates con IA utiliza inteligencia artificial avanzada para escanear, reconocer y resolver problemas matematicos desde una foto. Ya sea una pregunta del libro, una ecuacion escrita a mano o una tarea — apunta tu camara y obtiene una solucion detallada paso a paso en segundos.

LO QUE PUEDES HACER:
- Toma una foto de cualquier problema de mates o importa desde tu galeria
- Recorta y selecciona exactamente el problema que quieres resolver
- Obtiene soluciones instantaneas con explicaciones completas paso a paso
- Revisa todos tus problemas resueltos en un historial con busqueda
- Comparte soluciones como imagenes

TEMAS DE MATEMATICAS:
- Aritmetica y Matematicas basicas
- Algebra y Algebra lineal
- Geometria y Trigonometria
- Calculo y Ecuaciones diferenciales
- Estadistica y Probabilidad
- Problemas de razonamiento

SE ADAPTA A TU NIVEL:
Elige tu nivel educativo — Primaria, Secundaria, Prepa o Universidad — y la IA adapta sus explicaciones. Lenguaje sencillo para los mas jovenes, demostraciones detalladas para los avanzados.

Ideal para preparar examenes de ingreso a la UNAM y universidades!

INFORMACION DE SUSCRIPCION:
Algunas funciones requieren una suscripcion activa para acceso completo.
- Opciones de suscripcion: planes Semanal y Anual disponibles
- El pago se carga a tu cuenta de Apple ID al confirmar la compra
- La suscripcion se renueva automaticamente a menos que se cancele al menos 24 horas antes del final del periodo actual
- Se te cobrara la renovacion dentro de las 24 horas anteriores al final del periodo actual
- Puedes gestionar y cancelar tus suscripciones en los Ajustes de tu Apple ID tras la compra

Politica de Privacidad: {PRIVACY_URL}
Terminos de Uso: {TERMS_URL}""",

    "pt-BR": f"""Resolva qualquer problema de matematica instantaneamente — basta tirar uma foto!

O Resolvedor de Matematica com IA usa inteligencia artificial avancada para escanear, reconhecer e resolver problemas de matematica a partir de uma foto. Seja uma questao do livro, uma equacao manuscrita ou uma folha de dever — aponte sua camera e receba uma solucao detalhada passo a passo em segundos.

O QUE VOCE PODE FAZER:
- Tire uma foto de qualquer problema de matematica ou importe da sua galeria
- Recorte e selecione exatamente o problema que deseja resolver
- Receba solucoes instantaneas com explicacoes completas passo a passo
- Revise todos os problemas resolvidos em um historico pesquisavel
- Compartilhe solucoes como belas imagens

TOPICOS DE MATEMATICA:
- Aritmetica e Matematica basica
- Algebra e Algebra linear
- Geometria e Trigonometria
- Calculo e Equacoes diferenciais
- Estatistica e Probabilidade
- Problemas de raciocinio

ADAPTA-SE AO SEU NIVEL:
Escolha seu nivel educacional — Fundamental, Medio, ENEM/Vestibular ou Universidade — e a IA adapta suas explicacoes. Linguagem simples para os mais jovens, demonstracoes detalhadas para avancados.

Perfeito para se preparar para o ENEM e vestibulares!

INFORMACOES DE ASSINATURA:
Alguns recursos exigem uma assinatura ativa para acesso completo.
- Opcoes de assinatura: planos Semanal e Anual disponiveis
- O pagamento e cobrado na sua conta Apple ID na confirmacao da compra
- A assinatura e renovada automaticamente, a menos que seja cancelada pelo menos 24 horas antes do final do periodo atual
- Sua conta sera cobrada pela renovacao dentro de 24 horas antes do final do periodo atual
- Voce pode gerenciar e cancelar suas assinaturas nas Configuracoes da sua conta Apple ID apos a compra

Politica de Privacidade: {PRIVACY_URL}
Termos de Uso: {TERMS_URL}""",

    "pt-PT": f"""Resolva qualquer problema de matematica instantaneamente — basta tirar uma foto!

O Resolvedor de Matematica com IA usa inteligencia artificial avancada para digitalizar, reconhecer e resolver problemas de matematica a partir de uma foto. Seja uma questao do livro, uma equacao manuscrita ou um TPC — aponte a sua camera e receba uma solucao detalhada passo a passo em segundos.

O QUE PODE FAZER:
- Tire uma foto de qualquer problema de matematica ou importe da sua galeria
- Recorte e selecione exatamente o problema que deseja resolver
- Receba solucoes instantaneas com explicacoes completas passo a passo
- Reveja todos os problemas resolvidos num historico pesquisavel
- Partilhe solucoes como belas imagens

TOPICOS DE MATEMATICA:
- Aritmetica e Matematica basica
- Algebra e Algebra linear
- Geometria e Trigonometria
- Calculo e Equacoes diferenciais
- Estatistica e Probabilidade
- Problemas de raciocinio

ADAPTA-SE AO SEU NIVEL:
Escolha o seu nivel educacional — Basico, Secundario, Exame Nacional ou Universidade — e a IA adapta as suas explicacoes. Linguagem simples para os mais novos, demonstracoes detalhadas para avancados.

INFORMACOES DE SUBSCRICAO:
Algumas funcionalidades requerem uma subscricao ativa para acesso completo.
- Opcoes de subscricao: planos Semanal e Anual disponiveis
- O pagamento e cobrado na sua conta Apple ID na confirmacao da compra
- A subscricao e renovada automaticamente, salvo cancelamento pelo menos 24 horas antes do final do periodo atual
- A sua conta sera cobrada pela renovacao dentro de 24 horas antes do final do periodo atual
- Pode gerir e cancelar as suas subscricoes nas Definicoes da conta Apple ID apos a compra

Politica de Privacidade: {PRIVACY_URL}
Termos de Utilizacao: {TERMS_URL}""",

    "it": f"""Risolvi qualsiasi problema di matematica istantaneamente — basta scattare una foto!

Il Risolutore di Matematica con IA utilizza l'intelligenza artificiale avanzata per scansionare, riconoscere e risolvere problemi di matematica da una foto. Che sia una domanda del libro, un'equazione scritta a mano o un compito — punta la fotocamera e ottieni una soluzione dettagliata passo dopo passo in pochi secondi.

COSA PUOI FARE:
- Scatta una foto di qualsiasi problema di matematica o importa dalla galleria
- Ritaglia e seleziona esattamente il problema da risolvere
- Ottieni soluzioni istantanee con spiegazioni complete passo dopo passo
- Rivedi tutti i problemi risolti in una cronologia ricercabile
- Condividi le soluzioni come belle immagini

ARGOMENTI DI MATEMATICA:
- Aritmetica e Matematica di base
- Algebra e Algebra lineare
- Geometria e Trigonometria
- Analisi e Equazioni differenziali
- Statistica e Probabilita
- Problemi di ragionamento

SI ADATTA AL TUO LIVELLO:
Scegli il tuo livello — Scuola Media, Liceo, Maturita o Universita — e l'IA adatta le sue spiegazioni. Linguaggio semplice per i piu giovani, dimostrazioni dettagliate per gli avanzati.

Perfetto per prepararsi alla Maturita!

INFORMAZIONI SULL'ABBONAMENTO:
Alcune funzionalita richiedono un abbonamento attivo per l'accesso completo.
- Opzioni di abbonamento: piani Settimanale e Annuale disponibili
- Il pagamento viene addebitato sul tuo account Apple ID alla conferma dell'acquisto
- L'abbonamento si rinnova automaticamente a meno che non venga cancellato almeno 24 ore prima della fine del periodo corrente
- Il rinnovo verra addebitato entro 24 ore prima della fine del periodo corrente
- Puoi gestire e cancellare i tuoi abbonamenti nelle Impostazioni del tuo Apple ID dopo l'acquisto

Informativa sulla Privacy: {PRIVACY_URL}
Termini di Utilizzo: {TERMS_URL}""",

    "nl-NL": f"""Los elk wiskundeprobleem direct op — maak gewoon een foto!

De AI Wiskunde Oplosser gebruikt geavanceerde kunstmatige intelligentie om wiskundeproblemen van een foto te scannen, herkennen en op te lossen. Of het nu een vraag uit het boek is, een handgeschreven vergelijking of huiswerk — richt je camera en krijg in seconden een gedetailleerde stap-voor-stap oplossing.

WAT JE KUNT DOEN:
- Maak een foto van elk wiskundeprobleem of importeer uit je galerij
- Snijd bij en selecteer precies het probleem dat je wilt oplossen
- Krijg directe AI-gestuurde oplossingen met volledige stap-voor-stap uitleg
- Bekijk al je opgeloste problemen in een doorzoekbare geschiedenis
- Deel oplossingen als mooie afbeeldingen

WISKUNDE ONDERWERPEN:
- Rekenen en Basiswiskunde
- Algebra en Lineaire Algebra
- Meetkunde en Trigonometrie
- Calculus en Differentiaalvergelijkingen
- Statistiek en Kansrekening
- Redactiesommen

PAST ZICH AAN JOUW NIVEAU AAN:
Kies je opleidingsniveau — Basisschool, VMBO, HAVO, VWO of Universiteit — en de AI past zijn uitleg aan. Eenvoudige taal voor jongere leerlingen, gedetailleerde bewijzen voor gevorderden.

ABONNEMENTSINFORMATIE:
Sommige functies vereisen een actief abonnement voor volledige toegang.
- Abonnementsopties: Wekelijkse en Jaarlijkse plannen beschikbaar
- Betaling wordt in rekening gebracht op je Apple ID-account bij bevestiging van aankoop
- Het abonnement wordt automatisch verlengd tenzij het minstens 24 uur voor het einde van de huidige periode wordt opgezegd
- Je account wordt binnen 24 uur voor het einde van de huidige periode belast voor verlenging
- Je kunt je abonnementen beheren en opzeggen in je Apple ID-accountinstellingen na aankoop

Privacybeleid: {PRIVACY_URL}
Gebruiksvoorwaarden: {TERMS_URL}""",

    "ja": f"""数学の問題を瞬時に解決 — 写真を撮るだけ！

AI数学ソルバーは、高度な人工知能を使って写真から数学の問題をスキャン、認識、解決します。教科書の問題、手書きの方程式、宿題のプリント — カメラを向けるだけで、数秒で詳細なステップごとの解説が得られます。

できること：
- 数学の問題の写真を撮るか、ギャラリーからインポート
- 解きたい問題を正確にトリミングして選択
- AIによる即時解答と完全なステップごとの解説を取得
- 解いた問題を検索可能な履歴で確認
- 解答を美しい画像として共有

対応する数学分野：
- 算数・基礎数学
- 代数・線形代数
- 幾何学・三角関数
- 微積分・微分方程式
- 統計・確率
- 文章問題

あなたのレベルに適応：
教育レベルを選択 — 小学校、中学校、高校、大学 — するとAIが説明をレベルに合わせます。低学年にはわかりやすい言葉で、上級者には詳しい証明を。

共通テストや大学受験の準備にも最適！

サブスクリプション情報：
一部の機能はフルアクセスのためにアクティブなサブスクリプションが必要です。
- サブスクリプションオプション：週間プランと年間プランが利用可能
- お支払いは購入確認時にApple IDアカウントに請求されます
- サブスクリプションは現在の期間終了の少なくとも24時間前にキャンセルしない限り自動更新されます
- アカウントには現在の期間終了の24時間以内に更新料金が請求されます
- 購入後、Apple IDアカウント設定でサブスクリプションを管理・キャンセルできます

プライバシーポリシー：{PRIVACY_URL}
利用規約：{TERMS_URL}""",

    "ko": f"""수학 문제를 즉시 해결 — 사진만 찍으세요!

AI 수학 풀이는 고급 인공지능을 사용하여 사진에서 수학 문제를 스캔, 인식 및 풀어줍니다. 교과서 문제, 손으로 쓴 방정식, 숙제 — 카메라를 겨누면 몇 초 만에 상세한 단계별 풀이를 받을 수 있습니다.

할 수 있는 것:
- 수학 문제 사진을 찍거나 갤러리에서 가져오기
- 풀고 싶은 문제를 정확히 자르고 선택
- AI 기반 즉석 풀이와 완전한 단계별 설명 받기
- 풀었던 모든 문제를 검색 가능한 기록에서 확인
- 풀이를 아름다운 이미지로 공유

다루는 수학 주제:
- 산술 및 기초 수학
- 대수 및 선형대수
- 기하학 및 삼각함수
- 미적분 및 미분방정식
- 통계 및 확률
- 서술형 문제

나의 수준에 맞춤:
교육 수준을 선택하세요 — 초등, 중등, 고등, 대학교 — 그러면 AI가 설명을 맞춤 조정합니다. 어린 학생에게는 쉬운 언어로, 고급 학습자에게는 상세한 증명으로.

수능 및 내신 준비에 완벽!

구독 정보:
일부 기능은 전체 액세스를 위해 활성 구독이 필요합니다.
- 구독 옵션: 주간 및 연간 플랜 이용 가능
- 결제는 구매 확인 시 Apple ID 계정에 청구됩니다
- 구독은 현재 기간 종료 최소 24시간 전에 취소하지 않으면 자동 갱신됩니다
- 현재 기간 종료 24시간 이내에 갱신 요금이 계정에 청구됩니다
- 구매 후 Apple ID 계정 설정에서 구독을 관리하고 취소할 수 있습니다

개인정보 처리방침: {PRIVACY_URL}
이용약관: {TERMS_URL}""",

    "zh-Hans": f"""拍照即可解决任何数学问题！

AI数学解题器使用先进的人工智能，从照片中扫描、识别并解决数学问题。无论是课本题目、手写方程式还是作业 — 对准摄像头，几秒内即可获得详细的分步解答。

功能特色：
- 拍摄任何数学问题的照片或从相册导入
- 裁剪并精确选择要解决的问题
- 获取AI即时解答，附完整的分步说明
- 在可搜索的历史记录中查看所有已解题目
- 将解答分享为精美图片

涵盖数学主题：
- 算术与基础数学
- 代数与线性代数
- 几何与三角函数
- 微积分与微分方程
- 统计与概率
- 应用题

适应你的水平：
选择你的教育程度 — 小学、初中、高中或大学 — AI会调整解释方式。为低年级学生提供简单语言，为高级学习者提供详细证明。

备战中考、高考的理想工具！

订阅信息：
部分功能需要有效订阅才能完全访问。
- 订阅选项：提供周订阅和年订阅
- 付款在确认购买时从您的Apple ID账户扣除
- 除非在当前期限结束前至少24小时取消，否则订阅将自动续订
- 您的账户将在当前期限结束前24小时内收取续订费用
- 购买后，您可以在Apple ID账户设置中管理和取消订阅

隐私政策：{PRIVACY_URL}
使用条款：{TERMS_URL}""",

    "zh-Hant": f"""拍照即可解決任何數學問題！

AI數學解題器使用先進的人工智慧，從照片中掃描、辨識並解決數學問題。無論是課本題目、手寫方程式還是作業 — 對準相機，幾秒內即可獲得詳細的分步解答。

功能特色：
- 拍攝任何數學問題的照片或從相簿匯入
- 裁剪並精確選擇要解決的問題
- 獲取AI即時解答，附完整的分步說明
- 在可搜尋的歷史記錄中查看所有已解題目
- 將解答分享為精美圖片

涵蓋數學主題：
- 算術與基礎數學
- 代數與線性代數
- 幾何與三角函數
- 微積分與微分方程
- 統計與機率
- 應用題

適應你的程度：
選擇你的教育程度 — 國小、國中、高中或大學 — AI會調整解釋方式。為低年級學生提供簡單語言，為進階學習者提供詳細證明。

準備學測、指考的最佳工具！

訂閱資訊：
部分功能需要有效訂閱才能完全存取。
- 訂閱選項：提供週訂閱和年訂閱
- 付款在確認購買時從您的Apple ID帳號扣除
- 除非在目前期限結束前至少24小時取消，否則訂閱將自動續訂
- 您的帳號將在目前期限結束前24小時內收取續訂費用
- 購買後，您可以在Apple ID帳號設定中管理和取消訂閱

隱私權政策：{PRIVACY_URL}
使用條款：{TERMS_URL}""",

    "ar-SA": f"""حل اي مسالة رياضيات فورا — فقط التقط صورة!

يستخدم حل مسائل الرياضيات بالذكاء الاصطناعي تقنية متقدمة لمسح ومعرفة وحل مسائل الرياضيات من صورة. سواء كان سؤال من الكتاب او معادلة مكتوبة بخط اليد او ورقة واجب — وجه الكاميرا واحصل على حل مفصل خطوة بخطوة في ثوان.

ما يمكنك فعله:
- التقط صورة لاي مسالة رياضيات او استورد من معرض الصور
- قص وحدد المسالة التي تريد حلها بدقة
- احصل على حلول فورية بالذكاء الاصطناعي مع شرح كامل خطوة بخطوة
- راجع جميع مسائلك المحلولة في سجل قابل للبحث
- شارك الحلول كصور جميلة

مواضيع الرياضيات المشمولة:
- الحساب والرياضيات الاساسية
- الجبر والجبر الخطي
- الهندسة وحساب المثلثات
- التفاضل والتكامل والمعادلات التفاضلية
- الاحصاء والاحتمالات
- المسائل الكلامية

يتكيف مع مستواك:
اختر مستواك التعليمي — ابتدائي، متوسط، ثانوي او جامعة — والذكاء الاصطناعي يكيف شروحاته. لغة بسيطة للطلاب الاصغر، براهين مفصلة للمتقدمين.

مثالي للتحضير لاختبارات القدرات والتحصيلي!

معلومات الاشتراك:
بعض الميزات تتطلب اشتراكا نشطا للوصول الكامل.
- خيارات الاشتراك: خطط اسبوعية وسنوية متاحة
- يتم خصم المبلغ من حساب Apple ID الخاص بك عند تاكيد الشراء
- يتجدد الاشتراك تلقائيا ما لم يتم الغاؤه قبل 24 ساعة على الاقل من نهاية الفترة الحالية
- سيتم خصم رسوم التجديد من حسابك خلال 24 ساعة قبل نهاية الفترة الحالية
- يمكنك ادارة والغاء اشتراكاتك في اعدادات حساب Apple ID بعد الشراء

سياسة الخصوصية: {PRIVACY_URL}
شروط الاستخدام: {TERMS_URL}""",

    "tr": f"""Herhangi bir matematik problemini anında çöz — sadece bir fotoğraf çek!

AI Matematik Çözücü, gelişmiş yapay zekâ kullanarak fotoğraftan matematik problemlerini tarar, tanır ve çözer. İster ders kitabı sorusu, ister el yazısı denklem, ister ödev — kameranı doğrult ve saniyelerde detaylı adım adım çözüm al.

NELER YAPABİLİRSİN:
- Herhangi bir matematik probleminin fotoğrafını çek veya galerinden yükle
- Çözmek istediğin problemi kırp ve seç
- AI destekli anında çözümler al, tam adım adım açıklamalarla
- Çözülmüş tüm problemlerini aranabilir geçmişte incele
- Çözümleri güzel görseller olarak paylaş

KAPSANAN MATEMATİK KONULARI:
- Aritmetik ve Temel Matematik
- Cebir ve Lineer Cebir
- Geometri ve Trigonometri
- Kalkülüs ve Diferansiyel Denklemler
- İstatistik ve Olasılık
- Sözel Problemler

SEVİYENE UYUM SAĞLAR:
Eğitim seviyeni seç — İlkokul, Ortaokul, Lise veya Üniversite — ve yapay zekâ açıklamalarını seviyene göre uyarlar. Küçük öğrenciler için basit dil, ileri düzey öğrenciler için detaylı ispatlar.

YKS, TYT, AYT ve LGS hazırlığında sana yardımcı olur!

ABONELİK BİLGİLERİ:
Bazı özellikler tam erişim için aktif bir abonelik gerektirir.
- Abonelik seçenekleri: Haftalık ve Yıllık planlar mevcuttur
- Ödeme, satın alma onayında Apple Kimliğiniz hesabınızdan tahsil edilir
- Abonelik, mevcut dönem bitmeden en az 24 saat önce iptal edilmedikçe otomatik olarak yenilenir
- Hesabınızdan mevcut dönemin bitiminden 24 saat önce yenileme ücreti tahsil edilir
- Aboneliklerinizi satın alma sonrasında Apple Kimliğiniz Hesap Ayarlarından yönetebilir ve iptal edebilirsiniz

Gizlilik Politikası: {PRIVACY_URL}
Kullanım Koşulları: {TERMS_URL}""",

    "ru": f"""Решите любую задачу по математике мгновенно — просто сделайте фото!

AI Решатель Математики использует передовой искусственный интеллект для сканирования, распознавания и решения математических задач по фотографии. Будь то задача из учебника, рукописное уравнение или домашнее задание — наведите камеру и получите подробное пошаговое решение за секунды.

ЧТО ВЫ МОЖЕТЕ:
- Сфотографируйте любую задачу или импортируйте из галереи
- Обрежьте и выберите именно ту задачу, которую хотите решить
- Получите мгновенные решения от ИИ с полным пошаговым объяснением
- Просматривайте все решенные задачи в истории с поиском
- Делитесь решениями в виде красивых изображений

ТЕМЫ ПО МАТЕМАТИКЕ:
- Арифметика и основы математики
- Алгебра и линейная алгебра
- Геометрия и тригонометрия
- Математический анализ и дифференциальные уравнения
- Статистика и теория вероятностей
- Текстовые задачи

АДАПТИРУЕТСЯ К ВАШЕМУ УРОВНЮ:
Выберите уровень образования — Начальная школа, Средняя школа, Старшие классы или Университет — и ИИ адаптирует объяснения. Простой язык для младших учеников, подробные доказательства для продвинутых.

Идеально для подготовки к ЕГЭ и ОГЭ!

ИНФОРМАЦИЯ О ПОДПИСКЕ:
Некоторые функции требуют активной подписки для полного доступа.
- Варианты подписки: доступны Еженедельный и Годовой планы
- Оплата списывается с вашей учетной записи Apple ID при подтверждении покупки
- Подписка автоматически продлевается, если не отменена минимум за 24 часа до окончания текущего периода
- С вашего счета будет списана плата за продление в течение 24 часов до окончания текущего периода
- Вы можете управлять подписками и отменять их в настройках учетной записи Apple ID после покупки

Политика конфиденциальности: {PRIVACY_URL}
Условия использования: {TERMS_URL}""",

    "hi": f"""Kisi bhi ganit ki samasya ko turant hal karen — bas ek photo lijiye!

AI Math Solver advanced artificial intelligence ka upayog karke photo se ganit ki samasyaon ko scan, pehchan aur hal karta hai. Chahe textbook ka sawal ho, haath se likhi equation ho ya homework — apna camera point karen aur seconds mein vistar se step-by-step solution payen.

AAP KYA KAR SAKTE HAIN:
- Kisi bhi ganit ki samasya ki photo len ya gallery se import karen
- Jo samasya hal karni hai usse crop aur select karen
- AI-powered turant solutions payen poore step-by-step explanation ke saath
- Apni sabhi hal ki gayi samasyaon ko searchable history mein dekhen
- Solutions ko sundar images ke roop mein share karen

GANIT KE VISHAY:
- Ankganit aur Basic Math
- Beejganit (Algebra) aur Linear Algebra
- Jyamiti (Geometry) aur Trigonometry
- Calculus aur Differential Equations
- Sankhyiki (Statistics) aur Probability
- Word Problems

AAPKE STAR KE ANUSAAR:
Apna shiksha star chune — Primary, Middle School, High School ya University — aur AI apne explanations ko adjust karta hai. Chhote students ke liye saral bhasha, advanced learners ke liye detailed proofs.

JEE, NEET, CBSE aur ICSE board exams ki taiyari ke liye perfect!

SUBSCRIPTION JAANKARI:
Kuch features ke liye poore access ke liye active subscription zaroori hai.
- Subscription options: Weekly aur Annual plans uplabdh hain
- Payment kharid ki pushthi par aapke Apple ID account se charge hota hai
- Subscription automatic renew hota hai jab tak current period khatm hone se kam se kam 24 ghante pehle cancel nahi kiya jaata
- Aapke account se current period khatm hone se 24 ghante ke andar renewal charge hoga
- Aap kharid ke baad Apple ID Account Settings mein apne subscriptions manage aur cancel kar sakte hain

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",

    "he": f"""פתרו כל בעיה במתמטיקה מיידית — פשוט צלמו תמונה!

פותר המתמטיקה AI משתמש בבינה מלאכותית מתקדמת כדי לסרוק, לזהות ולפתור בעיות מתמטיקה מתמונה. בין אם זו שאלה מהספר, משוואה בכתב יד או דף שיעורי בית — כוונו את המצלמה וקבלו פתרון מפורט צעד אחר צעד תוך שניות.

מה אפשר לעשות:
- צלמו כל בעיית מתמטיקה או ייבאו מהגלריה
- חתכו ובחרו בדיוק את הבעיה שרוצים לפתור
- קבלו פתרונות מיידיים מבוססי AI עם הסבר מלא צעד אחר צעד
- עיינו בכל הבעיות שפתרתם בהיסטוריה עם חיפוש
- שתפו פתרונות כתמונות יפות

נושאי מתמטיקה:
- חשבון ומתמטיקה בסיסית
- אלגברה ואלגברה ליניארית
- גיאומטריה וטריגונומטריה
- חדו״א ומשוואות דיפרנציאליות
- סטטיסטיקה והסתברות
- בעיות מילוליות

מתאים לרמה שלכם:
בחרו את רמת ההשכלה — יסודי, חטיבה, תיכון או אוניברסיטה — וה-AI מתאים את ההסברים. שפה פשוטה לתלמידים צעירים, הוכחות מפורטות למתקדמים.

מושלם להכנה לבגרות!

מידע על מנוי:
חלק מהתכונות דורשות מנוי פעיל לגישה מלאה.
- אפשרויות מנוי: מסלולים שבועיים ושנתיים זמינים
- התשלום נגבה מחשבון ה-Apple ID שלכם באישור הרכישה
- המנוי מתחדש אוטומטית אלא אם מבוטל לפחות 24 שעות לפני סוף התקופה הנוכחית
- חשבונכם יחויב בחידוש תוך 24 שעות לפני סוף התקופה הנוכחית
- ניתן לנהל ולבטל מנויים בהגדרות חשבון Apple ID לאחר הרכישה

מדיניות פרטיות: {PRIVACY_URL}
תנאי שימוש: {TERMS_URL}""",

    "hr": f"""Rijesite bilo koji matematicki problem trenutno — samo slikajte!

AI Rjesavac Matematike koristi naprednu umjetnu inteligenciju za skeniranje, prepoznavanje i rjesavanje matematickih problema sa fotografije. Bilo da je pitanje iz udzbenika, rucno napisana jednadzba ili domaca zadaca — usmjerite kameru i dobijte detaljno rjesenje korak po korak u sekundama.

STO MOZETE UCINITI:
- Slikajte bilo koji matematicki problem ili uvezite iz galerije
- Izrezhite i odaberite tocno problem koji zelite rijesiti
- Dobijte trenutna AI rjesenja s potpunim objasnjenjima korak po korak
- Pregledajte sve rijesene probleme u pretrazivoj povijesti
- Podijelite rjesenja kao lijepe slike

MATEMATICKI PREDMETI:
- Aritmetika i osnovna matematika
- Algebra i linearna algebra
- Geometrija i trigonometrija
- Kalkulus i diferencijalne jednadzbe
- Statistika i vjerojatnost
- Tekstualni zadaci

PRILAGODAVA SE VASOJ RAZINI:
Odaberite svoju razinu obrazovanja — Osnovna skola, Srednja skola, Matura ili Fakultet — i AI prilagodava svoja objasnjenja. Jednostavan jezik za mlade ucenike, detaljni dokazi za napredne.

Savrseno za pripremu mature!

INFORMACIJE O PRETPLATI:
Neke znacajke zahtijevaju aktivnu pretplatu za potpuni pristup.
- Opcije pretplate: dostupni Tjedni i Godisnji planovi
- Placanje se naplacuje na vas Apple ID racun pri potvrdi kupnje
- Pretplata se automatski obnavlja osim ako se ne otkaze najmanje 24 sata prije kraja trenutnog razdoblja
- Vas racun ce biti teretan za obnovu unutar 24 sata prije kraja trenutnog razdoblja
- Svoje pretplate mozete upravljati i otkazati u postavkama Apple ID racuna nakon kupnje

Pravila o privatnosti: {PRIVACY_URL}
Uvjeti koristenja: {TERMS_URL}""",

    "cs": f"""Vyresete jakykoli matematicky priklad okamzite — staci vyfotit!

AI Resite Matematiky vyuziva pokrocilou umelou inteligenci k naskenovani, rozpoznani a vyreseni matematickych problemu z fotografie. At uz je to otazka z ucebnice, rucne napsana rovnice nebo domaci ukol — namirete fotoaparat a behem sekund ziskejte podrobne reseni krok za krokem.

CO MUZETE DELAT:
- Vyfozte jakykoli matematicky priklad nebo importujte z galerie
- Orezte a vyberte presne ten problem, ktery chcete vyresit
- Ziskejte okamzita AI reseni s uplnymi vysvetlenimi krok za krokem
- Prohlizejte si vsechny vyresene priklady v prohledavatelne historii
- Sdílejte reseni jako krasne obrazky

MATEMATICKE TEMATA:
- Aritmetika a zakladni matematika
- Algebra a linearni algebra
- Geometrie a trigonometrie
- Kalkulus a diferencialni rovnice
- Statistika a pravdepodobnost
- Slovni ulohy

PRIZPUSOBI SE VASI UROVNI:
Zvolte svou uroven vzdelani — Zakladni skola, Stredni skola, Maturita nebo Univerzita — a AI prizpusobi svá vysvetleni. Jednoduchy jazyk pro mladsi zaky, podrobne dukazy pro pokrocile.

Idealni pro pripravu na maturitu!

INFORMACE O PREDPLATNEM:
Nektere funkce vyzaduji aktivni predplatne pro plny pristup.
- Moznosti predplatneho: dostupne Tydenni a Rocni plany
- Platba je uctovana na vas ucet Apple ID pri potvrzeni nakupu
- Predplatne se automaticky obnovuje, pokud neni zruseno alespon 24 hodin pred koncem aktualniho obdobi
- Vas ucet bude zatizen obnovenim do 24 hodin pred koncem aktualniho obdobi
- Sve predplatne muzete spravovat a zrusit v nastaveni uctu Apple ID po nakupu

Zasady ochrany osobnich udaju: {PRIVACY_URL}
Podminky pouziti: {TERMS_URL}""",

    "da": f"""Los ethvert matematikproblem med det samme — tag bare et foto!

AI Matematik Loser bruger avanceret kunstig intelligens til at scanne, genkende og lose matematikproblemer fra et foto. Uanset om det er et sporgsmal fra bogen, en handskrevet ligning eller lektier — peg dit kamera og fa en detaljeret trin-for-trin losning pa sekunder.

HVAD DU KAN GORE:
- Tag et foto af ethvert matematikproblem eller importer fra dit galleri
- Beskear og vaelg praecis det problem, du vil lose
- Fa ojeblikkeligt AI-drevne losninger med fulde trin-for-trin forklaringer
- Gennemga alle dine loste problemer i en sogbar historik
- Del losninger som flotte billeder

MATEMATIKEMNER:
- Aritmetik og grundlaeggende matematik
- Algebra og lineaer algebra
- Geometri og trigonometri
- Calculus og differentialligninger
- Statistik og sandsynlighed
- Tekstopgaver

TILPASSER SIG DIT NIVEAU:
Vaelg dit uddannelsesniveau — Folkeskole, Gymnasium, HF/STX eller Universitet — og AI'en tilpasser sine forklaringer. Enkelt sprog til yngre elever, detaljerede beviser til avancerede.

ABONNEMENTSINFORMATION:
Nogle funktioner kraever et aktivt abonnement for fuld adgang.
- Abonnementsmuligheder: Ugentlige og Arlige planer tilgaengelige
- Betaling opkraeves pa din Apple ID-konto ved bekraeftelse af kob
- Abonnementet fornyes automatisk, medmindre det opsiges mindst 24 timer for udgangen af den aktuelle periode
- Din konto vil blive opkraevet for fornyelse inden for 24 timer for udgangen af den aktuelle periode
- Du kan administrere og opsige dine abonnementer i Apple ID-kontoindstillingerne efter kob

Privatlivspolitik: {PRIVACY_URL}
Brugsvilkar: {TERMS_URL}""",

    "fi": f"""Ratkaise mika tahansa matikkaongelma heti — ota vain kuva!

AI Matikan Ratkaisija kayttaa edistynyttya tekoalya skannatakseen, tunnistaakseen ja ratkaistakseen matematiikan ongelmia kuvasta. Olipa kyseessa oppikirjan tehtava, kasin kirjoitettu yhtalo tai lasky — osoita kameraa ja saat yksityiskohtaisen vaihe vaiheelta -ratkaisun sekunneissa.

MITA VOIT TEHDA:
- Ota kuva mista tahansa matikkaongelmasta tai tuo galleriasta
- Rajaa ja valitse tarkasti ongelma, jonka haluat ratkaista
- Saa valittomia tekoalypohjaisia ratkaisuja taydellisilla vaihe vaiheelta -selityksilla
- Tarkastele kaikkia ratkaistuja ongelmia hakukelpoisessa historiassa
- Jaa ratkaisut kauniina kuvina

MATEMATIIKAN AIHEET:
- Aritmetiikka ja perusmatematiikka
- Algebra ja lineaarialgebra
- Geometria ja trigonometria
- Analyysi ja differentiaaliyhtälöt
- Tilastotiede ja todennakoisyys
- Sanallisia tehtavia

MUKAUTUU TASOOSI:
Valitse koulutustasosi — Peruskoulu, Lukio, Ylioppilaskoe tai Yliopisto — ja tekoaly mukauttaa selityksensa. Yksinkertainen kieli nuoremmille oppilaille, yksityiskohtaiset todistukset edistyneille.

Taydellinan ylioppilaskirjoituksiin valmistautumiseen!

TILAUSTIEDOT:
Jotkin ominaisuudet vaativat aktiivisen tilauksen taydelliseen kayttoon.
- Tilausvaihtoehdot: Viikko- ja Vuositilaukset saatavilla
- Maksu veloitetaan Apple ID -tililtasi oston vahvistamisen yhteydessa
- Tilaus uusiutuu automaattisesti, ellei sita peruuteta vahintaan 24 tuntia ennen nykyisen jakson paattymista
- Tililtasi veloitetaan uusiminen 24 tunnin kuluessa ennen nykyisen jakson paattymista
- Voit hallita ja peruuttaa tilauksesi Apple ID -tilin asetuksissa oston jalkeen

Tietosuojakaytanto: {PRIVACY_URL}
Kayttoehdot: {TERMS_URL}""",

    "el": f"""Λύστε οποιοδήποτε μαθηματικό πρόβλημα αμέσως — απλά τραβήξτε μια φωτογραφία!

Ο AI Λύτης Μαθηματικών χρησιμοποιεί προηγμένη τεχνητή νοημοσύνη για να σαρώσει, αναγνωρίσει και λύσει μαθηματικά προβλήματα από φωτογραφία. Είτε είναι ερώτηση βιβλίου, χειρόγραφη εξίσωση ή φύλλο εργασίας — στρέψτε την κάμερα και πάρτε λεπτομερή λύση βήμα προς βήμα σε δευτερόλεπτα.

ΤΙ ΜΠΟΡΕΙΤΕ ΝΑ ΚΑΝΕΤΕ:
- Τραβήξτε φωτογραφία οποιουδήποτε μαθηματικού προβλήματος ή εισάγετε από τη γκαλερί
- Περικόψτε και επιλέξτε ακριβώς το πρόβλημα που θέλετε να λύσετε
- Λάβετε άμεσες λύσεις AI με πλήρεις εξηγήσεις βήμα προς βήμα
- Ανασκοπήστε όλα τα λυμένα προβλήματά σας σε αναζητήσιμο ιστορικό
- Μοιραστείτε λύσεις ως όμορφες εικόνες

ΘΕΜΑΤΑ ΜΑΘΗΜΑΤΙΚΩΝ:
- Αριθμητική και Βασικά Μαθηματικά
- Άλγεβρα και Γραμμική Άλγεβρα
- Γεωμετρία και Τριγωνομετρία
- Ανάλυση και Διαφορικές Εξισώσεις
- Στατιστική και Πιθανότητες
- Προβλήματα λογικής

ΠΡΟΣΑΡΜΟΖΕΤΑΙ ΣΤΟ ΕΠΙΠΕΔΟ ΣΑΣ:
Επιλέξτε το εκπαιδευτικό σας επίπεδο — Δημοτικό, Γυμνάσιο, Λύκειο/Πανελλήνιες ή Πανεπιστήμιο — και η AI προσαρμόζει τις εξηγήσεις. Απλή γλώσσα για μικρότερους μαθητές, λεπτομερείς αποδείξεις για προχωρημένους.

Ιδανικό για προετοιμασία Πανελληνίων!

ΠΛΗΡΟΦΟΡΙΕΣ ΣΥΝΔΡΟΜΗΣ:
Ορισμένες λειτουργίες απαιτούν ενεργή συνδρομή για πλήρη πρόσβαση.
- Επιλογές συνδρομής: Εβδομαδιαία και Ετήσια πλάνα διαθέσιμα
- Η πληρωμή χρεώνεται στον λογαριασμό Apple ID σας κατά την επιβεβαίωση αγοράς
- Η συνδρομή ανανεώνεται αυτόματα εκτός αν ακυρωθεί τουλάχιστον 24 ώρες πριν τη λήξη
- Ο λογαριασμός σας θα χρεωθεί για ανανέωση εντός 24 ωρών πριν τη λήξη
- Μπορείτε να διαχειριστείτε τις συνδρομές σας στις ρυθμίσεις Apple ID μετά την αγορά

Πολιτική Απορρήτου: {PRIVACY_URL}
Οροι Χρήσης: {TERMS_URL}""",

    "hu": f"""Oldjon meg barmilyen matekfeladatot azonnal — csak fotózza le!

Az AI Matek Megoldo fejlett mestereges intelligenciat hasznal, hogy fotóról beolvassa, felismerje es megoldja a matekfeladatokat. Legyen az tankonyvi kerdes, kezzel irt egyenlet vagy hazi feladat — iranyitsa ra a kamerat es masodpercek alatt reszletes lepesrol lepesre megoldast kap.

AMIT TEHET:
- Fotozzon le barmilyen matekfeladatot vagy importaljon a galeriabol
- Vagia ki es valassza ki pontosan a megoldani kivant feladatot
- Kapjon azonnali AI-alapu megoldasokat teljes lepesrol lepesre magyarazattal
- Tekintse at az osszes megoldott feladatat keresheto elozmenyekben
- Ossza meg a megoldasokat szep kepkent

MATEMATIKAI TEMAK:
- Aritmetika es alapszintu matematika
- Algebra es linearis algebra
- Geometria es trigonometria
- Analizis es differencialegyenletek
- Statisztika es valoszinusegszamitas
- Szoveges feladatok

ALKALMAZKODIK AZ ON SZINTJEHEZ:
Valassza ki az iskolai szintet — Altananos iskola, Kozepiskola, Erettsegi vagy Egyetem — es az AI igazitja a magyarazatait. Egyszeru nyelv a fiatalabb diakoknak, reszletes bizonyitasok a halodoknak.

Tokeletes erettsegire felkeszuleshez!

ELOFIZETES INFORMACIO:
Egyes funkciok aktiv elofizetest igenyelnek a teljes hozzafereshez.
- Elofizetest opciok: Heti es Eves csomagok erhetok el
- A fizetes az Apple ID fiokjabol kerul levonasra a vasarlas megerositesekor
- Az elofizetes automatikusan megujul, hacsak legalabb 24 oraval az aktualis idoszak vege elott nem mondja le
- Fiokkjabol 24 oran belul kerul levonasra a megujitas dija az aktualis idoszak vege elott
- Elofizetesei a vasarlas utan az Apple ID fiokbeallitasaiban kezelhetok es lemondhatók

Adatvedelmi iranyelvek: {PRIVACY_URL}
Felhasznalasi feltetelek: {TERMS_URL}""",

    "id": f"""Selesaikan soal matematika apapun secara instan — cukup ambil foto!

AI Pemecah Matematika menggunakan kecerdasan buatan canggih untuk memindai, mengenali, dan menyelesaikan soal matematika dari foto. Baik itu soal buku pelajaran, persamaan tulisan tangan, atau lembar PR — arahkan kamera dan dapatkan solusi detail langkah demi langkah dalam hitungan detik.

YANG BISA ANDA LAKUKAN:
- Ambil foto soal matematika apapun atau impor dari galeri
- Potong dan pilih soal yang ingin diselesaikan dengan tepat
- Dapatkan solusi instan berbasis AI dengan penjelasan lengkap langkah demi langkah
- Tinjau semua soal yang telah diselesaikan di riwayat yang bisa dicari
- Bagikan solusi sebagai gambar yang indah

TOPIK MATEMATIKA:
- Aritmatika dan Matematika Dasar
- Aljabar dan Aljabar Linear
- Geometri dan Trigonometri
- Kalkulus dan Persamaan Diferensial
- Statistika dan Probabilitas
- Soal Cerita

MENYESUAIKAN DENGAN LEVEL ANDA:
Pilih tingkat pendidikan — SD, SMP, SMA atau Universitas — dan AI menyesuaikan penjelasannya. Bahasa sederhana untuk siswa muda, bukti detail untuk yang mahir.

Sempurna untuk persiapan UTBK dan SNBT!

INFORMASI BERLANGGANAN:
Beberapa fitur memerlukan langganan aktif untuk akses penuh.
- Opsi berlangganan: paket Mingguan dan Tahunan tersedia
- Pembayaran dibebankan ke akun Apple ID Anda saat konfirmasi pembelian
- Langganan otomatis diperpanjang kecuali dibatalkan setidaknya 24 jam sebelum akhir periode saat ini
- Akun Anda akan dikenakan biaya perpanjangan dalam 24 jam sebelum akhir periode saat ini
- Anda dapat mengelola dan membatalkan langganan di Pengaturan Akun Apple ID setelah pembelian

Kebijakan Privasi: {PRIVACY_URL}
Ketentuan Penggunaan: {TERMS_URL}""",

    "ms": f"""Selesaikan sebarang masalah matematik serta-merta — cuma ambil gambar!

AI Penyelesai Matematik menggunakan kecerdasan buatan canggih untuk mengimbas, mengenal pasti dan menyelesaikan masalah matematik daripada gambar. Sama ada soalan buku teks, persamaan tulisan tangan atau kerja rumah — halakan kamera dan dapatkan penyelesaian terperinci langkah demi langkah dalam beberapa saat.

APA YANG ANDA BOLEH BUAT:
- Ambil gambar sebarang masalah matematik atau import dari galeri
- Pangkas dan pilih masalah yang ingin diselesaikan dengan tepat
- Dapatkan penyelesaian serta-merta AI dengan penerangan lengkap langkah demi langkah
- Semak semua masalah yang diselesaikan dalam sejarah yang boleh dicari
- Kongsi penyelesaian sebagai gambar yang cantik

TOPIK MATEMATIK:
- Aritmetik dan Matematik Asas
- Algebra dan Algebra Linear
- Geometri dan Trigonometri
- Kalkulus dan Persamaan Pembezaan
- Statistik dan Kebarangkalian
- Masalah Bercerita

MENYESUAIKAN DENGAN TAHAP ANDA:
Pilih tahap pendidikan — Sekolah Rendah, Menengah, SPM atau Universiti — dan AI menyesuaikan penerangannya. Bahasa mudah untuk pelajar muda, bukti terperinci untuk pelajar maju.

Sesuai untuk persediaan UPSR dan SPM!

MAKLUMAT LANGGANAN:
Sesetengah ciri memerlukan langganan aktif untuk akses penuh.
- Pilihan langganan: pelan Mingguan dan Tahunan tersedia
- Bayaran dikenakan ke akaun Apple ID anda semasa pengesahan pembelian
- Langganan diperbaharui secara automatik kecuali dibatalkan sekurang-kurangnya 24 jam sebelum tamat tempoh semasa
- Akaun anda akan dicaj untuk pembaharuan dalam masa 24 jam sebelum tamat tempoh semasa
- Anda boleh mengurus dan membatalkan langganan di Tetapan Akaun Apple ID selepas pembelian

Dasar Privasi: {PRIVACY_URL}
Terma Penggunaan: {TERMS_URL}""",

    "no": f"""Los ethvert matteproblem med en gang — bare ta et bilde!

AI Matte Loser bruker avansert kunstig intelligens for a skanne, gjenkjenne og lose matteproblemer fra et bilde. Enten det er et sporsmaal fra boken, en handskrevet ligning eller lekser — pek kameraet og fa en detaljert steg-for-steg losning pa sekunder.

HVA DU KAN GJORE:
- Ta et bilde av ethvert matteproblem eller importer fra galleriet
- Beskjaer og velg noyaktig det problemet du vil lose
- Fa ojeblikkelige AI-drevne losninger med fulle steg-for-steg forklaringer
- Ga gjennom alle loste problemer i en sokbar historikk
- Del losninger som vakre bilder

MATTEEMNER:
- Aritmetikk og grunnleggende matematikk
- Algebra og lineaer algebra
- Geometri og trigonometri
- Kalkulus og differensialligninger
- Statistikk og sannsynlighet
- Tekstoppgaver

TILPASSER SEG DITT NIVA:
Velg utdanningsniva — Barneskole, Ungdomsskole, VGS eller Universitet — og AI-en tilpasser sine forklaringer. Enkelt sprak for yngre elever, detaljerte bevis for viderekomne.

ABONNEMENTSINFORMASJON:
Noen funksjoner krever et aktivt abonnement for full tilgang.
- Abonnementsalternativer: Ukentlige og Arlige planer tilgjengelig
- Betaling belastes Apple ID-kontoen din ved bekreftelse av kjop
- Abonnementet fornyes automatisk med mindre det sies opp minst 24 timer for slutten av gjeldende periode
- Kontoen din vil bli belastet for fornyelse innen 24 timer for slutten av gjeldende periode
- Du kan administrere og si opp abonnementene dine i Apple ID-kontoinnstillingene etter kjop

Personvernregler: {PRIVACY_URL}
Bruksvilkar: {TERMS_URL}""",

    "pl": f"""Rozwiaz dowolne zadanie z matematyki natychmiast — po prostu zrob zdjecie!

AI Rozwiaz Matematyke wykorzystuje zaawansowana sztuczna inteligencje do skanowania, rozpoznawania i rozwiazywania zadan matematycznych ze zdjecia. Czy to pytanie z podrecznika, reczne napisane rownanie czy karta pracy domowej — skieruj aparat i w kilka sekund otrzymaj szczegolowe rozwiazanie krok po kroku.

CO MOZESZ ZROBIC:
- Zrob zdjecie dowolnego zadania z matematyki lub zaimportuj z galerii
- Przytnij i wybierz dokladnie zadanie, ktore chcesz rozwiazac
- Uzyskaj natychmiastowe rozwiazania AI z pelnymi wyjasnieniami krok po kroku
- Przegladaj wszystkie rozwiazane zadania w przeszukiwalnej historii
- Udostepniaj rozwiazania jako piekne obrazy

TEMATY MATEMATYCZNE:
- Arytmetyka i matematyka podstawowa
- Algebra i algebra liniowa
- Geometria i trygonometria
- Rachunek rozniczkowy i rownania rozniczkowe
- Statystyka i prawdopodobienstwo
- Zadania tekstowe

DOSTOSOWUJE SIE DO TWOJEGO POZIOMU:
Wybierz swoj poziom edukacji — Szkola Podstawowa, Liceum, Matura lub Uniwersytet — a AI dostosuje swoje wyjasnienia. Prosty jezyk dla mlodszych uczniow, szczegolowe dowody dla zaawansowanych.

Idealny do przygotowania do matury!

INFORMACJE O SUBSKRYPCJI:
Niektore funkcje wymagaja aktywnej subskrypcji dla pelnego dostepu.
- Opcje subskrypcji: dostepne plany Tygodniowe i Roczne
- Platnosc jest pobierana z konta Apple ID przy potwierdzeniu zakupu
- Subskrypcja automatycznie sie odnawia, chyba ze zostanie anulowana co najmniej 24 godziny przed koncem biezacego okresu
- Z konta zostanie pobrana oplata za odnowienie w ciagu 24 godzin przed koncem biezacego okresu
- Subskrypcjami mozna zarzadzac i je anulowac w Ustawieniach konta Apple ID po zakupie

Polityka Prywatnosci: {PRIVACY_URL}
Warunki Uzytkowania: {TERMS_URL}""",

    "ro": f"""Rezolvati orice problema de matematica instantaneu — faceti doar o poza!

AI Rezolvator Mate foloseste inteligenta artificiala avansata pentru a scana, recunoaste si rezolva probleme de matematica dintr-o fotografie. Fie ca este o intrebare din manual, o ecuatie scrisa de mana sau un tema — indreptati camera si obtineti o solutie detaliata pas cu pas in cateva secunde.

CE PUTETI FACE:
- Fotografiati orice problema de matematica sau importati din galerie
- Decupati si selectati exact problema pe care doriti sa o rezolvati
- Obtineti solutii instantanee AI cu explicatii complete pas cu pas
- Revizuiti toate problemele rezolvate intr-un istoric cu cautare
- Distribuiti solutiile ca imagini frumoase

SUBIECTE DE MATEMATICA:
- Aritmetica si Matematica de baza
- Algebra si Algebra liniara
- Geometrie si Trigonometrie
- Calcul diferential si Ecuatii diferentiale
- Statistica si Probabilitate
- Probleme de rationament

SE ADAPTEAZA LA NIVELUL TAU:
Alege nivelul de educatie — Scoala Primara, Gimnaziu, Liceu/BAC sau Universitate — si AI isi adapteaza explicatiile. Limbaj simplu pentru elevii mai mici, demonstratii detaliate pentru avansati.

Perfect pentru pregatirea BAC-ului!

INFORMATII DESPRE ABONAMENT:
Unele functii necesita un abonament activ pentru acces complet.
- Optiuni de abonament: planuri Saptamanal si Anual disponibile
- Plata se percepe din contul Apple ID la confirmarea achizitiei
- Abonamentul se reinnoieste automat daca nu este anulat cu cel putin 24 de ore inainte de sfarsitul perioadei curente
- Contul dumneavoastra va fi taxat pentru reinnoire in termen de 24 de ore inainte de sfarsitul perioadei curente
- Puteti gestiona si anula abonamentele in Setarile contului Apple ID dupa achizitie

Politica de Confidentialitate: {PRIVACY_URL}
Termeni de Utilizare: {TERMS_URL}""",

    "sk": f"""Vyriesite akykolvek matematicky priklad okamzite — staci odfotit!

AI Riesitel Matematiky vyuziva pokrocilu umelú inteligenciu na skenovanie, rozpoznavanie a riesenie matematickych problemov z fotografie. Ci uz je to otazka z ucebnice, rucne napisana rovnica alebo domaca uloha — namierte fotoaparat a za sekundy ziskajte podrobne riesenie krok za krokom.

CO MOZETE ROBIT:
- Odfodte akykolvek matematicky priklad alebo importujte z galerie
- Orezte a vyberte presne ten problem, ktory chcete vyriesit
- Ziskajte okamzite AI riesenia s uplnymi vysvetleniami krok za krokom
- Prezrite si vsetky vyriesene priklady v prehladavatelnej historii
- Zdielate riesenia ako pekne obrazky

MATEMATICKE TEMY:
- Aritmetika a zakladna matematika
- Algebra a linearna algebra
- Geometria a trigonometria
- Kalkulus a diferencialne rovnice
- Statistika a pravdepodobnost
- Slovne ulohy

PRIZPOSOBI SA VASEJ UROVNI:
Zvolte svoju uroven vzdelania — Zakladna skola, Stredna skola, Maturita alebo Univerzita — a AI prizposobi svoje vysvetlenia. Jednoduchy jazyk pre mladsich ziakov, podrobne dokazy pre pokrocilych.

Idealny na pripravu na maturitu!

INFORMACIE O PREDPLATNOM:
Niektore funkcie vyzaduju aktivne predplatne pre plny pristup.
- Moznosti predplatneho: dostupne Tyzdenne a Rocne plany
- Platba je uctovana na vas ucet Apple ID pri potvrdeni nakupu
- Predplatne sa automaticky obnovuje, pokial nie je zrusene aspon 24 hodin pred koncom aktualneho obdobia
- Vas ucet bude zatazeny obnovenim do 24 hodin pred koncom aktualneho obdobia
- Svoje predplatne mozete spravovat a zrusit v nastaveniach uctu Apple ID po nakupe

Zasady ochrany osobnych udajov: {PRIVACY_URL}
Podmienky pouzivania: {TERMS_URL}""",

    "sv": f"""Los vilket matteproblem som helst direkt — ta bara ett foto!

AI Matte Losare anvander avancerad artificiell intelligens for att skanna, kanna igen och losa matteproblem fran ett foto. Oavsett om det ar en fraga fran boken, en handskriven ekvation eller laxor — rikta kameran och fa en detaljerad steg-for-steg losning pa sekunder.

VAD DU KAN GORA:
- Ta ett foto av vilket matteproblem som helst eller importera fran galleriet
- Beskara och valj exakt det problem du vill losa
- Fa omedelbara AI-drivna losningar med fullstandiga steg-for-steg forklaringar
- Granska alla losta problem i en sokbar historik
- Dela losningar som snygga bilder

MATTEAMNEN:
- Aritmetik och grundlaggande matematik
- Algebra och linjar algebra
- Geometri och trigonometri
- Kalkyl och differentialekvationer
- Statistik och sannolikhet
- Textuppgifter

ANPASSAR SIG TILL DIN NIVA:
Valj din utbildningsniva — Grundskola, Hogstadiet, Gymnasiet/NP eller Universitet — och AI:n anpassar sina forklaringar. Enkelt sprak for yngre elever, detaljerade bevis for avancerade.

PRENUMERATIONSINFORMATION:
Vissa funktioner kraver en aktiv prenumeration for full atkomst.
- Prenumerationsalternativ: Vecko- och Arsplaner tillgangliga
- Betalning debiteras fran ditt Apple ID-konto vid kopbekraftelse
- Prenumerationen fornyas automatiskt om den inte avbryts minst 24 timmar fore slutet av innevarande period
- Ditt konto debiteras for fornyelse inom 24 timmar fore slutet av innevarande period
- Du kan hantera och avbryta prenumerationer i Apple ID-kontointstallningarna efter kop

Integritetspolicy: {PRIVACY_URL}
Anvandarvillkor: {TERMS_URL}""",

    "th": f"""แก้โจทย์เลขได้ทันที — แค่ถ่ายรูป!

AI แก้โจทย์เลข ใช้ปัญญาประดิษฐ์ขั้นสูงในการสแกน จดจำ และแก้โจทย์คณิตศาสตร์จากรูปถ่าย ไม่ว่าจะเป็นโจทย์ในหนังสือ สมการที่เขียนด้วยมือ หรือการบ้าน — เล็งกล้องแล้วรับคำตอบแบบทีละขั้นตอนอย่างละเอียดภายในไม่กี่วินาที

สิ่งที่คุณทำได้:
- ถ่ายรูปโจทย์เลขหรือนำเข้าจากแกลเลอรี
- ครอปและเลือกโจทย์ที่ต้องการแก้อย่างแม่นยำ
- รับคำตอบจาก AI ทันทีพร้อมคำอธิบายทีละขั้นตอนอย่างครบถ้วน
- ดูโจทย์ที่แก้แล้วทั้งหมดในประวัติที่ค้นหาได้
- แชร์คำตอบเป็นรูปภาพสวยงาม

หัวข้อคณิตศาสตร์:
- เลขคณิตและคณิตศาสตร์พื้นฐาน
- พีชคณิตและพีชคณิตเชิงเส้น
- เรขาคณิตและตรีโกณมิติ
- แคลคูลัสและสมการเชิงอนุพันธ์
- สถิติและความน่าจะเป็น
- โจทย์ปัญหา

ปรับให้เข้ากับระดับของคุณ:
เลือกระดับการศึกษา — ประถม มัธยมต้น มัธยมปลาย หรือมหาวิทยาลัย — แล้ว AI จะปรับคำอธิบาย ภาษาง่ายสำหรับนักเรียนเล็ก การพิสูจน์ละเอียดสำหรับผู้เรียนขั้นสูง

เหมาะสำหรับเตรียมสอบ GAT PAT และ O-NET!

ข้อมูลการสมัครสมาชิก:
บางฟีเจอร์ต้องมีการสมัครสมาชิกเพื่อเข้าถึงทั้งหมด
- ตัวเลือกการสมัครสมาชิก: แผนรายสัปดาห์และรายปี
- การชำระเงินจะเรียกเก็บจากบัญชี Apple ID ของคุณเมื่อยืนยันการซื้อ
- การสมัครสมาชิกจะต่ออายุอัตโนมัติ เว้นแต่จะยกเลิกอย่างน้อย 24 ชั่วโมงก่อนสิ้นสุดรอบปัจจุบัน
- บัญชีของคุณจะถูกเรียกเก็บค่าต่ออายุภายใน 24 ชั่วโมงก่อนสิ้นสุดรอบปัจจุบัน
- คุณสามารถจัดการและยกเลิกการสมัครสมาชิกได้ในการตั้งค่าบัญชี Apple ID หลังจากซื้อ

นโยบายความเป็นส่วนตัว: {PRIVACY_URL}
ข้อกำหนดการใช้งาน: {TERMS_URL}""",

    "uk": f"""Розвʼяжіть будь-яку задачу з математики миттєво — просто зробіть фото!

AI Розвʼязувач Математики використовує передовий штучний інтелект для сканування, розпізнавання та розвʼязання математичних задач з фотографії. Чи це задача з підручника, рукописне рівняння або домашнє завдання — наведіть камеру та отримайте детальний покроковий розвʼязок за секунди.

ЩО ВИ МОЖЕТЕ:
- Сфотографуйте будь-яку задачу або імпортуйте з галереї
- Обріжте та виберіть саме ту задачу, яку хочете розвʼязати
- Отримайте миттєві розвʼязки від ШІ з повним покроковим поясненням
- Переглядайте всі розвʼязані задачі в історії з пошуком
- Діліться розвʼязками як гарними зображеннями

ТЕМИ З МАТЕМАТИКИ:
- Арифметика та основи математики
- Алгебра та лінійна алгебра
- Геометрія та тригонометрія
- Математичний аналіз та диференціальні рівняння
- Статистика та теорія ймовірностей
- Текстові задачі

АДАПТУЄТЬСЯ ДО ВАШОГО РІВНЯ:
Оберіть рівень освіти — Початкова школа, Середня школа, Старші класи або Університет — і ШІ адаптує свої пояснення. Проста мова для молодших учнів, детальні доведення для просунутих.

Ідеально для підготовки до НМТ та ЗНО!

ІНФОРМАЦІЯ ПРО ПІДПИСКУ:
Деякі функції потребують активної підписки для повного доступу.
- Варіанти підписки: доступні Щотижневий та Річний плани
- Оплата стягується з вашого облікового запису Apple ID при підтвердженні покупки
- Підписка автоматично поновлюється, якщо не скасована мінімум за 24 години до закінчення поточного періоду
- З вашого рахунку буде стягнуто плату за поновлення протягом 24 годин до закінчення поточного періоду
- Ви можете керувати підписками та скасовувати їх у налаштуваннях облікового запису Apple ID після покупки

Політика конфіденційності: {PRIVACY_URL}
Умови використання: {TERMS_URL}""",

    "vi": f"""Giai bat ky bai toan nao ngay lap tuc — chi can chup anh!

AI Giai Toan su dung tri tue nhan tao tien tien de quet, nhan dien va giai cac bai toan tu anh chup. Du la cau hoi trong sach giao khoa, phuong trinh viet tay hay bai tap ve nha — huong camera va nhan loi giai chi tiet tung buoc trong vai giay.

BAN CO THE LAM GI:
- Chup anh bat ky bai toan nao hoac nhap tu thu vien anh
- Cat va chon chinh xac bai toan ban muon giai
- Nhan loi giai AI ngay lap tuc voi giai thich day du tung buoc
- Xem lai tat ca cac bai da giai trong lich su co the tim kiem
- Chia se loi giai duoi dang hinh anh dep

CAC CHU DE TOAN HOC:
- So hoc va Toan co ban
- Dai so va Dai so tuyen tinh
- Hinh hoc va Luong giac
- Giai tich va Phuong trinh vi phan
- Thong ke va Xac suat
- Bai toan co loi van

THICH UNG VOI TRINH DO CUA BAN:
Chon cap hoc — Tieu hoc, THCS, THPT hoac Dai hoc — va AI dieu chinh giai thich. Ngon ngu don gian cho hoc sinh nho, chung minh chi tiet cho nguoi hoc nang cao.

Hoan hao de chuan bi thi THPT Quoc gia!

THONG TIN DANG KY:
Mot so tinh nang yeu cau dang ky de truy cap day du.
- Tuy chon dang ky: goi Hang tuan va Hang nam
- Thanh toan duoc tru tu tai khoan Apple ID cua ban khi xac nhan mua
- Dang ky tu dong gia han tru khi bi huy it nhat 24 gio truoc khi ket thuc ky hien tai
- Tai khoan cua ban se bi tru phi gia han trong vong 24 gio truoc khi ket thuc ky hien tai
- Ban co the quan ly va huy dang ky trong Cai dat Tai khoan Apple ID sau khi mua

Chinh sach Bao mat: {PRIVACY_URL}
Dieu khoan Su dung: {TERMS_URL}""",

    "ca": f"""Resoleu qualsevol problema de mates a l'instant — feu una foto!

El Resolvedor de Mates amb IA utilitza intel·ligencia artificial avancada per escanejar, reconèixer i resoldre problemes de matematiques des d'una foto. Ja sigui una pregunta del llibre, una equació escrita a ma o deures — apunteu la camera i obteniu una solucio detallada pas a pas en segons.

QUE PODEU FER:
- Feu una foto de qualsevol problema de mates o importeu de la galeria
- Retalleu i seleccioneu exactament el problema que voleu resoldre
- Obtingueu solucions instantanies amb explicacions completes pas a pas
- Reviseu tots els problemes resolts en un historial cercable
- Compartiu solucions com a imatges boniques

TEMES DE MATEMATIQUES:
- Aritmetica i Matematiques basiques
- Algebra i Algebra lineal
- Geometria i Trigonometria
- Calcul i Equacions diferencials
- Estadistica i Probabilitat
- Problemes de raonament

S'ADAPTA AL VOSTRE NIVELL:
Trieu el vostre nivell educatiu — Primaria, ESO, Batxillerat/Selectivitat o Universitat — i la IA adapta les seves explicacions. Llenguatge senzill per als mes joves, demostracions detallades per als avancats.

Perfecte per preparar la Selectivitat i la PAU!

INFORMACIO SOBRE LA SUBSCRIPCIO:
Algunes funcions requereixen una subscripcio activa per a l'acces complet.
- Opcions de subscripcio: plans Setmanal i Anual disponibles
- El pagament es cobra al vostre compte Apple ID en confirmar la compra
- La subscripcio es renova automaticament tret que es cancel·li almenys 24 hores abans del final del periode actual
- El vostre compte sera cobrat per la renovacio dins de les 24 hores anteriors al final del periode actual
- Podeu gestionar i cancel·lar les vostres subscripcions a la Configuracio del compte Apple ID despres de la compra

Politica de Privacitat: {PRIVACY_URL}
Termes d'Us: {TERMS_URL}""",
}

# Promotional texts (already in native languages from LOCALES dict)
PROMO_TEXTS = {
    "en-US": "Snap a photo of any math problem and get instant AI-powered step-by-step solutions. From algebra to calculus — your personal math tutor is here!",
    "en-GB": "Snap a photo of any maths problem and get instant AI-powered step-by-step solutions. From GCSE to A-level — your personal maths tutor is here!",
    "en-AU": "Snap a photo of any maths problem and get instant AI-powered step-by-step solutions. From Year 7 to university — your personal maths tutor!",
    "en-CA": "Snap a photo of any math problem and get instant AI-powered step-by-step solutions. From algebra to calculus — your personal math tutor is here!",
    "fr-FR": "Prenez en photo un probleme de maths et obtenez des solutions detaillees etape par etape grace a l'IA. Du college au BAC, votre tuteur personnel!",
    "fr-CA": "Prenez en photo un probleme de maths et obtenez des solutions detaillees etape par etape grace a l'IA. Du secondaire au CEGEP, votre tuteur!",
    "de-DE": "Fotografiere jede Matheaufgabe und erhalte sofort KI-gestutzte Schritt-fur-Schritt-Losungen. Vom Gymnasium bis zum Abitur — dein Mathe-Nachhilfelehrer!",
    "es-ES": "Haz una foto de cualquier problema de mates y obtiene soluciones paso a paso con IA. De la ESO a Selectividad, tu tutor de matematicas personal!",
    "es-MX": "Toma una foto de cualquier problema de mates y obtiene soluciones paso a paso con IA. De la prepa a la universidad, tu tutor personal!",
    "pt-BR": "Tire uma foto de qualquer problema de matematica e receba solucoes passo a passo com IA. Do ensino medio ao ENEM — seu tutor pessoal!",
    "pt-PT": "Tire uma foto de qualquer problema de matematica e receba solucoes passo a passo com IA. Do secundario ao exame — o seu explicador pessoal!",
    "it": "Scatta una foto di qualsiasi problema di matematica e ottieni soluzioni passo dopo passo con l'IA. Dalla scuola alla maturita — il tuo tutor!",
    "nl-NL": "Maak een foto van elk wiskundeprobleem en krijg direct AI-gestuurde stap-voor-stap oplossingen. Van HAVO tot VWO — jouw persoonlijke bijles!",
    "ja": "数学の問題を写真に撮るだけで、AIがステップごとに解説。小学校から大学まで、あなた専属の数学チューター!",
    "ko": "수학 문제를 사진으로 찍으면 AI가 단계별로 풀이해드립니다. 중학교부터 수능까지, 나만의 수학 과외 선생님!",
    "zh-Hans": "拍照即可解题，AI智能分步解答。从小学到高考，你的专属数学辅导老师！",
    "zh-Hant": "拍照即可解題，AI智慧分步解答。從國中到學測，你的專屬數學輔導老師！",
    "ar-SA": "صور اي مسألة رياضيات واحصل على حلول فورية خطوة بخطوة بالذكاء الاصطناعي. من الابتدائية الى الجامعة!",
    "tr": "Matematik problemini fotoğrafla, AI anında adım adım çözüm üretsin. İlkokuldan YKS'ye kadar — senin kişisel matematik öğretmenin!",
    "ru": "Сфотографируйте любую задачу по математике и получите пошаговое решение с помощью ИИ. От школы до ЕГЭ — ваш персональный репетитор!",
    "hi": "Kisi bhi math problem ki photo lo aur AI se turant step-by-step solution pao. School se JEE tak — aapka personal math tutor!",
    "he": "צלמו כל בעיית מתמטיקה וקבלו פתרון מיידי צעד אחר צעד בעזרת AI. מחטיבה ועד בגרות — המורה הפרטי שלכם!",
    "hr": "Fotografirajte matematicki problem i dobijte AI rjesenja korak po korak. Od osnovne do mature — vas osobni tutor!",
    "cs": "Vyfoťte jakýkoliv matematicky priklad a ziskejte AI reseni krok za krokem. Od zakladky po maturitu — vas osobni doucovatel!",
    "da": "Tag et foto af ethvert matematikproblem og fa AI-drevne losninger trin for trin. Fra folkeskole til gymnasium — din personlige tutor!",
    "fi": "Ota kuva mista tahansa matikkaongelmasta ja saat AI-ratkaisun vaihe vaiheelta. Peruskoulusta ylioppilaaseen — oma matikkaopettajasi!",
    "el": "Φωτογραφίστε οποιοδήποτε μαθηματικό πρόβλημα και λάβετε λύσεις βήμα προς βήμα με AI. Από το γυμνάσιο ως τις Πανελλήνιες!",
    "hu": "Fotózd le bármely matekfeladatot és kapj AI-alapú megoldást lépésről lépésre. Általánostól az érettségiig — személyes tanárod!",
    "id": "Foto soal matematika apapun dan dapatkan solusi langkah demi langkah dengan AI. Dari SD sampai UTBK — tutor pribadi kamu!",
    "ms": "Ambil gambar sebarang masalah matematik dan dapatkan penyelesaian langkah demi langkah dengan AI. Dari UPSR ke SPM — tutor peribadi anda!",
    "no": "Ta bilde av et hvilket som helst matteproblem og fa AI-drevne losninger steg for steg. Fra ungdomsskole til VGS — din personlige tutor!",
    "pl": "Zrob zdjecie dowolnego zadania z matematyki i uzyskaj rozwiazania AI krok po kroku. Od podstawowki do matury — Twoj osobisty korepetytor!",
    "ro": "Fotografiaza orice problema de matematica si obtii solutii pas cu pas cu AI. De la generala pana la BAC — tutorele tau personal!",
    "sk": "Odfoťte akýkoľvek matematický príklad a získajte AI riešenia krok za krokom. Od základky po maturitu — váš osobný doučovateľ!",
    "sv": "Ta en bild pa vilket matteproblem som helst och fa AI-drivna losningar steg for steg. Fran hogstadiet till NP — din personliga mattelektor!",
    "th": "ถ่ายรูปโจทย์เลขแล้วได้เฉลยทีละขั้นตอนจาก AI ทันที ตั้งแต่ประถมถึงมหาวิทยาลัย — ติวเตอร์ส่วนตัวของคุณ!",
    "uk": "Сфотографуйте будь-яку задачу з математики та отримайте покрокове розвʼязання з AI. Від школи до НМТ — ваш персональний репетитор!",
    "vi": "Chup anh bat ky bai toan nao va nhan loi giai chi tiet tung buoc tu AI. Tu cap 2 den THPT — gia su rieng cua ban!",
    "ca": "Fes una foto de qualsevol problema de mates i obtingues solucions pas a pas amb IA. De l'ESO a la Selectivitat — el teu tutor personal!",
}


def main():
    print("=" * 60)
    print("MathPro - Localized Description & Promo Uploader")
    print(f"  Languages: {len(DESCRIPTIONS)}")
    print("=" * 60)

    # Get IDs
    print("\n[1] Finding app...")
    data = requests.get(f"{BASE}/apps", headers=hdrs(), params={"filter[bundleId]": BUNDLE_ID}).json()
    app_id = data["data"][0]["id"]
    print(f"  App: {data['data'][0]['attributes']['name']} ({app_id})")

    print("\n[2] Getting Version...")
    data = requests.get(f"{BASE}/apps/{app_id}/appStoreVersions", headers=hdrs(),
                        params={"filter[platform]": "IOS", "limit": 1}).json()
    version_id = data["data"][0]["id"]
    print(f"  Version: {data['data'][0]['attributes']['versionString']}")

    # Get existing version localizations
    print("\n[3] Getting existing version localizations...")
    all_locs = []
    url = f"{BASE}/appStoreVersions/{version_id}/appStoreVersionLocalizations"
    params = {"limit": 50}
    while url:
        resp = requests.get(url, headers=hdrs(), params=params)
        if resp.status_code != 200:
            break
        rdata = resp.json()
        all_locs.extend(rdata.get("data", []))
        url = rdata.get("links", {}).get("next")
        params = {}

    ver_locs = {l["attributes"]["locale"]: l["id"] for l in all_locs}
    print(f"  Found {len(ver_locs)} version localizations")

    # Update each locale
    print("\n[4] Uploading localized descriptions & promo texts...")
    print("-" * 60)

    ok = 0
    fail = 0

    for locale in sorted(DESCRIPTIONS.keys()):
        desc = DESCRIPTIONS[locale]
        promo = PROMO_TEXTS.get(locale, "")

        if locale not in ver_locs:
            print(f"  [{locale}] ⚠ No version localization found, skipping")
            fail += 1
            continue

        loc_id = ver_locs[locale]
        attrs = {"description": desc}
        if promo:
            attrs["promotionalText"] = promo

        success, resp = api_patch(f"/appStoreVersionLocalizations/{loc_id}", {
            "data": {
                "type": "appStoreVersionLocalizations",
                "id": loc_id,
                "attributes": attrs,
            }
        })

        if success:
            print(f"  [{locale}] ✓ Description & Promo updated")
            ok += 1
        else:
            print(f"  [{locale}] ✗ FAILED")
            try:
                err = resp.json()["errors"][0]["detail"]
                print(f"    → {err}")
            except:
                print(f"    → {resp.text[:200]}")
            fail += 1

        time.sleep(0.3)

    print("\n" + "=" * 60)
    print(f"DONE! ✓ {ok} succeeded, ✗ {fail} failed (out of {len(DESCRIPTIONS)} locales)")
    print("=" * 60)


if __name__ == "__main__":
    main()

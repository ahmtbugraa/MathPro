#!/usr/bin/env python3
"""
Fix ALL descriptions and promotional texts with proper diacritics and spelling.
Languages that need fixing: tr, de-DE, fr-FR, fr-CA, es-ES, es-MX, pt-BR, pt-PT,
cs, hr, hu, ro, pl, sv, no, da, fi, vi, sl-SI, sk, hi
"""

import jwt, time, requests, sys

KEY_ID = "F45A64X9CT"
ISSUER_ID = "aa8b074b-c562-463d-86e6-30dd31eb8ef8"
P8_PATH = "/Users/abk/Downloads/AuthKey_F45A64X9CT.p8"
BUNDLE_ID = "com.ahmetbugrakacdi.MathPro"
BASE = "https://api.appstoreconnect.apple.com/v1"

with open(P8_PATH, "r") as f:
    PRIVATE_KEY = f.read()

PRIVACY_URL = "https://www.notion.so/MathPro-Privacy-Policy-32f3887142058088b5f3eae284b4515a"
TERMS_URL = "https://www.notion.so/MathPro-Terms-of-Use-32f38871420580daaf10e5412a61d0e9"


def tok():
    now = int(time.time())
    return jwt.encode(
        {"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
        PRIVATE_KEY, algorithm="ES256",
        headers={"alg": "ES256", "kid": KEY_ID, "typ": "JWT"},
    )


def hdr():
    return {"Authorization": f"Bearer {tok()}", "Content-Type": "application/json"}


# ══════════════════════════════════════════════════════════════
# CORRECTED DESCRIPTIONS & PROMO TEXTS — Proper diacritics
# ══════════════════════════════════════════════════════════════

FIXES = {
    "tr": {
        "promoText": "Matematik problemini fotoğrafla, AI anında adım adım çözüm üretsin. İlkokuldan YKS'ye kadar — senin kişisel matematik öğretmenin!",
        "description": f"""Herhangi bir matematik problemini anında çöz — sadece bir fotoğraf çek!

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
    },

    "de-DE": {
        "promoText": "Fotografiere jede Matheaufgabe und erhalte sofort KI-gestützte Schritt-für-Schritt-Lösungen. Vom Gymnasium bis zum Abitur — dein Mathe-Nachhilfelehrer!",
        "description": f"""Löse jede Matheaufgabe sofort — mach einfach ein Foto!

Der KI Mathe Löser nutzt fortschrittliche künstliche Intelligenz, um Matheaufgaben von einem Foto zu scannen, zu erkennen und zu lösen. Ob Lehrbuchfrage, handgeschriebene Gleichung oder Hausaufgabenblatt — richte deine Kamera darauf und erhalte in Sekunden eine detaillierte Schritt-für-Schritt-Lösung.

WAS DU TUN KANNST:
- Mach ein Foto von jeder Matheaufgabe oder importiere aus deiner Galerie
- Schneide genau das Problem zu, das du lösen möchtest
- Erhalte sofortige KI-gestützte Lösungen mit vollständigen Schritt-für-Schritt-Erklärungen
- Überprüfe alle gelösten Aufgaben in einem durchsuchbaren Verlauf
- Teile Lösungen als schöne Bilder

ABGEDECKTE MATHE-THEMEN:
- Arithmetik und Grundlagen
- Algebra und Lineare Algebra
- Geometrie und Trigonometrie
- Analysis und Differentialgleichungen
- Statistik und Wahrscheinlichkeit
- Textaufgaben

PASST SICH DEINEM NIVEAU AN:
Wähle dein Bildungsniveau — Grundschule, Mittelstufe, Oberstufe/Abitur oder Universität — und die KI passt ihre Erklärungen an. Einfache Sprache für jüngere Schüler, detaillierte Beweise für Fortgeschrittene.

Perfekt für die Abiturvorbereitung!

ABONNEMENT-INFORMATIONEN:
Einige Funktionen erfordern ein aktives Abonnement für den vollen Zugang.
- Abonnementoptionen: Wöchentliche und Jährliche Pläne verfügbar
- Die Zahlung wird bei Kaufbestätigung Ihrem Apple-ID-Konto belastet
- Das Abonnement verlängert sich automatisch, sofern es nicht mindestens 24 Stunden vor Ablauf des aktuellen Zeitraums gekündigt wird
- Ihrem Konto wird die Verlängerung innerhalb von 24 Stunden vor Ablauf des aktuellen Zeitraums berechnet
- Sie können Ihre Abonnements nach dem Kauf in den Apple-ID-Kontoeinstellungen verwalten und kündigen

Datenschutzrichtlinie: {PRIVACY_URL}
Nutzungsbedingungen: {TERMS_URL}""",
    },

    "fr-FR": {
        "promoText": "Prenez en photo un problème de maths et obtenez des solutions détaillées étape par étape grâce à l'IA. Du collège au BAC, votre tuteur personnel !",
        "description": f"""Résolvez n'importe quel problème de maths instantanément — prenez simplement une photo !

Ce solveur de maths IA utilise l'intelligence artificielle avancée pour scanner, reconnaître et résoudre les problèmes de maths à partir d'une photo. Question de manuel, équation manuscrite ou feuille de devoirs — pointez votre caméra et obtenez une solution détaillée étape par étape en quelques secondes.

CE QUE VOUS POUVEZ FAIRE :
- Prenez une photo de n'importe quel problème de maths ou importez depuis votre galerie
- Recadrez et sélectionnez exactement le problème à résoudre
- Obtenez des solutions instantanées avec des explications complètes étape par étape
- Consultez tous vos problèmes résolus dans un historique consultable
- Partagez les solutions sous forme de belles images

SUJETS DE MATHS COUVERTS :
- Arithmétique et Maths de base
- Algèbre et Algèbre linéaire
- Géométrie et Trigonométrie
- Calcul différentiel et Équations différentielles
- Statistiques et Probabilités
- Problèmes de raisonnement

S'ADAPTE À VOTRE NIVEAU :
Choisissez votre niveau — Collège, Lycée, BAC ou Université — et l'IA adapte ses explications. Langage simple pour les plus jeunes, démonstrations détaillées pour les avancés.

INFORMATIONS SUR L'ABONNEMENT :
Certaines fonctionnalités nécessitent un abonnement actif pour un accès complet.
- Options d'abonnement : forfaits Hebdomadaire et Annuel disponibles
- Le paiement est débité de votre compte Apple ID lors de la confirmation d'achat
- L'abonnement se renouvelle automatiquement sauf annulation au moins 24 heures avant la fin de la période en cours
- Votre compte sera débité du renouvellement dans les 24 heures précédant la fin de la période en cours
- Vous pouvez gérer et annuler vos abonnements dans les Réglages de votre identifiant Apple après achat

Politique de confidentialité : {PRIVACY_URL}
Conditions d'utilisation : {TERMS_URL}""",
    },

    "fr-CA": {
        "promoText": "Prenez en photo un problème de maths et obtenez des solutions détaillées étape par étape grâce à l'IA. Du secondaire au CÉGEP, votre tuteur !",
        "description": f"""Résolvez n'importe quel problème de maths instantanément — prenez simplement une photo !

Ce solveur de maths IA utilise l'intelligence artificielle avancée pour scanner, reconnaître et résoudre les problèmes de maths à partir d'une photo. Question de manuel, équation manuscrite ou feuille de devoirs — pointez votre caméra et obtenez une solution détaillée étape par étape en quelques secondes.

CE QUE VOUS POUVEZ FAIRE :
- Prenez une photo de n'importe quel problème de maths ou importez depuis votre galerie
- Recadrez et sélectionnez exactement le problème à résoudre
- Obtenez des solutions instantanées avec des explications complètes étape par étape
- Consultez tous vos problèmes résolus dans un historique consultable
- Partagez les solutions sous forme de belles images

SUJETS DE MATHS COUVERTS :
- Arithmétique et Maths de base
- Algèbre et Algèbre linéaire
- Géométrie et Trigonométrie
- Calcul différentiel et Équations différentielles
- Statistiques et Probabilités
- Problèmes de raisonnement

S'ADAPTE À VOTRE NIVEAU :
Choisissez votre niveau — Primaire, Secondaire, CÉGEP ou Université — et l'IA adapte ses explications. Langage simple pour les plus jeunes, démonstrations détaillées pour les avancés.

INFORMATIONS SUR L'ABONNEMENT :
Certaines fonctionnalités nécessitent un abonnement actif pour un accès complet.
- Options d'abonnement : forfaits Hebdomadaire et Annuel disponibles
- Le paiement est débité de votre compte Apple ID lors de la confirmation d'achat
- L'abonnement se renouvelle automatiquement sauf annulation au moins 24 heures avant la fin de la période en cours
- Votre compte sera débité du renouvellement dans les 24 heures précédant la fin de la période en cours
- Vous pouvez gérer et annuler vos abonnements dans les Réglages de votre identifiant Apple après achat

Politique de confidentialité : {PRIVACY_URL}
Conditions d'utilisation : {TERMS_URL}""",
    },

    "es-ES": {
        "promoText": "Haz una foto de cualquier problema de mates y obtén soluciones paso a paso con IA. De la ESO a Selectividad, ¡tu tutor de matemáticas personal!",
        "description": f"""¡Resuelve cualquier problema de matemáticas al instante — solo haz una foto!

El Resolvedor de Mates con IA utiliza inteligencia artificial avanzada para escanear, reconocer y resolver problemas matemáticos desde una foto. Ya sea una pregunta del libro, una ecuación escrita a mano o una hoja de deberes — apunta tu cámara y obtén una solución detallada paso a paso en segundos.

LO QUE PUEDES HACER:
- Haz una foto de cualquier problema de mates o importa desde tu galería
- Recorta y selecciona exactamente el problema que quieres resolver
- Obtén soluciones instantáneas con explicaciones completas paso a paso
- Revisa todos tus problemas resueltos en un historial con búsqueda
- Comparte soluciones como imágenes

TEMAS DE MATEMÁTICAS:
- Aritmética y Matemáticas básicas
- Álgebra y Álgebra lineal
- Geometría y Trigonometría
- Cálculo y Ecuaciones diferenciales
- Estadística y Probabilidad
- Problemas de razonamiento

SE ADAPTA A TU NIVEL:
Elige tu nivel educativo — Primaria, ESO, Bachillerato/Selectividad o Universidad — y la IA adapta sus explicaciones. Lenguaje sencillo para los más jóvenes, demostraciones detalladas para los avanzados.

INFORMACIÓN DE SUSCRIPCIÓN:
Algunas funciones requieren una suscripción activa para acceso completo.
- Opciones de suscripción: planes Semanal y Anual disponibles
- El pago se carga a tu cuenta de Apple ID al confirmar la compra
- La suscripción se renueva automáticamente a menos que se cancele al menos 24 horas antes del final del período actual
- Se te cobrará la renovación dentro de las 24 horas anteriores al final del período actual
- Puedes gestionar y cancelar tus suscripciones en los Ajustes de tu Apple ID tras la compra

Política de Privacidad: {PRIVACY_URL}
Términos de Uso: {TERMS_URL}""",
    },

    "es-MX": {
        "promoText": "Toma una foto de cualquier problema de mates y obtén soluciones paso a paso con IA. De la prepa a la universidad, ¡tu tutor personal!",
        "description": f"""¡Resuelve cualquier problema de matemáticas al instante — solo toma una foto!

El Resolvedor de Mates con IA utiliza inteligencia artificial avanzada para escanear, reconocer y resolver problemas matemáticos desde una foto. Ya sea una pregunta del libro, una ecuación escrita a mano o una tarea — apunta tu cámara y obtén una solución detallada paso a paso en segundos.

LO QUE PUEDES HACER:
- Toma una foto de cualquier problema de mates o importa desde tu galería
- Recorta y selecciona exactamente el problema que quieres resolver
- Obtén soluciones instantáneas con explicaciones completas paso a paso
- Revisa todos tus problemas resueltos en un historial con búsqueda
- Comparte soluciones como imágenes

TEMAS DE MATEMÁTICAS:
- Aritmética y Matemáticas básicas
- Álgebra y Álgebra lineal
- Geometría y Trigonometría
- Cálculo y Ecuaciones diferenciales
- Estadística y Probabilidad
- Problemas de razonamiento

SE ADAPTA A TU NIVEL:
Elige tu nivel educativo — Primaria, Secundaria, Prepa o Universidad — y la IA adapta sus explicaciones. Lenguaje sencillo para los más jóvenes, demostraciones detalladas para los avanzados.

¡Ideal para preparar exámenes de ingreso a la UNAM y universidades!

INFORMACIÓN DE SUSCRIPCIÓN:
Algunas funciones requieren una suscripción activa para acceso completo.
- Opciones de suscripción: planes Semanal y Anual disponibles
- El pago se carga a tu cuenta de Apple ID al confirmar la compra
- La suscripción se renueva automáticamente a menos que se cancele al menos 24 horas antes del final del período actual
- Se te cobrará la renovación dentro de las 24 horas anteriores al final del período actual
- Puedes gestionar y cancelar tus suscripciones en los Ajustes de tu Apple ID tras la compra

Política de Privacidad: {PRIVACY_URL}
Términos de Uso: {TERMS_URL}""",
    },

    "pt-BR": {
        "promoText": "Tire uma foto de qualquer problema de matemática e receba soluções passo a passo com IA. Do ensino médio ao ENEM — seu tutor pessoal!",
        "description": f"""Resolva qualquer problema de matemática instantaneamente — basta tirar uma foto!

O Resolvedor de Matemática com IA usa inteligência artificial avançada para escanear, reconhecer e resolver problemas de matemática a partir de uma foto. Seja uma questão do livro, uma equação manuscrita ou uma folha de dever — aponte sua câmera e receba uma solução detalhada passo a passo em segundos.

O QUE VOCÊ PODE FAZER:
- Tire uma foto de qualquer problema de matemática ou importe da sua galeria
- Recorte e selecione exatamente o problema que deseja resolver
- Receba soluções instantâneas com explicações completas passo a passo
- Revise todos os problemas resolvidos em um histórico pesquisável
- Compartilhe soluções como belas imagens

TÓPICOS DE MATEMÁTICA:
- Aritmética e Matemática básica
- Álgebra e Álgebra linear
- Geometria e Trigonometria
- Cálculo e Equações diferenciais
- Estatística e Probabilidade
- Problemas de raciocínio

ADAPTA-SE AO SEU NÍVEL:
Escolha seu nível educacional — Fundamental, Médio, ENEM/Vestibular ou Universidade — e a IA adapta suas explicações. Linguagem simples para os mais jovens, demonstrações detalhadas para avançados.

Perfeito para se preparar para o ENEM e vestibulares!

INFORMAÇÕES DE ASSINATURA:
Alguns recursos exigem uma assinatura ativa para acesso completo.
- Opções de assinatura: planos Semanal e Anual disponíveis
- O pagamento é cobrado na sua conta Apple ID na confirmação da compra
- A assinatura é renovada automaticamente, a menos que seja cancelada pelo menos 24 horas antes do final do período atual
- Sua conta será cobrada pela renovação dentro de 24 horas antes do final do período atual
- Você pode gerenciar e cancelar suas assinaturas nas Configurações da sua conta Apple ID após a compra

Política de Privacidade: {PRIVACY_URL}
Termos de Uso: {TERMS_URL}""",
    },

    "pt-PT": {
        "promoText": "Tire uma foto de qualquer problema de matemática e receba soluções passo a passo com IA. Do secundário ao exame — o seu explicador pessoal!",
        "description": f"""Resolva qualquer problema de matemática instantaneamente — basta tirar uma foto!

O Resolvedor de Matemática com IA usa inteligência artificial avançada para digitalizar, reconhecer e resolver problemas de matemática a partir de uma foto. Seja uma questão do livro, uma equação manuscrita ou um TPC — aponte a sua câmara e receba uma solução detalhada passo a passo em segundos.

O QUE PODE FAZER:
- Tire uma foto de qualquer problema de matemática ou importe da sua galeria
- Recorte e selecione exatamente o problema que deseja resolver
- Receba soluções instantâneas com explicações completas passo a passo
- Reveja todos os problemas resolvidos num histórico pesquisável
- Partilhe soluções como belas imagens

TÓPICOS DE MATEMÁTICA:
- Aritmética e Matemática básica
- Álgebra e Álgebra linear
- Geometria e Trigonometria
- Cálculo e Equações diferenciais
- Estatística e Probabilidade
- Problemas de raciocínio

ADAPTA-SE AO SEU NÍVEL:
Escolha o seu nível educacional — Básico, Secundário, Exame Nacional ou Universidade — e a IA adapta as suas explicações. Linguagem simples para os mais novos, demonstrações detalhadas para avançados.

INFORMAÇÕES DE SUBSCRIÇÃO:
Algumas funcionalidades requerem uma subscrição ativa para acesso completo.
- Opções de subscrição: planos Semanal e Anual disponíveis
- O pagamento é cobrado na sua conta Apple ID na confirmação da compra
- A subscrição é renovada automaticamente, salvo cancelamento pelo menos 24 horas antes do final do período atual
- A sua conta será cobrada pela renovação dentro de 24 horas antes do final do período atual
- Pode gerir e cancelar as suas subscrições nas Definições da conta Apple ID após a compra

Política de Privacidade: {PRIVACY_URL}
Termos de Utilização: {TERMS_URL}""",
    },

    "cs": {
        "promoText": "Vyfoťte jakýkoliv matematický příklad a získejte AI řešení krok za krokem. Od základky po maturitu — váš osobní doučovatel!",
        "description": f"""Vyřešte jakýkoliv matematický příklad okamžitě — stačí vyfotit!

AI Řešitel Matematiky využívá pokročilou umělou inteligenci k naskenování, rozpoznání a vyřešení matematických problémů z fotografie. Ať už je to otázka z učebnice, ručně napsaná rovnice nebo domácí úkol — namiřte fotoaparát a během sekund získejte podrobné řešení krok za krokem.

CO MŮŽETE DĚLAT:
- Vyfoťte jakýkoliv matematický příklad nebo importujte z galerie
- Ořežte a vyberte přesně ten problém, který chcete vyřešit
- Získejte okamžitá AI řešení s úplnými vysvětleními krok za krokem
- Prohlížejte si všechny vyřešené příklady v prohledávatelné historii
- Sdílejte řešení jako krásné obrázky

MATEMATICKÉ TÉMATA:
- Aritmetika a základní matematika
- Algebra a lineární algebra
- Geometrie a trigonometrie
- Kalkulus a diferenciální rovnice
- Statistika a pravděpodobnost
- Slovní úlohy

PŘIZPŮSOBÍ SE VAŠÍ ÚROVNI:
Zvolte svou úroveň vzdělání — Základní škola, Střední škola, Maturita nebo Univerzita — a AI přizpůsobí svá vysvětlení. Jednoduchý jazyk pro mladší žáky, podrobné důkazy pro pokročilé.

Ideální pro přípravu na maturitu!

INFORMACE O PŘEDPLATNÉM:
Některé funkce vyžadují aktivní předplatné pro plný přístup.
- Možnosti předplatného: dostupné Týdenní a Roční plány
- Platba je účtována na váš účet Apple ID při potvrzení nákupu
- Předplatné se automaticky obnovuje, pokud není zrušeno alespoň 24 hodin před koncem aktuálního období
- Váš účet bude zatížen obnovením do 24 hodin před koncem aktuálního období
- Své předplatné můžete spravovat a zrušit v nastavení účtu Apple ID po nákupu

Zásady ochrany osobních údajů: {PRIVACY_URL}
Podmínky použití: {TERMS_URL}""",
    },

    "hr": {
        "promoText": "Fotografirajte matematički problem i dobijte AI rješenja korak po korak. Od osnovne do mature — vaš osobni tutor!",
        "description": f"""Riješite bilo koji matematički problem trenutno — samo slikajte!

AI Rješavač Matematike koristi naprednu umjetnu inteligenciju za skeniranje, prepoznavanje i rješavanje matematičkih problema sa fotografije. Bilo da je pitanje iz udžbenika, ručno napisana jednadžba ili domaća zadaća — usmjerite kameru i dobijte detaljno rješenje korak po korak u sekundama.

ŠTO MOŽETE UČINITI:
- Slikajte bilo koji matematički problem ili uvezite iz galerije
- Izrežite i odaberite točno problem koji želite riješiti
- Dobijte trenutna AI rješenja s potpunim objašnjenjima korak po korak
- Pregledajte sve riješene probleme u pretraživoj povijesti
- Podijelite rješenja kao lijepe slike

MATEMATIČKI PREDMETI:
- Aritmetika i osnovna matematika
- Algebra i linearna algebra
- Geometrija i trigonometrija
- Kalkulus i diferencijalne jednadžbe
- Statistika i vjerojatnost
- Tekstualni zadaci

PRILAGOĐAVA SE VAŠOJ RAZINI:
Odaberite svoju razinu obrazovanja — Osnovna škola, Srednja škola, Matura ili Fakultet — i AI prilagođava svoja objašnjenja. Jednostavan jezik za mlade učenike, detaljni dokazi za napredne.

Savršeno za pripremu mature!

INFORMACIJE O PRETPLATI:
Neke značajke zahtijevaju aktivnu pretplatu za potpuni pristup.
- Opcije pretplate: dostupni Tjedni i Godišnji planovi
- Plaćanje se naplaćuje na vaš Apple ID račun pri potvrdi kupnje
- Pretplata se automatski obnavlja osim ako se ne otkaže najmanje 24 sata prije kraja trenutnog razdoblja
- Vaš račun će biti terećen za obnovu unutar 24 sata prije kraja trenutnog razdoblja
- Svoje pretplate možete upravljati i otkazati u postavkama Apple ID računa nakon kupnje

Pravila o privatnosti: {PRIVACY_URL}
Uvjeti korištenja: {TERMS_URL}""",
    },

    "hu": {
        "promoText": "Fotózd le bármely matekfeladatot és kapj AI-alapú megoldást lépésről lépésre. Általánostól az érettségiig — személyes tanárod!",
        "description": f"""Oldjon meg bármilyen matekfeladatot azonnal — csak fényképezze le!

Az AI Matek Megoldó fejlett mesterséges intelligenciát használ, hogy fotóról beolvassa, felismerje és megoldja a matekfeladatokat. Legyen az tankönyvi kérdés, kézzel írt egyenlet vagy házi feladat — irányítsa rá a kamerát és másodpercek alatt részletes lépésről lépésre megoldást kap.

AMIT TEHET:
- Fényképezzen le bármilyen matekfeladatot vagy importáljon a galériából
- Vágja ki és válassza ki pontosan a megoldani kívánt feladatot
- Kapjon azonnali AI-alapú megoldásokat teljes lépésről lépésre magyarázattal
- Tekintse át az összes megoldott feladatát kereshető előzményekben
- Ossza meg a megoldásokat szép képként

MATEMATIKAI TÉMÁK:
- Aritmetika és alapszintű matematika
- Algebra és lineáris algebra
- Geometria és trigonometria
- Analízis és differenciálegyenletek
- Statisztika és valószínűségszámítás
- Szöveges feladatok

ALKALMAZKODIK AZ ÖN SZINTJÉHEZ:
Válassza ki az iskolai szintet — Általános iskola, Középiskola, Érettségi vagy Egyetem — és az AI igazítja a magyarázatait. Egyszerű nyelv a fiatalabb diákoknak, részletes bizonyítások a haladóknak.

Tökéletes érettségire felkészüléshez!

ELŐFIZETÉS INFORMÁCIÓ:
Egyes funkciók aktív előfizetést igényelnek a teljes hozzáféréshez.
- Előfizetési opciók: Heti és Éves csomagok érhetők el
- A fizetés az Apple ID fiókjából kerül levonásra a vásárlás megerősítésekor
- Az előfizetés automatikusan megújul, hacsak legalább 24 órával az aktuális időszak vége előtt nem mondja le
- Fiókjából 24 órán belül kerül levonásra a megújítás díja az aktuális időszak vége előtt
- Előfizetései a vásárlás után az Apple ID fiókbeállításaiban kezelhetők és lemondhatók

Adatvédelmi irányelvek: {PRIVACY_URL}
Felhasználási feltételek: {TERMS_URL}""",
    },

    "ro": {
        "promoText": "Fotografiază orice problemă de matematică și obții soluții pas cu pas cu AI. De la generală până la BAC — tutorele tău personal!",
        "description": f"""Rezolvați orice problemă de matematică instantaneu — faceți doar o poză!

AI Rezolvator Mate folosește inteligența artificială avansată pentru a scana, recunoaște și rezolva probleme de matematică dintr-o fotografie. Fie că este o întrebare din manual, o ecuație scrisă de mână sau o temă — îndreptați camera și obțineți o soluție detaliată pas cu pas în câteva secunde.

CE PUTEȚI FACE:
- Fotografiați orice problemă de matematică sau importați din galerie
- Decupați și selectați exact problema pe care doriți să o rezolvați
- Obțineți soluții instantanee AI cu explicații complete pas cu pas
- Revizuiți toate problemele rezolvate într-un istoric cu căutare
- Distribuiți soluțiile ca imagini frumoase

SUBIECTE DE MATEMATICĂ:
- Aritmetică și Matematică de bază
- Algebră și Algebră liniară
- Geometrie și Trigonometrie
- Calcul diferențial și Ecuații diferențiale
- Statistică și Probabilitate
- Probleme de raționament

SE ADAPTEAZĂ LA NIVELUL TĂU:
Alege nivelul de educație — Școală Primară, Gimnaziu, Liceu/BAC sau Universitate — și AI își adaptează explicațiile. Limbaj simplu pentru elevii mai mici, demonstrații detaliate pentru avansați.

Perfect pentru pregătirea BAC-ului!

INFORMAȚII DESPRE ABONAMENT:
Unele funcții necesită un abonament activ pentru acces complet.
- Opțiuni de abonament: planuri Săptămânal și Anual disponibile
- Plata se percepe din contul Apple ID la confirmarea achiziției
- Abonamentul se reînnoiește automat dacă nu este anulat cu cel puțin 24 de ore înainte de sfârșitul perioadei curente
- Contul dumneavoastră va fi taxat pentru reînnoire în termen de 24 de ore înainte de sfârșitul perioadei curente
- Puteți gestiona și anula abonamentele în Setările contului Apple ID după achiziție

Politica de Confidențialitate: {PRIVACY_URL}
Termeni de Utilizare: {TERMS_URL}""",
    },

    "pl": {
        "promoText": "Zrób zdjęcie dowolnego zadania z matematyki i uzyskaj rozwiązania AI krok po kroku. Od podstawówki do matury — Twój osobisty korepetytor!",
        "description": f"""Rozwiąż dowolne zadanie z matematyki natychmiast — po prostu zrób zdjęcie!

AI Rozwiąż Matematykę wykorzystuje zaawansowaną sztuczną inteligencję do skanowania, rozpoznawania i rozwiązywania zadań matematycznych ze zdjęcia. Czy to pytanie z podręcznika, ręcznie napisane równanie czy karta pracy domowej — skieruj aparat i w kilka sekund otrzymaj szczegółowe rozwiązanie krok po kroku.

CO MOŻESZ ZROBIĆ:
- Zrób zdjęcie dowolnego zadania z matematyki lub zaimportuj z galerii
- Przytnij i wybierz dokładnie zadanie, które chcesz rozwiązać
- Uzyskaj natychmiastowe rozwiązania AI z pełnymi wyjaśnieniami krok po kroku
- Przeglądaj wszystkie rozwiązane zadania w przeszukiwalnej historii
- Udostępniaj rozwiązania jako piękne obrazy

TEMATY MATEMATYCZNE:
- Arytmetyka i matematyka podstawowa
- Algebra i algebra liniowa
- Geometria i trygonometria
- Rachunek różniczkowy i równania różniczkowe
- Statystyka i prawdopodobieństwo
- Zadania tekstowe

DOSTOSOWUJE SIĘ DO TWOJEGO POZIOMU:
Wybierz swój poziom edukacji — Szkoła Podstawowa, Liceum, Matura lub Uniwersytet — a AI dostosuje swoje wyjaśnienia. Prosty język dla młodszych uczniów, szczegółowe dowody dla zaawansowanych.

Idealny do przygotowania do matury!

INFORMACJE O SUBSKRYPCJI:
Niektóre funkcje wymagają aktywnej subskrypcji dla pełnego dostępu.
- Opcje subskrypcji: dostępne plany Tygodniowe i Roczne
- Płatność jest pobierana z konta Apple ID przy potwierdzeniu zakupu
- Subskrypcja automatycznie się odnawia, chyba że zostanie anulowana co najmniej 24 godziny przed końcem bieżącego okresu
- Z konta zostanie pobrana opłata za odnowienie w ciągu 24 godzin przed końcem bieżącego okresu
- Subskrypcjami można zarządzać i je anulować w Ustawieniach konta Apple ID po zakupie

Polityka Prywatności: {PRIVACY_URL}
Warunki Użytkowania: {TERMS_URL}""",
    },

    "sk": {
        "promoText": "Odfoťte akýkoľvek matematický príklad a získajte AI riešenia krok za krokom. Od základky po maturitu — váš osobný doučovateľ!",
        "description": f"""Vyriešte akýkoľvek matematický príklad okamžite — stačí odfotiť!

AI Riešiteľ Matematiky využíva pokročilú umelú inteligenciu na skenovanie, rozpoznávanie a riešenie matematických problémov z fotografie. Či už je to otázka z učebnice, ručne napísaná rovnica alebo domáca úloha — namierte fotoaparát a za sekundy získajte podrobné riešenie krok za krokom.

ČO MÔŽETE ROBIŤ:
- Odfoťte akýkoľvek matematický príklad alebo importujte z galérie
- Orežte a vyberte presne ten problém, ktorý chcete vyriešiť
- Získajte okamžité AI riešenia s úplnými vysvetleniami krok za krokom
- Prezrite si všetky vyriešené príklady v prehľadávateľnej histórii
- Zdieľajte riešenia ako pekné obrázky

MATEMATICKÉ TÉMY:
- Aritmetika a základná matematika
- Algebra a lineárna algebra
- Geometria a trigonometria
- Kalkulus a diferenciálne rovnice
- Štatistika a pravdepodobnosť
- Slovné úlohy

PRISPÔSOBÍ SA VAŠEJ ÚROVNI:
Zvoľte svoju úroveň vzdelania — Základná škola, Stredná škola, Maturita alebo Univerzita — a AI prispôsobí svoje vysvetlenia. Jednoduchý jazyk pre mladších žiakov, podrobné dôkazy pre pokročilých.

Ideálny na prípravu na maturitu!

INFORMÁCIE O PREDPLATNOM:
Niektoré funkcie vyžadujú aktívne predplatné pre plný prístup.
- Možnosti predplatného: dostupné Týždenné a Ročné plány
- Platba je účtovaná na váš účet Apple ID pri potvrdení nákupu
- Predplatné sa automaticky obnovuje, pokiaľ nie je zrušené aspoň 24 hodín pred koncom aktuálneho obdobia
- Váš účet bude zaťažený obnovením do 24 hodín pred koncom aktuálneho obdobia
- Svoje predplatné môžete spravovať a zrušiť v nastaveniach účtu Apple ID po nákupe

Zásady ochrany osobných údajov: {PRIVACY_URL}
Podmienky používania: {TERMS_URL}""",
    },

    "sv": {
        "promoText": "Ta en bild på vilket matteproblem som helst och få AI-drivna lösningar steg för steg. Från högstadiet till NP — din personliga mattelektor!",
        "description": f"""Lös vilket matteproblem som helst direkt — ta bara ett foto!

AI Matte Lösare använder avancerad artificiell intelligens för att skanna, känna igen och lösa matteproblem från ett foto. Oavsett om det är en fråga från boken, en handskriven ekvation eller läxor — rikta kameran och få en detaljerad steg-för-steg-lösning på sekunder.

VAD DU KAN GÖRA:
- Ta ett foto av vilket matteproblem som helst eller importera från galleriet
- Beskär och välj exakt det problem du vill lösa
- Få omedelbara AI-drivna lösningar med fullständiga steg-för-steg-förklaringar
- Granska alla lösta problem i en sökbar historik
- Dela lösningar som snygga bilder

MATTEÄMNEN:
- Aritmetik och grundläggande matematik
- Algebra och linjär algebra
- Geometri och trigonometri
- Kalkyl och differentialekvationer
- Statistik och sannolikhet
- Textuppgifter

ANPASSAR SIG TILL DIN NIVÅ:
Välj din utbildningsnivå — Grundskola, Högstadiet, Gymnasiet/NP eller Universitet — och AI:n anpassar sina förklaringar. Enkelt språk för yngre elever, detaljerade bevis för avancerade.

PRENUMERATIONSINFORMATION:
Vissa funktioner kräver en aktiv prenumeration för full åtkomst.
- Prenumerationsalternativ: Vecko- och Årsplaner tillgängliga
- Betalning debiteras från ditt Apple ID-konto vid köpbekräftelse
- Prenumerationen förnyas automatiskt om den inte avbryts minst 24 timmar före slutet av innevarande period
- Ditt konto debiteras för förnyelse inom 24 timmar före slutet av innevarande period
- Du kan hantera och avbryta prenumerationer i Apple ID-kontoinställningarna efter köp

Integritetspolicy: {PRIVACY_URL}
Användarvillkor: {TERMS_URL}""",
    },

    "no": {
        "promoText": "Ta bilde av et hvilket som helst matteproblem og få AI-drevne løsninger steg for steg. Fra ungdomsskole til VGS — din personlige tutor!",
        "description": f"""Løs ethvert matteproblem med en gang — bare ta et bilde!

AI Matte Løser bruker avansert kunstig intelligens for å skanne, gjenkjenne og løse matteproblemer fra et bilde. Enten det er et spørsmål fra boken, en håndskrevet ligning eller lekser — pek kameraet og få en detaljert steg-for-steg-løsning på sekunder.

HVA DU KAN GJØRE:
- Ta et bilde av ethvert matteproblem eller importer fra galleriet
- Beskjær og velg nøyaktig det problemet du vil løse
- Få øyeblikkelige AI-drevne løsninger med fulle steg-for-steg-forklaringer
- Gå gjennom alle løste problemer i en søkbar historikk
- Del løsninger som vakre bilder

MATTEEMNER:
- Aritmetikk og grunnleggende matematikk
- Algebra og lineær algebra
- Geometri og trigonometri
- Kalkulus og differensialligninger
- Statistikk og sannsynlighet
- Tekstoppgaver

TILPASSER SEG DITT NIVÅ:
Velg utdanningsnivå — Barneskole, Ungdomsskole, VGS eller Universitet — og AI-en tilpasser sine forklaringer. Enkelt språk for yngre elever, detaljerte bevis for viderekomne.

ABONNEMENTSINFORMASJON:
Noen funksjoner krever et aktivt abonnement for full tilgang.
- Abonnementsalternativer: Ukentlige og Årlige planer tilgjengelig
- Betaling belastes Apple ID-kontoen din ved bekreftelse av kjøp
- Abonnementet fornyes automatisk med mindre det sies opp minst 24 timer før slutten av gjeldende periode
- Kontoen din vil bli belastet for fornyelse innen 24 timer før slutten av gjeldende periode
- Du kan administrere og si opp abonnementene dine i Apple ID-kontoinnstillingene etter kjøp

Personvernregler: {PRIVACY_URL}
Bruksvilkår: {TERMS_URL}""",
    },

    "da": {
        "promoText": "Tag et foto af ethvert matematikproblem og få AI-drevne løsninger trin for trin. Fra folkeskole til gymnasium — din personlige tutor!",
        "description": f"""Løs ethvert matematikproblem med det samme — tag bare et foto!

AI Matematik Løser bruger avanceret kunstig intelligens til at scanne, genkende og løse matematikproblemer fra et foto. Uanset om det er et spørgsmål fra bogen, en håndskrevet ligning eller lektier — peg dit kamera og få en detaljeret trin-for-trin-løsning på sekunder.

HVAD DU KAN GØRE:
- Tag et foto af ethvert matematikproblem eller importér fra dit galleri
- Beskær og vælg præcis det problem, du vil løse
- Få øjeblikkelige AI-drevne løsninger med fulde trin-for-trin-forklaringer
- Gennemgå alle dine løste problemer i en søgbar historik
- Del løsninger som flotte billeder

MATEMATIKEMNER:
- Aritmetik og grundlæggende matematik
- Algebra og lineær algebra
- Geometri og trigonometri
- Calculus og differentialligninger
- Statistik og sandsynlighed
- Tekstopgaver

TILPASSER SIG DIT NIVEAU:
Vælg dit uddannelsesniveau — Folkeskole, Gymnasium, HF/STX eller Universitet — og AI'en tilpasser sine forklaringer. Enkelt sprog til yngre elever, detaljerede beviser til avancerede.

ABONNEMENTSINFORMATION:
Nogle funktioner kræver et aktivt abonnement for fuld adgang.
- Abonnementsmuligheder: Ugentlige og Årlige planer tilgængelige
- Betaling opkræves på din Apple ID-konto ved bekræftelse af køb
- Abonnementet fornyes automatisk, medmindre det opsiges mindst 24 timer før udgangen af den aktuelle periode
- Din konto vil blive opkrævet for fornyelse inden for 24 timer før udgangen af den aktuelle periode
- Du kan administrere og opsige dine abonnementer i Apple ID-kontoindstillingerne efter køb

Privatlivspolitik: {PRIVACY_URL}
Brugsvilkår: {TERMS_URL}""",
    },

    "fi": {
        "promoText": "Ota kuva mistä tahansa matikkaongelmasta ja saat AI-ratkaisun vaihe vaiheelta. Peruskoulusta ylioppilaaseen — oma matikkaopettajasi!",
        "description": f"""Ratkaise mikä tahansa matikkaongelma heti — ota vain kuva!

AI Matikan Ratkaisija käyttää edistynyttä tekoälyä skannatakseen, tunnistaakseen ja ratkaistakseen matematiikan ongelmia kuvasta. Olipa kyseessä oppikirjan tehtävä, käsin kirjoitettu yhtälö tai läksy — osoita kameraa ja saat yksityiskohtaisen vaihe vaiheelta -ratkaisun sekunneissa.

MITÄ VOIT TEHDÄ:
- Ota kuva mistä tahansa matikkaongelmasta tai tuo galleriasta
- Rajaa ja valitse tarkasti ongelma, jonka haluat ratkaista
- Saa välittömiä tekoälypohjaisia ratkaisuja täydellisillä vaihe vaiheelta -selityksillä
- Tarkastele kaikkia ratkaistuja ongelmia hakukelpoisessa historiassa
- Jaa ratkaisut kauniina kuvina

MATEMATIIKAN AIHEET:
- Aritmetiikka ja perusmatematiikka
- Algebra ja lineaarialgebra
- Geometria ja trigonometria
- Analyysi ja differentiaaliyhtälöt
- Tilastotiede ja todennäköisyys
- Sanallisia tehtäviä

MUKAUTUU TASOOSI:
Valitse koulutustasosi — Peruskoulu, Lukio, Ylioppilaskoe tai Yliopisto — ja tekoäly mukauttaa selityksensä. Yksinkertainen kieli nuoremmille oppilaille, yksityiskohtaiset todistukset edistyneille.

Täydellinen ylioppilaskirjoituksiin valmistautumiseen!

TILAUSTIEDOT:
Jotkin ominaisuudet vaativat aktiivisen tilauksen täydelliseen käyttöön.
- Tilausvaihtoehdot: Viikko- ja Vuositilaukset saatavilla
- Maksu veloitetaan Apple ID -tililtäsi oston vahvistamisen yhteydessä
- Tilaus uusiutuu automaattisesti, ellei sitä peruuteta vähintään 24 tuntia ennen nykyisen jakson päättymistä
- Tililtäsi veloitetaan uusiminen 24 tunnin kuluessa ennen nykyisen jakson päättymistä
- Voit hallita ja peruuttaa tilauksesi Apple ID -tilin asetuksissa oston jälkeen

Tietosuojakäytäntö: {PRIVACY_URL}
Käyttöehdot: {TERMS_URL}""",
    },

    "vi": {
        "promoText": "Chụp ảnh bất kỳ bài toán nào và nhận lời giải chi tiết từng bước từ AI. Từ cấp 2 đến THPT — gia sư riêng của bạn!",
        "description": f"""Giải bất kỳ bài toán nào ngay lập tức — chỉ cần chụp ảnh!

AI Giải Toán sử dụng trí tuệ nhân tạo tiên tiến để quét, nhận diện và giải các bài toán từ ảnh chụp. Dù là câu hỏi trong sách giáo khoa, phương trình viết tay hay bài tập về nhà — hướng camera và nhận lời giải chi tiết từng bước trong vài giây.

BẠN CÓ THỂ LÀM GÌ:
- Chụp ảnh bất kỳ bài toán nào hoặc nhập từ thư viện ảnh
- Cắt và chọn chính xác bài toán bạn muốn giải
- Nhận lời giải AI ngay lập tức với giải thích đầy đủ từng bước
- Xem lại tất cả các bài đã giải trong lịch sử có thể tìm kiếm
- Chia sẻ lời giải dưới dạng hình ảnh đẹp

CÁC CHỦ ĐỀ TOÁN HỌC:
- Số học và Toán cơ bản
- Đại số và Đại số tuyến tính
- Hình học và Lượng giác
- Giải tích và Phương trình vi phân
- Thống kê và Xác suất
- Bài toán có lời văn

THÍCH ỨNG VỚI TRÌNH ĐỘ CỦA BẠN:
Chọn cấp học — Tiểu học, THCS, THPT hoặc Đại học — và AI điều chỉnh giải thích. Ngôn ngữ đơn giản cho học sinh nhỏ, chứng minh chi tiết cho người học nâng cao.

Hoàn hảo để chuẩn bị thi THPT Quốc gia!

THÔNG TIN ĐĂNG KÝ:
Một số tính năng yêu cầu đăng ký để truy cập đầy đủ.
- Tùy chọn đăng ký: gói Hàng tuần và Hàng năm
- Thanh toán được trừ từ tài khoản Apple ID của bạn khi xác nhận mua
- Đăng ký tự động gia hạn trừ khi bị hủy ít nhất 24 giờ trước khi kết thúc kỳ hiện tại
- Tài khoản của bạn sẽ bị trừ phí gia hạn trong vòng 24 giờ trước khi kết thúc kỳ hiện tại
- Bạn có thể quản lý và hủy đăng ký trong Cài đặt Tài khoản Apple ID sau khi mua

Chính sách Bảo mật: {PRIVACY_URL}
Điều khoản Sử dụng: {TERMS_URL}""",
    },

    "sl-SI": {
        "promoText": "Fotografirajte katerikoli matematični problem in dobite AI rešitve po korakih. Od osnovne šole do mature — vaš osebni učitelj!",
        "description": f"""Rešite katerikoli matematični problem takoj — samo fotografirajte!

AI Reševanje Matematike uporablja napredno umetno inteligenco za skeniranje, prepoznavanje in reševanje matematičnih problemov s fotografije. Bodisi je vprašanje iz učbenika, ročno napisana enačba ali domača naloga — usmerite kamero in v sekundah dobite podrobno rešitev po korakih.

KAJ LAHKO STORITE:
- Fotografirajte katerikoli matematični problem ali uvozite iz galerije
- Obrežite in izberite natančno problem, ki ga želite rešiti
- Dobite takojšnje AI rešitve s popolnimi razlagami po korakih
- Preglejte vse rešene probleme v iskalnem zgodovini
- Delite rešitve kot lepe slike

MATEMATIČNE TEME:
- Aritmetika in osnovna matematika
- Algebra in linearna algebra
- Geometrija in trigonometrija
- Analiza in diferencialne enačbe
- Statistika in verjetnost
- Besedilne naloge

PRILAGODI SE VAŠI RAVNI:
Izberite svojo raven izobrazbe — Osnovna šola, Srednja šola, Matura ali Univerza — in AI prilagodi svoje razlage. Preprost jezik za mlajše učence, podrobni dokazi za napredne.

Idealno za pripravo na maturo!

INFORMACIJE O NAROČNINI:
Nekatere funkcije zahtevajo aktivno naročnino za poln dostop.
- Možnosti naročnine: na voljo Tedenska in Letna naročnina
- Plačilo se zaračuna na vaš račun Apple ID ob potrditvi nakupa
- Naročnina se samodejno obnovi, razen če je preklicana vsaj 24 ur pred koncem tekočega obdobja
- Vaš račun bo bremenjen za obnovo v 24 urah pred koncem tekočega obdobja
- Svoje naročnine lahko upravljate in prekličete v nastavitvah računa Apple ID po nakupu

Politika zasebnosti: {PRIVACY_URL}
Pogoji uporabe: {TERMS_URL}""",
    },

    "hi": {
        "promoText": "किसी भी गणित की समस्या की फोटो लें और AI से तुरंत स्टेप-बाय-स्टेप हल पाएं। स्कूल से JEE तक — आपका पर्सनल मैथ ट्यूटर!",
        "description": f"""किसी भी गणित की समस्या को तुरंत हल करें — बस एक फोटो लें!

AI Math Solver उन्नत आर्टिफिशियल इंटेलिजेंस का उपयोग करके फोटो से गणित की समस्याओं को स्कैन, पहचान और हल करता है। चाहे पाठ्यपुस्तक का सवाल हो, हाथ से लिखी समीकरण हो या होमवर्क — अपना कैमरा दिखाएं और सेकंडों में विस्तृत स्टेप-बाय-स्टेप हल पाएं।

आप क्या कर सकते हैं:
- किसी भी गणित की समस्या की फोटो लें या गैलरी से इंपोर्ट करें
- जो समस्या हल करनी है उसे क्रॉप करके चुनें
- पूरे स्टेप-बाय-स्टेप स्पष्टीकरण के साथ AI हल पाएं
- खोजने योग्य इतिहास में सभी हल की गई समस्याएं देखें
- सुंदर छवियों के रूप में हल शेयर करें

गणित के विषय:
- अंकगणित और मूल गणित
- बीजगणित और रैखिक बीजगणित
- ज्यामिति और त्रिकोणमिति
- कैलकुलस और अवकल समीकरण
- सांख्यिकी और प्रायिकता
- शब्द समस्याएं

आपके स्तर के अनुसार:
अपना शिक्षा स्तर चुनें — प्राथमिक, माध्यमिक, उच्च माध्यमिक या विश्वविद्यालय — और AI अपनी व्याख्या समायोजित करता है। छोटे छात्रों के लिए सरल भाषा, उन्नत शिक्षार्थियों के लिए विस्तृत प्रमाण।

JEE, NEET, CBSE और ICSE बोर्ड परीक्षाओं की तैयारी के लिए बेहतरीन!

सब्सक्रिप्शन जानकारी:
कुछ सुविधाओं के लिए पूर्ण एक्सेस के लिए सक्रिय सब्सक्रिप्शन आवश्यक है।
- सब्सक्रिप्शन विकल्प: साप्ताहिक और वार्षिक प्लान उपलब्ध हैं
- खरीद की पुष्टि पर आपके Apple ID खाते से भुगतान लिया जाता है
- वर्तमान अवधि समाप्त होने से कम से कम 24 घंटे पहले रद्द न किया जाए तो सब्सक्रिप्शन स्वचालित रूप से नवीनीकृत होती है
- खरीद के बाद Apple ID खाता सेटिंग्स में अपनी सब्सक्रिप्शन प्रबंधित और रद्द कर सकते हैं

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}""",
    },

    "nl-NL": {
        "promoText": "Maak een foto van elk wiskundeprobleem en krijg direct AI-gestuurde stap-voor-stap oplossingen. Van HAVO tot VWO — jouw persoonlijke bijles!",
        "description": f"""Los elk wiskundeprobleem direct op — maak gewoon een foto!

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
    },

    "it": {
        "promoText": "Scatta una foto di qualsiasi problema di matematica e ottieni soluzioni passo dopo passo con l'IA. Dalla scuola alla maturità — il tuo tutor!",
        "description": f"""Risolvi qualsiasi problema di matematica istantaneamente — basta scattare una foto!

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
- Statistica e Probabilità
- Problemi di ragionamento

SI ADATTA AL TUO LIVELLO:
Scegli il tuo livello — Scuola Media, Liceo, Maturità o Università — e l'IA adatta le sue spiegazioni. Linguaggio semplice per i più giovani, dimostrazioni dettagliate per gli avanzati.

Perfetto per prepararsi alla Maturità!

INFORMAZIONI SULL'ABBONAMENTO:
Alcune funzionalità richiedono un abbonamento attivo per l'accesso completo.
- Opzioni di abbonamento: piani Settimanale e Annuale disponibili
- Il pagamento viene addebitato sul tuo account Apple ID alla conferma dell'acquisto
- L'abbonamento si rinnova automaticamente a meno che non venga cancellato almeno 24 ore prima della fine del periodo corrente
- Il rinnovo verrà addebitato entro 24 ore prima della fine del periodo corrente
- Puoi gestire e cancellare i tuoi abbonamenti nelle Impostazioni del tuo Apple ID dopo l'acquisto

Informativa sulla Privacy: {PRIVACY_URL}
Termini di Utilizzo: {TERMS_URL}""",
    },
}


def main():
    print("=" * 60)
    print("MathPro - Fix Descriptions with Proper Diacritics")
    print(f"  Languages to fix: {len(FIXES)}")
    print("=" * 60)

    # Get IDs
    print("\n[1] Finding app...")
    data = requests.get(f"{BASE}/apps", headers=hdr(), params={"filter[bundleId]": BUNDLE_ID}).json()
    app_id = data["data"][0]["id"]

    print("[2] Getting Version...")
    data = requests.get(f"{BASE}/apps/{app_id}/appStoreVersions", headers=hdr(),
                        params={"filter[platform]": "IOS", "limit": 1}).json()
    version_id = data["data"][0]["id"]

    # Get version localizations
    print("[3] Getting version localizations...")
    ver_locs = {}
    url = f"{BASE}/appStoreVersions/{version_id}/appStoreVersionLocalizations"
    p = {"limit": 200}
    while url:
        r = requests.get(url, headers=hdr(), params=p)
        d = r.json()
        for l in d.get("data", []):
            ver_locs[l["attributes"]["locale"]] = l["id"]
        url = d.get("links", {}).get("next")
        p = {}
    print(f"  Found {len(ver_locs)} localizations")

    # Fix each locale
    print("\n[4] Fixing descriptions...")
    print("-" * 60)
    ok = 0
    fail = 0

    for locale, content in sorted(FIXES.items()):
        if locale not in ver_locs:
            print(f"  [{locale}] ⚠ Not found, skipping")
            fail += 1
            continue

        loc_id = ver_locs[locale]
        attrs = {}
        if "description" in content:
            attrs["description"] = content["description"]
        if "promoText" in content:
            attrs["promotionalText"] = content["promoText"]

        resp = requests.patch(f"{BASE}/appStoreVersionLocalizations/{loc_id}", headers=hdr(), json={
            "data": {"type": "appStoreVersionLocalizations", "id": loc_id, "attributes": attrs}
        })

        if resp.status_code == 200:
            print(f"  [{locale}] ✓ Fixed")
            ok += 1
        else:
            errs = resp.json().get("errors", [])
            err = errs[0]["detail"] if errs else resp.text[:200]
            print(f"  [{locale}] ✗ {err}")
            fail += 1

        time.sleep(0.3)

    print("\n" + "=" * 60)
    print(f"DONE! ✓ {ok} fixed, ✗ {fail} failed (out of {len(FIXES)})")
    print("=" * 60)


if __name__ == "__main__":
    main()

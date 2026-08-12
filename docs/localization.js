const translations = {
  en: {
    navLabel: "Main navigation", support: "Support", privacy: "Privacy", appStore: "App Store",
    homeDescription: "Support and privacy information for Yawn Sleep on iPhone and Apple Watch.",
    homeTitle: "Yawn Sleep — Sleep at a glance", heroTitle: "Sleep at a glance.",
    heroLead: "Yawn Sleep turns last night’s sleep into one friendly glance. A soft 3D bed and the Little Sleep Companion react to a locally calculated Yawn Score.",
    download: "Download on the App Store", getSupport: "Get support", heroArt: "Lil’ Guy enjoys a cheerful pillow fight, alternating between another Lil’ Guy and a pink Lil’ Girl with pigtails",
    meetMorning: "Meet your morning", scoreSoul: "A score with a little soul.",
    scoreIntro: "One number, three simple signals, and a tiny companion who already knows how the night went.",
    roughNight: "Rough night?", readyDay: "Ready for the day.", makeYours: "Make it yours.",
    lowAlt: "Yawn Sleep showing a score of 38 with a tired Lil’ Guy beside an unmade bed",
    highAlt: "Yawn Sleep showing a score of 88 with a cheerful Lil’ Guy jumping on the bed",
    girlAlt: "Yawn Sleep showing a score of 88 with Lil’ Girl enjoying a pillow fight",
    privateTitle: "Private by design", privateText: "Your Health data stays on your devices. Yawn Sleep has no account, analytics, ads, or tracking.", readPolicy: "Read the policy →",
    helpTitle: "Need help?", helpText: "Find setup guidance for Health permissions, iPhone, and Apple Watch.", openSupport: "Open support →",
    appStoreTitle: "Ready for a better morning?", appStoreText: "Download Yawn Sleep for free on iPhone and Apple Watch.", viewAppStore: "View on the App Store →",
    homeFooter: "© 2026 Lutz R. Frank · Yawn Sleep is an independent app and is not affiliated with Apple.",
    supportDescription: "Support for the Yawn Sleep iPhone and Apple Watch app.", supportTitle: "Yawn Sleep Support",
    privacyDescription: "Privacy policy for the Yawn Sleep iPhone and Apple Watch app.", privacyTitle: "Yawn Sleep Privacy Policy"
  },
  de: {
    navLabel: "Hauptnavigation", support: "Support", privacy: "Datenschutz", appStore: "App Store",
    homeDescription: "Support- und Datenschutzinformationen für Yawn Sleep auf iPhone und Apple Watch.",
    homeTitle: "Yawn Sleep — Schlaf auf einen Blick", heroTitle: "Schlaf auf einen Blick.",
    heroLead: "Yawn Sleep macht aus der letzten Nacht einen freundlichen Blickfang. Ein weiches 3D-Bett und der kleine Schlafbegleiter reagieren auf deinen lokal berechneten Yawn Score.",
    download: "Im App Store laden", getSupport: "Support öffnen", heroArt: "Lil’ Guy hat eine fröhliche Kissenschlacht – abwechselnd mit einem weiteren Lil’ Guy und einem pinken Lil’ Girl mit Zöpfen",
    meetMorning: "Guten Morgen", scoreSoul: "Ein Score mit etwas Seele.",
    scoreIntro: "Eine Zahl, drei einfache Signale und ein kleiner Begleiter, der schon weiß, wie deine Nacht war.",
    roughNight: "Schlechte Nacht?", readyDay: "Bereit für den Tag.", makeYours: "Mach es zu deinem.",
    lowAlt: "Yawn Sleep zeigt einen Score von 38 mit einem müden Lil’ Guy neben einem ungemachten Bett",
    highAlt: "Yawn Sleep zeigt einen Score von 88 mit einem fröhlichen Lil’ Guy, der auf dem Bett springt",
    girlAlt: "Yawn Sleep zeigt einen Score von 88 mit Lil’ Girl bei einer Kissenschlacht",
    privateTitle: "Privat von Grund auf", privateText: "Deine Gesundheitsdaten bleiben auf deinen Geräten. Yawn Sleep hat kein Konto, keine Analysen, keine Werbung und kein Tracking.", readPolicy: "Datenschutz lesen →",
    helpTitle: "Brauchst du Hilfe?", helpText: "Hier findest du Hilfe zu Health-Berechtigungen, iPhone und Apple Watch.", openSupport: "Support öffnen →",
    appStoreTitle: "Bereit für einen besseren Morgen?", appStoreText: "Lade Yawn Sleep kostenlos für iPhone und Apple Watch.", viewAppStore: "Im App Store ansehen →",
    homeFooter: "© 2026 Lutz R. Frank · Yawn Sleep ist eine unabhängige App und nicht mit Apple verbunden.",
    supportDescription: "Support für die Yawn Sleep App auf iPhone und Apple Watch.", supportTitle: "Yawn Sleep Support",
    privacyDescription: "Datenschutzerklärung für die Yawn Sleep App auf iPhone und Apple Watch.", privacyTitle: "Yawn Sleep Datenschutzerklärung"
  }
};

function setLanguage(language) {
  const lang = language === "de" ? "de" : "en";
  const copy = translations[lang];
  document.documentElement.lang = lang;
  document.querySelectorAll("[data-i18n]").forEach((element) => {
    element.textContent = copy[element.dataset.i18n];
  });
  document.querySelectorAll("[data-i18n-aria]").forEach((element) => {
    element.setAttribute("aria-label", copy[element.dataset.i18nAria]);
  });
  document.querySelectorAll("[data-i18n-alt]").forEach((element) => {
    element.setAttribute("alt", copy[element.dataset.i18nAlt]);
  });
  document.querySelectorAll("[data-language]").forEach((element) => {
    element.hidden = element.dataset.language !== lang;
  });
  document.querySelectorAll("[data-language-button]").forEach((button) => {
    const active = button.dataset.languageButton === lang;
    button.classList.toggle("active", active);
    button.setAttribute("aria-pressed", String(active));
  });
  const page = document.body.dataset.page;
  if (page) {
    document.title = copy[`${page}Title`];
    document.querySelector('meta[name="description"]').setAttribute("content", copy[`${page}Description`]);
  }
}

document.addEventListener("DOMContentLoaded", () => {
  const systemLanguage = (navigator.languages?.[0] || navigator.language || "en").toLowerCase();
  setLanguage(systemLanguage.startsWith("de") ? "de" : "en");
  document.querySelectorAll("[data-language-button]").forEach((button) => {
    button.addEventListener("click", () => setLanguage(button.dataset.languageButton));
  });
});

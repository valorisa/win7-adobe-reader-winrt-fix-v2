# 🗺️ Roadmap — Win7 Adobe Reader WinRT Fix

> **Dernière mise à jour :** 1er Mars 2026  
> **Version actuelle :** 2.0.1 (En modération Chocolatey)  
> **Prochaine version :** 2.0.2 (Q2 2026)

---

## 📊 État d'avancement

| Version | Statut | Date | Notes |
|---------|--------|------|-------|
| **V2.0.0** | ❌ Rejetée | Fév 2026 | Nuspec incomplet (`tools/` manquant) |
| **V2.0.1** | ⏳ En modération | Mar 2026 | Correction complète + mode offline |
| **V2.0.2** | 📋 Planifiée | Q2 2026 | UUP silencieux + multi-langues |
| **V2.1.0** | 💡 En réflexion | Q3-Q4 2026 | Notifications + tests unitaires |

---

## 🎯 V2.0.2 (Q2 2026) — Améliorations prioritaires

### **🔴 Haute priorité**

| ID | Fonctionnalité | Description | Effort | Impact |
|----|---------------|-------------|--------|--------|
| **F-001** | UUP 100% silencieux | API uupdump + aria2 sans interaction | 🟡 Moyen | ⭐⭐⭐⭐⭐ |
| **F-002** | Support multi-langues | Packs fr-fr, en-us, de-de, es-es, it-it | 🟢 Facile | ⭐⭐⭐⭐ |
| **F-003** | Mode portable | Exécution sans Chocolatey ni installation | 🟡 Moyen | ⭐⭐⭐ |

### **🟠 Moyenne priorité**

| ID | Fonctionnalité | Description | Effort | Impact |
|----|---------------|-------------|--------|--------|
| **F-004** | Logs détaillés | Fichier log dans `%TEMP%\win7-adobe-fix\` | 🟢 Facile | ⭐⭐ |
| **F-005** | Backup automatique | Backup DLL originale avant remplacement | 🟢 Facile | ⭐⭐⭐⭐ |
| **F-006** | Détection auto Adobe | Trouver l'installation Adobe automatiquement | 🟡 Moyen | ⭐⭐ |

---

## 🚀 V2.1.0 (Q3-Q4 2026) — Fonctionnalités avancées

### **💡 En réflexion**

| ID | Fonctionnalité | Description | Effort | Impact |
|----|---------------|-------------|--------|--------|
| **F-010** | Notification nouvelle DLL | Vérif périodique versions Microsoft | 🔴 Complexe | ⭐⭐⭐ |
| **F-011** | Tests unitaires PowerShell | Pester/PSScriptAnalyzer + CI | 🟢 Facile | ⭐⭐⭐ |
| **F-012** | Support Windows 8.1 | Extension compatibilité | 🟡 Moyen | ⭐⭐ |
| **F-013** | GUI optionnelle | Interface graphique simple (WinForms) | 🔴 Complexe | ⭐⭐⭐ |
| **F-014** | Dashboard installations | Suivi statistique (optionnel, anonymisé) | 🔴 Complexe | ⭐⭐ |

---

## 📅 Calendrier estimé

┌─────────────────────────────────────────────────────────────┐
│ MARS 2026 │
│ ✅ V2.0.1 soumise à Chocolatey │
│ ⏳ Attente approbation (2-5 jours) │
│ 📢 Annonce forums Windows 7 │
└─────────────────────────────────────────────────────────────┘
↓
┌─────────────────────────────────────────────────────────────┐
│ AVRIL-MAI 2026 (Q2) │
│ 🛠️ Développement V2.0.2 │
│ • UUP silencieux (F-001) │
│ • Multi-langues (F-002) │
│ • Mode portable (F-003) │
│ 🧪 Tests internes │
└─────────────────────────────────────────────────────────────┘
↓
┌─────────────────────────────────────────────────────────────┐
│ JUIN 2026 │
│ 🚀 Publication V2.0.2 │
│ 📝 Mise à jour documentation │
│ 📢 Annonce communauté │
└─────────────────────────────────────────────────────────────┘
↓
┌─────────────────────────────────────────────────────────────┐
│ JUILLET-DÉCEMBRE 2026 (Q3-Q4) │
│ 💡 Développement V2.1.0 (selon retours utilisateurs) │
│ 🔍 Priorisation basée sur issues GitHub │
└─────────────────────────────────────────────────────────────┘


---

## 📋 Critères de validation pour chaque version

### **Avant publication**

- [ ] Tous les scripts testés localement (Windows 7 SP1 x86)
- [ ] Tests automatisés Chocolatey passés (Validation + Verification + Scan)
- [ ] Documentation README.md mise à jour
- [ ] Changelog complété
- [ ] Version incrémentée dans `win7-adobe-fix.nuspec`
- [ ] Tag Git créé (`vX.X.X`)
- [ ] Package poussé sur Chocolatey.org

### **Critères de qualité**

- [ ] Aucun `Read-Host` bloquant en mode silencieux
- [ ] Tous les hashs DLL documentés dans `verified-hashes.txt`
- [ ] Signature Authenticode vérifiée (Microsoft Corporation)
- [ ] Code compatible PowerShell 5.1 (Windows 7 natif)
- [ ] Pas de fichiers temporaires `.bak` dans le repo

---

## 🐛 Gestion des bugs

| Priorité | Délai de réponse | Délai de correction |
|----------|-----------------|---------------------|
| **Critique** (installation échoue) | 24h | 48h |
| **Majeur** (fonctionnalité cassée) | 48h | 1 semaine |
| **Mineur** (cosmétique/documentation) | 1 semaine | Prochaine version |

---

## 📞 Canaux de feedback

| Canal | URL | Usage |
|-------|-----|-------|
| **Issues GitHub** | https://github.com/valorisa/win7-adobe-reader-winrt-fix-v2/issues | Bugs + fonctionnalités |
| **Chocolatey Comments** | https://community.chocolatey.org/packages/win7-adobe-fix | Retours installation |
| **Forums Windows 7** | https://www.sevenforums.com/ | Communauté utilisateur |
| **Email mainteneur** | (à définir) | Questions privées |

---

## 🏆 Objectifs à long terme

| Objectif | Échéance | Statut |
|----------|----------|--------|
| 1000+ téléchargements Chocolatey | Fin 2026 | ⏳ En attente |
| Approbation modération Chocolatey | Mars 2026 | ⏳ En cours |
| Couverture 5 langues principales | Q2 2026 | 📋 Planifié |
| Zéro bug critique signalé | Continu | ✅ Objectif permanent |
| Documentation 100% à jour | Continu | ✅ Objectif permanent |

---

*Document maintenu par @valorisa — Dernière révision : 02 Mars 2026*
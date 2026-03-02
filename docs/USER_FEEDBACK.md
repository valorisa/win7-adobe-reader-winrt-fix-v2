# 📊 Tableau de suivi des retours utilisateurs

> **Maintenu par :** @valorisa  
> **Dernière mise à jour :** 1er Mars 2026  
> **Format :** Markdown (compatible GitHub Issues + Excel)

---

## 📋 Légende

| Symbole | Signification |
|---------|---------------|
| 🔴 | Critique — Installation échoue |
| 🟠 | Majeur — Fonctionnalité cassée |
| 🟡 | Mineur — Gêne occasionnelle |
| 🟢 | Résolu — Corrigé ou workaround trouvé |
| ⏳ | En attente — Information manquante |
| 💡 | Suggestion — Amélioration proposée |

---

## 📅 Retours par version

### **V2.0.1 (Mars 2026)**

| # | Date | Utilisateur | Canal | Type | Description | Statut | Version corrigée |
|---|------|-------------|-------|------|-------------|--------|------------------|
| 001 | 2026-03-01 | @bbrod | Local | 🟠 Bug | Dossier `scripts/` non copié | 🟢 Résolu | V2.0.1 |
| 002 | 2026-03-01 | @bbrod | Local | 💡 Feature | Mode offline demandé | 🟢 Implémenté | V2.0.1 |
| 003 | 2026-03-01 | @bbrod | Local | 💡 Feature | Multi-hash support | 🟢 Implémenté | V2.0.1 |
| 004 | 2026-03-01 | @bbrod | Local | 🟡 Bug | Hash E4C29D4B... rejeté | 🟢 Résolu | V2.0.1 |
| 005 | 2026-03-01 | Chocolatey | Auto | 🔴 Bug | Verification Testing Failed | 🟢 Résolu | V2.0.1 |

### **V2.0.0 (Février 2026)**

| # | Date | Utilisateur | Canal | Type | Description | Statut | Version corrigée |
|---|------|-------------|-------|------|-------------|--------|------------------|
| 001 | 2026-02-26 | Chocolatey | Auto | 🔴 Bug | `Cannot find path 'scripts'` | 🟢 Résolu | V2.0.1 |
| 002 | 2026-02-26 | chocolatey-ops | Auto | 🟡 Guidelines | Missing iconUrl | 🟢 Résolu | V2.0.1 |
| 003 | 2026-02-26 | chocolatey-ops | Auto | 🟡 Guidelines | Missing packageSourceUrl | 🟢 Résolu | V2.0.1 |
| 004 | 2026-02-26 | chocolatey-ops | Auto | 🟡 Guidelines | Missing releaseNotes | 🟢 Résolu | V2.0.1 |

---

## 📈 Statistiques globales

| Métrique | Valeur |
|----------|--------|
| **Total retours** | 9 |
| **Bugs critiques** | 2 (22%) |
| **Bugs majeurs** | 2 (22%) |
| **Bugs mineurs** | 2 (22%) |
| **Suggestions** | 3 (34%) |
| **Taux de résolution** | 88% (8/9) |
| **Temps moyen de résolution** | 2 jours |

---

## 🎯 Tendances identifiées

| Tendance | Impact | Action |
|----------|--------|--------|
| Besoin mode offline | ⭐⭐⭐⭐⭐ | ✅ Implémenté V2.0.1 |
| Multi-langues demandé | ⭐⭐⭐⭐ | 📋 Planifié V2.0.2 |
| Installation silencieuse | ⭐⭐⭐⭐ | 📋 Planifié V2.0.2 |
| Logs détaillés | ⭐⭐⭐ | 💡 En réflexion V2.1.0 |

---

## 📞 Actions requises

| Priorité | Action | Responsable | Échéance |
|----------|--------|-------------|----------|
| 🔴 | Surveiller emails Chocolatey | @valorisa | 24-48h |
| 🟠 | Répondre aux issues GitHub | @valorisa | 48h |
| 🟡 | Mettre à jour ROADMAP.md | @valorisa | Hebdo |
| 🟢 | Compiler statistiques mensuelles | @valorisa | Mensuel |

---

## 📧 Template de réponse aux utilisateurs

```markdown
Bonjour @<utilisateur>,

Merci pour ton retour sur win7-adobe-fix !

✅ **Statut :** <En cours / Résolu / En attente>
📦 **Version concernée :** <2.0.0 / 2.0.1 / 2.0.2>
🔧 **Action :** <Description de l'action entreprise>

Tu peux suivre l'avancement ici : <lien vers issue GitHub>

N'hésite pas à tester la version <X.X.X> et à nous faire part de tes retours.

Cordialement,
@valorisa
```
---
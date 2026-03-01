# Win7 Adobe Reader WinRT Fix V2.0.1 – Full Auto + Offline Edition

**Réparez le plantage d'Adobe Reader sur Windows 7** causé par la dépendance à `api-ms-win-core-winrt-l1-1-0.dll` après les mises à jour 2026.

> ⚠️ **Windows 7 UNIQUEMENT** — Windows 8, 8.1, 10 et 11 contiennent déjà cette DLL nativement et ne sont pas concernés.

[![Chocolatey](https://img.shields.io/chocolatey/v/win7-adobe-fix?color=green&label=Chocolatey)](https://community.chocolatey.org/packages/win7-adobe-fix)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub last commit](https://img.shields.io/github/last-commit/valorisa/win7-adobe-reader-winrt-fix-v2)](https://github.com/valorisa/win7-adobe-reader-winrt-fix-v2/commits/main)

---

## 🎯 Fonctionnalités principales (V2.0.1)

- ✅ **Extraction automatique** de la DLL officielle Microsoft via **UUP dump Professional** (~250–350 Mo)
- ✅ **NOUVEAU : Mode offline** avec DLL pré-vérifiée (pas de téléchargement, 100 % fiable)
- ✅ **NOUVEAU : Multi-hash support** (2 versions Microsoft acceptées)
- ✅ Vérification **SHA256 + signature Authenticode** (100 % Microsoft)
- ✅ Option **rollback vers Adobe Reader XI 11.0.23** (dernière version stable sans WinRT)
- ✅ Package **Chocolatey prêt à l'emploi**

```powershell
# Installation publique (dès approbation modération)
choco install win7-adobe-fix -y                          # Mode UUP extraction (défaut)
choco install win7-adobe-fix -y --params="/ForceOffline" # Mode offline (DLL pré-embarquée)
choco install win7-adobe-fix -y --params="/RollbackXI"   # Rollback Reader XI
```

---

## 📋 Modes d'installation

| Mode | Commande | Avantages | Inconvénients | Recommandé pour |
| ---- | -------- | --------- | ------------- | --------------- |
| **UUP Extraction** (défaut) | `choco install win7-adobe-fix -y` | DLL officielle, à jour | ~300 Mo téléchargés, 2-3 min | La plupart des cas |
| **Offline** | `--params="/ForceOffline"` | Instantané, pas de réseau | Nécessite DLL pré-embarquée | Machines isolées, tests |
| **Rollback XI** | `--params="/RollbackXI"` | Pas de dépendance WinRT, très stable | ~45 Mo, désinstall DC requise | Anciennes machines lentes |

---

## 🔐 Droits Administrateur requis

| Action | Admin requis ? | Pourquoi |
| ------ | -------------- | -------- |
| **Installation Chocolatey** | ✅ **OUI** | Écrit dans `C:\ProgramData\chocolatey` |
| **Mode UUP Extraction** | ✅ **OUI** | Copie DLL dans `Program Files (x86)\Adobe\` |
| **Mode Offline** | ✅ **OUI** | Copie DLL dans `Program Files (x86)\Adobe\` |
| **Mode Rollback XI** | ✅ **OUI** | Désinstallation + installation logiciel |
| **Test local (choco pack)** | ❌ **NON** | Crée .nupkg dans ton dossier utilisateur |
| **Vérification hash (scan-and-verify.ps1)** | ❌ **NON** | Lecture seule |
| **Git operations (add/commit/push)** | ❌ **NON** | Écrit dans ton dossier Git |

**Comment exécuter en Administrateur :**
1. Clic droit sur PowerShell
2. "Exécuter en tant qu'administrateur"
3. Confirmer l'invite UAC

---

## 🖥️ PowerShell 5.1 vs PowerShell 7+ — Lequel utiliser ?

### **Ce projet utilise Windows PowerShell 5.1**

Tous les scripts de ce projet sont **100 % compatibles Windows PowerShell 5.1**, la version native incluse dans Windows 7/8.1/10/11.

### **Différences clés entre PowerShell 5.1 et 7+**

| Caractéristique | Windows PowerShell 5.1 | PowerShell 7+ |
| -------------- | ---------------------- | ------------- |
| **Version** | 5.1.17763.x (native Windows) | 7.x.x (cross-platform) |
| **Framework** | .NET Framework 4.8 | .NET Core / .NET 5+ |
| **Disponibilité** | Pré-installé sur Windows 7+ | À installer séparément |
| **Compatibilité** | 100 % modules Windows legacy | Certains modules incompatibles |
| **Performance** | Standard | Plus rapide, meilleur pipeline |
| **Support** | Maintenance uniquement | Actif + nouvelles fonctionnalités |
| **Plateformes** | Windows uniquement | Windows, Linux, macOS |

### **Pourquoi ce projet utilise PowerShell 5.1**

| Raison | Explication |
| ------ | ----------- |
| **✅ Windows 7 natif** | PowerShell 5.1 est pré-installé sur Windows 7 (pas d'installation supplémentaire) |
| **✅ Compatibilité maximale** | Tous les modules Windows (WMI, Registry, COM) fonctionnent sans problème |
| **✅ Stabilité** | Version mature, testée depuis 2016, aucun breaking change |
| **✅ Chocolatey** | Chocolatey fonctionne nativement avec PS 5.1 sur Windows 7 |
| **✅ Scripts legacy** | Certains cmdlets (`Get-WmiObject`, `Win32_Product`) sont dépréciés dans PS 7+ |

### **Quand utiliser PowerShell 7+ ?**

| Scénario | Recommandation |
|----------|---------------|
| **Développement moderne** | ✅ PS 7+ (nouvelles fonctionnalités, performances) |
| **Scripts cross-platform** | ✅ PS 7+ (Linux, macOS supportés) |
| **Automation CI/CD** | ✅ PS 7+ (GitHub Actions, Azure DevOps) |
| **Windows 7 / legacy** | ✅ **PS 5.1** (natif, compatible) |
| **Modules Windows spécifiques** | ✅ **PS 5.1** (WMI, COM, registry profond) |
| **Chocolatey sur Win7** | ✅ **PS 5.1** (recommandé par Chocolatey) |

### **Vérifier ta version PowerShell**

```powershell
# Affiche la version installée
$PSVersionTable.PSVersion

# Résultat attendu pour ce projet :
# Major  Minor  Build  Revision
# -----  -----  -----  --------
# 5      1      ...    ...
```

### **Installer PowerShell 7+ (optionnel)**

Si tu veux PS 7+ pour d'autres projets :

```powershell
# Via Chocolatey (Windows 10/11 recommandé)
choco install powershell -y

# PowerShell 7 sera installé dans :
# C:\Program Files\PowerShell\7\pwsh.exe
# (ne remplace PAS Windows PowerShell 5.1)
```

> 💡 **Bon à savoir :** PowerShell 7+ peut coexister avec PowerShell 5.1. Ils sont installés côte à côte et n'entrent pas en conflit.

---

## 🎯 Objectif

Adobe Reader (AcroRd32.exe) plante sur Windows 7 depuis les mises à jour début 2026 qui introduisent une dépendance à la DLL `api-ms-win-core-winrt-l1-1-0.dll` (composant WinRT absent sur Win7).

Ce projet fournit **trois solutions** propres et reproductibles :

1. **Extraction automatique** via UUP dump (DLL officielle Microsoft)
2. **Mode offline** avec DLL pré-vérifiée (100 % fiable, pas de téléchargement)
3. **Rollback complet** vers Adobe Reader XI 11.0.23 (dernière version stable sans WinRT)

---

## ⚡ Installation rapide

### Via Chocolatey (recommandé)

**Version publique (dès approbation modération) :**
```powershell
# Mode 1 : Extraction UUP automatique (défaut)
choco install win7-adobe-fix -y

# Mode 2 : Offline (DLL pré-embarquée, pas de téléchargement)
choco install win7-adobe-fix -y --params="/ForceOffline"

# Mode 3 : Rollback vers Reader XI 11.0.23
choco install win7-adobe-fix -y --params="/RollbackXI"
```

**Test local (depuis ce repo) :**
```powershell
# Pack
choco pack chocolatey\win7-adobe-fix.nuspec

# Install
choco install win7-adobe-fix --source . -y
choco install win7-adobe-fix --source . -y --params="/ForceOffline"
choco install win7-adobe-fix --source . -y --params="/RollbackXI"
```

### Manuel (sans Chocolatey)

```powershell
# Exécute en Administrateur
Set-ExecutionPolicy Bypass -Scope Process -Force
.\chocolatey\scripts\main-fix.ps1
```

---

## 📦 Mode offline (Nouveau en V2.0.1)

Le mode offline permet d'utiliser une DLL **pré-vérifiée** sans extraction UUP. Idéal pour :
- Machines sans connexion Internet
- Tests rapides en local
- Déploiements en entreprise

### Préparation

1. Place la DLL vérifiée dans :
   ```
   .\chocolatey\scripts\offline\api-ms-win-core-winrt-l1-1-0.dll
   ```

2. Vérifie le hash (doit correspondre à l'une des versions acceptées) :
   ```powershell
   .\chocolatey\scripts\scan-and-verify.ps1 -DllPath ".\chocolatey\scripts\offline\api-ms-win-core-winrt-l1-1-0.dll"
   ```

### Hashs acceptés

| Version | Hash SHA256 | Taille | Source |
|---------|-------------|--------|--------|
| Windows 10 22H2 (build 19041) | `B30F6D5E1328144C41F1116F9E3A50F458FC455B16900ED9B48CEAE0771696BD` | 13 192 octets | Win10 22H2 x86 officiel |
| Windows 10 Technical Preview (build 9904) | `E4C29D4B5496C965B903CAA1722F3A54DB22B95688A10B8A103639BA4B1F999D` | 19 192 octets | Win10 TP x86 (validé) |

> ✅ Toutes les versions sont **signées Microsoft Corporation** et vérifiées VirusTotal (0/66 détections).

### Utilisation

```powershell
# En local
.\chocolatey\scripts\uup-extract-dll.ps1 -ForceOffline

# Via Chocolatey
choco install win7-adobe-fix -y --params="/ForceOffline"
```

---

## 🔍 Vérification et sécurité

Chaque DLL est vérifiée avant installation :

1. **Hash SHA256** — Comparé aux références Microsoft officielles (multi-hash support)
2. **Signature Authenticode** — Doit être signée par Microsoft Corporation
3. **Optionnel : VirusTotal** — Scan disponible via API (voir `scan-and-verify.ps1`)

### Exemple de vérification manuelle

```powershell
# Vérifie une DLL
.\chocolatey\scripts\scan-and-verify.ps1 -DllPath "chemin\vers\dll"

# Affiche les hashes de référence
Get-Content .\verified-hashes.txt
```

---

## 📁 Structure du dépôt

```text
PS C:\Users\bbrod\Projets\win7-adobe-reader-winrt-fix-v2> tree
.
├── README.md                      # Documentation principale du projet (V2.0.1)
├── LICENSE                        # Licence MIT du projet
├── verified-hashes.txt            # Hashs officiels Microsoft validés (multi-hash)
├── chocolatey/
│   ├── win7-adobe-fix.nuspec      # Spécifications package Chocolatey (v2.0.1)
│   ├── scripts/
│   │   ├── main-fix.ps1           # Orchestrateur principal
│   │   ├── offline/               # Mode offline (NOUVEAU V2.0.1)
│   │   │   └── api-ms-win-core-winrt-l1-1-0.dll  # DLL WinRT signée Microsoft
│   │   ├── rollback-reader-xi.ps1 # Rollback vers Reader XI
│   │   ├── scan-and-verify.ps1    # Vérification hash + signature (V2.1)
│   │   └── uup-extract-dll.ps1    # Extraction DLL (V6.4 + offline)
│   └── tools/
│       └── chocolateyInstall.ps1  # Script d'installation (robocopy)
└── .github/
    └── workflows/
        └── build-and-publish-choco.yml  # CI/CD automatique
```

**Total :** 4 dossiers, 11 fichiers (aucun fichier temporaire .bak)

---

## 🛠️ Dépannage

### Problème : "DLL introuvable dans les archives UUP"

**Cause :** L'ID UUP ne contient pas la DLL dans cette édition.

**Solutions :**
1. Utilise le mode offline :
   ```powershell
   .\chocolatey\scripts\uup-extract-dll.ps1 -ForceOffline
   ```
2. Vérifie que l'URL utilise `edition=professional` (pas `core`)
3. Consulte `verified-hashes.txt` pour les hashes alternatifs

### Problème : "Hash non reconnu"

**Cause :** La DLL provient d'une version Windows différente.

**Solutions :**
1. Vérifie la signature Authenticode :
   ```powershell
   Get-AuthenticodeSignature "chemin\vers\dll"
   ```
2. Si signée Microsoft → ajoute le hash à `verified-hashes.txt`
3. Si non signée → **ne pas utiliser** (risque de sécurité)

### Problème : "Dossier Adobe non trouvé"

**Cause :** Adobe Reader n'est pas installé à l'emplacement par défaut.

**Solutions :**
1. Vérifie l'installation :
   ```powershell
   Test-Path "$env:ProgramFiles (x86)\Adobe\Acrobat Reader DC\Reader"
   ```
2. Copie manuellement la DLL depuis `%TEMP%\UUP_extract_*\`
3. Utilise le rollback Reader XI qui gère l'installation complète

### Problème Chocolatey : "Package has a previous version in a submitted state"

**Cause :** Une version précédente est en attente de modération.

**Solutions :**
1. Va sur https://community.chocolatey.org/packages/win7-adobe-fix
2. Connecte-toi avec ton compte mainteneur
3. Ajoute un commentaire dans "Add to Review Comments"
4. Demande le rejet de l'ancienne version
5. Attends 24-48h (modération)
6. Resoumets la nouvelle version

---

## 🚀 Publication et maintenance

### Build local
```powershell
cd chocolatey
choco pack win7-adobe-fix.nuspec --outputdirectory ..
```

### Publication sur Chocolatey.org
```powershell
choco push win7-adobe-fix.2.0.1.nupkg --api-key=TACLE --source=https://push.chocolatey.org/
```

> ⚠️ **Remplace `TACLE` par ta vraie clé API Chocolatey** (disponible sur https://community.chocolatey.org/account)

### CI/CD Automatique (GitHub Actions)

Le workflow `.github/workflows/build-and-publish-choco.yml` se déclenche automatiquement :
- À chaque **tag** (`v*.*.*`) → build + publication
- Manuellement via **workflow_dispatch**

**Secrets requis :**
- `CHOCO_API_KEY` → Clé API Chocolatey.org

---

## 📝 Changelog

### V2.0.1 (Mars 2026)
- ✅ **Mode offline** avec DLL pré-vérifiée
- ✅ **Multi-hash support** (2 versions Microsoft acceptées)
- ✅ UUID UUP mis à jour (`0e85a309-...` Professional fr-fr)
- ✅ URL dynamique (`$Pack`, `$Edition` paramétrables)
- ✅ `scan-and-verify.ps1` V2.1 compatible PowerShell 5.1
- ✅ Correction `chocolateyInstall.ps1` (copie robuste via robocopy)
- ✅ Correction `win7-adobe-fix.nuspec` (ajout `tools/` dans les fichiers)
- ✅ README.md mis à jour avec documentation complète

### V2.0.0 (Février 2026)
- Extraction UUP automatique
- Vérification hash + signature
- Option rollback Reader XI
- Package Chocolatey initial

---

## 📄 Licence

MIT License — Voir [LICENSE](LICENSE) pour les détails.

---

## 🙏 Remerciements

- **UUP dump** — Pour l'accès aux builds Windows officiels
- **Chocolatey** — Pour la plateforme de distribution
- **Communauté Windows 7** — Pour les tests et retours

---

*valorisa@2026* — Approuvé, encadré, testé. 😈🚀

---

## 📞 Support

- **Issues GitHub** : https://github.com/valorisa/win7-adobe-reader-winrt-fix-v2/issues
- **Documentation** : https://github.com/valorisa/win7-adobe-reader-winrt-fix-v2/wiki
- **Chocolatey** : https://community.chocolatey.org/packages/win7-adobe-fix

---


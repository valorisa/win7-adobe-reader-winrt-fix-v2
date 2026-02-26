# Win7 Adobe Reader WinRT Fix V2 – Full Auto Edition

**Réparez le plantage d’Adobe Reader sur Windows 7** causé par la dépendance à `api-ms-win-core-winrt-l1-1-0.dll` après les mises à jour 2026.

[![Chocolatey](https://img.shields.io/chocolatey/v/win7-adobe-fix?color=green&label=Chocolatey)](https://community.chocolatey.org/packages/win7-adobe-fix)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub last commit](https://img.shields.io/github/last-commit/valorisa/win7-adobe-reader-winrt-fix-v2)](https://github.com/valorisa/win7-adobe-reader-winrt-fix-v2/commits/main)

**Fonctionnalités principales**
- Extraction automatique de la DLL officielle Microsoft via **UUP dump minimal** (~250–350 Mo, pas d’ISO de 6 Go)
- Vérification SHA256 + signature Authenticode (100 % Microsoft)
- Option rollback vers **Adobe Reader XI 11.0.23** (dernière version stable sans dépendance WinRT)
- Package Chocolatey prêt à l’emploi

```powershell
# Installation publique (dès que modéré)
choco install win7-adobe-fix -y --params="'/DLLonly'"     # ou /RollbackXI
```

## Objectif

Adobe Reader (AcroRd32.exe) plante sur Windows 7 depuis les mises à jour début 2026 qui introduisent une dépendance à la DLL `api-ms-win-core-winrt-l1-1-0.dll` (composant WinRT absent sur Win7).  
Ce projet fournit deux solutions propres et reproductibles :

1. Copie de la DLL officielle extraite depuis un build Windows 10/11 (méthode recommandée)
2. Rollback complet vers Adobe Reader XI 11.0.23

## Méthodes proposées

| Méthode                          | Avantages                              | Inconvénients                     | Recommandé pour |
|----------------------------------|----------------------------------------|------------------------------------|-----------------|
| Copie DLL via UUP dump           | Léger (~300 Mo), 100 % Microsoft, rapide | Nécessite clic sur uupdump.net    | La plupart des cas |
| Rollback vers Reader XI 11.0.23  | Pas de dépendance WinRT, très stable   | Plus lourd (~45 Mo + désinstall)  | Anciennes machines |

## Pré-requis

- Chocolatey installé (`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))`)
- aria2 installé (`choco install aria2 -y`)
- PowerShell 5.1 ou supérieur (natif sur Windows 7/10/11)

## Installation

### Via Chocolatey (recommandé)

**Version publique (community.chocolatey.org)**  
Dès approbation de la modération :

```powershell
choco install win7-adobe-fix -y --params="/DLLonly"     # Copie DLL uniquement
# ou
choco install win7-adobe-fix -y --params="/RollbackXI"  # Rollback Reader XI
```

**Test local (depuis ce repo)**

```powershell
# Pack
choco pack chocolatey\win7-adobe-fix.nuspec

# Install
choco install win7-adobe-fix --source . -y --params="/DLLonly"
```

### Manuel (sans Chocolatey)

```powershell
# Lance le fix complet (UUP + extraction + vérif + copie ou rollback)
.\scripts\main-fix.ps1
```

## Publication Chocolatey

Package publié sous le nom **win7-adobe-fix** (version 2.0.0 actuelle).

- **Nom du package** : `win7-adobe-fix`
- **Page officielle** : https://community.chocolatey.org/packages/win7-adobe-fix (en attente de modération)
- **Commandes utiles** :
  - `/DLLonly` → copie uniquement la DLL WinRT (solution légère recommandée)
  - `/RollbackXI` → rollback complet vers Adobe Reader XI 11.0.23

Le package est construit depuis `chocolatey\win7-adobe-fix.nuspec` et inclut :
- Extraction DLL via UUP dump minimal
- Vérification intégrité (hash + signature Microsoft)
- Licence MIT (voir [LICENSE](LICENSE))

Pour les futures versions : incrémentez `<version>` dans le .nuspec, `choco pack`, puis `choco push`.

## Structure du dépôt

```
win7-adobe-reader-winrt-fix-v2/
├── LICENSE
├── README.md
├── verified-hashes.txt
├── .github/
│   └── workflows/
│       └── build-and-publish-choco.yml
├── chocolatey/
│   ├── win7-adobe-fix.nuspec
│   └── tools/
│       └── chocolateyInstall.ps1
├── scripts/
│   ├── uup-extract-dll.ps1
│   ├── scan-and-verify.ps1
│   ├── rollback-reader-xi.ps1
│   └── main-fix.ps1
└── .gitignore
```

## Améliorations futures

- UUP dump 100 % silencieux (via API uupdump + aria2 scripté)
- Publication automatique sur Chocolatey.org à chaque tag
- Support Windows 8.1 / versions plus anciennes d’Adobe
- Ajout d’un mode « offline » complet (DLL pré-extraite)

Elon approuverait. 😈🚀

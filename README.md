# Win7 Adobe Reader WinRT Fix V2 - Full Auto Edition

**UUP dump 100 % automatique** (pas d’ISO 6 Go)  
**GitHub Actions** → build Chocolatey nupkg  
**Chocolatey package** `win7-adobe-fix` (install en 1 commande)

```powershell
choco install win7-adobe-fix -y --params="'/DLLonly'"   # ou /RollbackXI
```

Tout est vérifié (hash Microsoft + signature Authenticode + VT).

## Objectif

Réparer le plantage d’Adobe Reader (AcroRd32.exe) sur Windows 7 après la mise à jour 2026 qui ajoute une dépendance à `api-ms-win-core-winrt-l1-1-0.dll` (DLL WinRT absente sur Win7).

## Méthodes proposées

1. **Copie de la DLL officielle** extraite via UUP dump (minimal ~250 Mo, 100 % Microsoft)  
2. **Rollback vers Adobe Reader XI 11.0.23** (dernière version stable sans dépendance WinRT)

## Pré-requis

- Chocolatey installé  
- aria2 installé (`choco install aria2 -y`)  
- PowerShell 5.1 ou supérieur (natif Windows OK)

## Installation rapide (via Chocolatey local)

```powershell
# Depuis le dossier du repo
choco pack chocolatey\win7-adobe-fix.nuspec
choco install win7-adobe-fix --source . -y --params="/DLLonly"

# Ou pour le rollback Reader XI :
choco install win7-adobe-fix --source . -y --params="/RollbackXI"
```

## Utilisation manuelle (sans Chocolatey)

```powershell
# Lance le fix complet (UUP + extraction + vérif + copie)
.\scripts\main-fix.ps1
```

## Structure du repo

```text
win7-adobe-reader-winrt-fix-v2/
├── README.md
├── verified-hashes.txt
├── .github/workflows/
│   └── build-and-publish-choco.yml
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

## Développement / Améliorations futures

- UUP dump 100 % silencieux (sans clic manuel)  
- Publication automatique sur community.chocolatey.org  
- Support multi-versions Windows 7 / 8.1

Elon approuverait. 😈🚀


# =============================================================================
# uup-extract-dll.ps1 - V6.4 (Mars 2026 - MODE OFFLINE + URL CORRIGÉE + DEBUG)
# Fix automatique pour Adobe Reader sur Windows 7
# =============================================================================
[CmdletBinding()]
param(
    [string]$UupId = "0e85a309-5d76-4452-86c5-f9e17c3c2344",    # ✅ UUID Professional x86 fr-fr
    [string]$Arch = "x86",
    [string]$Pack = "fr-fr",                                    # ✅ Nouveau paramètre
    [string]$Edition = "professional",                          # ✅ Nouveau paramètre (PAS "core" !)
    [switch]$DryRun = $false,
    [switch]$Cleanup = $true,
    [switch]$DebugMode = $false,
    [switch]$ForceOffline = $false,                             # ✅ Mode offline forcé
    [string]$TargetFolder = "$env:ProgramFiles (x86)\Adobe\Acrobat Reader DC\Reader"
)

# ---------------------------------------------------------------------------
# PRÉPARATION GÉNÉRALE
# ---------------------------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# ✅ CORRECTION CRITIQUE : URL sans espaces traînants
$siteBase = "https://uupdump.net"
$dllName  = "api-ms-win-core-winrt-l1-1-0.dll"
$expectedHash = "B30F6D5E1328144C41F1116F9E3A50F458FC455B16900ED9B48CEAE0771696BD"

Write-Host "`n=== UUP Dump V6.4 - Fix Adobe Reader WinRT (x86) ===" -ForegroundColor Cyan
Write-Host "DLL cible : $dllName" -ForegroundColor Gray
Write-Host "ID UUP : $UupId | Édition : $Edition | Pack : $Pack" -ForegroundColor Green
if ($DebugMode) { Write-Host "[DEBUG MODE ACTIVÉ]" -ForegroundColor Yellow }
if ($ForceOffline) { Write-Host "[MODE OFFLINE FORCÉ]" -ForegroundColor Yellow }

# ---------------------------------------------------------------------------
# MODE OFFLINE : Vérification immédiate si activé ou si DLL locale présente
# ---------------------------------------------------------------------------
$offlineDll = Join-Path $PSScriptRoot "offline\$dllName"
$found = $false

if ($ForceOffline -or (Test-Path $offlineDll)) {
    Write-Host "`n[Mode Offline] Vérification de la DLL locale..." -ForegroundColor Cyan
    if (Test-Path $offlineDll) {
        $offlineHash = (Get-FileHash $offlineDll -Algorithm SHA256).Hash
        if ($offlineHash -eq $expectedHash) {
            Write-Host "✅ Hash vérifié - DLL locale valide" -ForegroundColor Green
            $extractDir = Join-Path $env:TEMP "UUP_extract_offline"
            New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
            Copy-Item -Path $offlineDll -Destination (Join-Path $extractDir $dllName) -Force
            $found = $true
            $dllPath = Join-Path $extractDir $dllName
        } else {
            Write-Warning "⚠️ Hash offline invalide !"
            Write-Host "  Attendu : $expectedHash" -ForegroundColor Gray
            Write-Host "  Obtenu  : $offlineHash" -ForegroundColor Gray
            if (-not $ForceOffline) { 
                Write-Host "→ Poursuite avec extraction UUP..." -ForegroundColor Yellow 
            } else { 
                Write-Error "Mode offline forcé mais hash invalide. Arrêt."; exit 1 
            }
        }
    } elseif ($ForceOffline) {
        Write-Error "Mode offline forcé mais DLL absente : $offlineDll"; exit 1
    }
}

# ---------------------------------------------------------------------------
# CONSTRUCTION URL & TÉLÉCHARGEMENT (si pas déjà trouvé en offline)
# ---------------------------------------------------------------------------
if (-not $found) {
    # ✅ CORRECTION : URL dynamique avec $Pack et $Edition
    $aria2Url = "$siteBase/get.php?id=$UupId&pack=$Pack&edition=$Edition&aria2=1"
    
    if ($DryRun) {
        Write-Host "[DRY-RUN] URL : $aria2Url" -ForegroundColor Yellow
        exit 0
    }

    # ---------------------------------------------------------------------------
    # OUTILS REQUIS
    # ---------------------------------------------------------------------------
    $aria2    = Join-Path $env:ProgramData "chocolatey\bin\aria2c.exe"
    $sevenZip = "C:\Program Files\7-Zip\7z.exe"
    if (-not (Test-Path $sevenZip)) { $sevenZip = Join-Path $env:ProgramData "chocolatey\bin\7z.exe" }
    $wimlib   = Join-Path $env:ProgramData "chocolatey\bin\wimlib-imagex.exe"

    if (-not (Test-Path $aria2))    { choco install aria2 -y --no-progress | Out-Null }
    if (-not (Test-Path $sevenZip)) { choco install 7zip -y --no-progress | Out-Null; $sevenZip = "C:\Program Files\7-Zip\7z.exe" }
    if (-not (Test-Path $wimlib))   { choco install wimlib -y --no-progress | Out-Null }

    Write-Host "7-Zip : $sevenZip" -ForegroundColor Gray
    Write-Host "wimlib : $wimlib" -ForegroundColor Gray

    # ---------------------------------------------------------------------------
    # DOSSIERS TEMPORAIRES
    # ---------------------------------------------------------------------------
    $ariaFile   = Join-Path $env:TEMP "uup_$UupId.aria2.txt"
    $uupDir     = Join-Path $env:TEMP "UUPs_$UupId"
    $extractDir = Join-Path $env:TEMP "UUP_extract_$UupId"

    Remove-Item $uupDir -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $uupDir -Force | Out-Null
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

    # ---------------------------------------------------------------------------
    # TÉLÉCHARGEMENT
    # ---------------------------------------------------------------------------
    Write-Host "`nTéléchargement de la liste..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $aria2Url -OutFile $ariaFile -UseBasicParsing -UserAgent $UserAgent -TimeoutSec 120

    Write-Host "Téléchargement des fichiers..." -ForegroundColor Cyan
    & $aria2 -i $ariaFile -d $uupDir --continue=true --max-connection-per-server=8 --split=8 --min-split-size=1M `
        --console-log-level=notice --summary-interval=10 "--user-agent=$UserAgent"
    if ($LASTEXITCODE -ne 0) { Write-Error "aria2 a échoué"; exit 1 }
    Write-Host "Téléchargement terminé." -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# FONCTION UTILITAIRE : Recherche récursive de la DLL
# ---------------------------------------------------------------------------
function Find-DllRecursively {
    param([string]$SearchPath, [string]$FileName)
    return Get-ChildItem -Path $SearchPath -Recurse -File -Filter $FileName -ErrorAction SilentlyContinue | Select-Object -First 1
}

# ---------------------------------------------------------------------------
# ÉTAPE 1 : Extraction via wimlib (mode robuste + wildcard + gestion RemoteException)
# ---------------------------------------------------------------------------
if (-not $found) {
    Write-Host "`n[Étape 1] Extraction via wimlib..." -ForegroundColor Cyan
    $dllPath = Join-Path $extractDir $dllName

    $mainEsd = Get-ChildItem -Path $uupDir -File -Filter "*.esd" | Sort-Object Length -Descending | Select-Object -First 1
    if (-not $mainEsd) { Write-Error "Aucun fichier ESD trouvé."; exit 1 }

    Write-Host " Archive principale : $($mainEsd.Name) ($([math]::Round($mainEsd.Length / 1MB)) Mo)" -ForegroundColor Gray

    # Lister les index disponibles
    $indexes = (& $wimlib info $mainEsd.FullName 2>$null | Select-String "Image [0-9]+") |
        ForEach-Object { if ($_ -match "Image\s+(\d+)") { [int]$matches[1] } }
    if (-not $indexes) { $indexes = @(1) }

    foreach ($idx in $indexes) {
        Write-Host " Tentative wimlib (image $idx)..." -ForegroundColor Yellow
        
        try {
            # ✅ Wildcard large + nullglob + gestion propre des erreurs via Start-Process
            $wimArgs = @(
                "extract", $mainEsd.FullName, $idx,
                "*$dllName",
                "--dest-dir=$extractDir", "--no-acls", "--nullglob"
            )
            $proc = Start-Process -FilePath $wimlib -ArgumentList $wimArgs -Wait -NoNewWindow -PassThru `
                -RedirectStandardError "$env:TEMP\wimlib_err_$idx.log"
            
            if ($proc.ExitCode -ne 0 -and $DebugMode) {
                Write-Warning "wimlib exit code: $($proc.ExitCode) - Voir: $env:TEMP\wimlib_err_$idx.log"
            }
        } catch {
            if ($DebugMode) { Write-Warning "Erreur wimlib ignorée : $_" }
        }

        # Recherche récursive post-extraction
        $foundDll = Find-DllRecursively -SearchPath $extractDir -FileName $dllName
        if ($foundDll) {
            if ($foundDll.FullName -ne $dllPath) {
                Copy-Item -Path $foundDll.FullName -Destination $dllPath -Force
            }
            Write-Host " ✅ Trouvée via wimlib + recherche récursive (image $idx)" -ForegroundColor Green
            $found = $true
            break
        }
    }
}

# ---------------------------------------------------------------------------
# ÉTAPE 2 : Fallback 7-Zip sur TOUS les ESD
# ---------------------------------------------------------------------------
if (-not $found) {
    Write-Host "`n[Étape 2] Fallback 7-Zip sur tous les ESD..." -ForegroundColor Yellow
    $allEsds = Get-ChildItem -Path $uupDir -File -Filter "*.esd"
    
    foreach ($esd in $allEsds) {
        Write-Host " Extraction : $($esd.Name)..." -ForegroundColor Gray
        $tempDir = Join-Path $extractDir "esd_$($esd.BaseName)"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        
        try {
            & $sevenZip x $esd.FullName -o"$tempDir" -r -y "*$dllName" 2>&1 | Out-Null
        } catch {
            if ($DebugMode) { Write-Warning "Erreur 7-Zip ignorée sur $($esd.Name)" }
        }
        
        $foundDll = Find-DllRecursively -SearchPath $tempDir -FileName $dllName
        if ($foundDll) {
            Copy-Item -Path $foundDll.FullName -Destination $dllPath -Force
            Write-Host " ✅ Trouvée via 7-Zip dans : $($esd.Name)" -ForegroundColor Green
            $found = $true
            break
        }
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ---------------------------------------------------------------------------
# ÉTAPE 3 : Fallback CAB avec expand
# ---------------------------------------------------------------------------
if (-not $found) {
    Write-Host "`n[Étape 3] Fallback CAB avec expand..." -ForegroundColor Yellow
    $cabs = Get-ChildItem -Path $uupDir -File -Filter "*.cab"
    
    foreach ($cab in $cabs) {
        try {
            & "$env:SystemRoot\System32\expand.exe" "$($cab.FullName)" -F:* "$extractDir" 2>$null | Out-Null
        } catch {
            if ($DebugMode) { Write-Warning "Erreur expand ignorée sur $($cab.Name)" }
        }
        
        $foundDll = Find-DllRecursively -SearchPath $extractDir -FileName $dllName
        if ($foundDll) {
            if ($foundDll.FullName -ne $dllPath) {
                Copy-Item -Path $foundDll.FullName -Destination $dllPath -Force
            }
            Write-Host " ✅ Trouvée via expand dans : $($cab.Name)" -ForegroundColor Green
            $found = $true
            break
        }
    }
}

# ---------------------------------------------------------------------------
# ÉTAPE 4 : Recherche de dernier recours dans TOUT le dossier UUP
# ---------------------------------------------------------------------------
if (-not $found) {
    Write-Host "`n[Étape 4] Recherche de dernier recours (scan complet)..." -ForegroundColor Yellow
    $foundDll = Find-DllRecursively -SearchPath $uupDir -FileName $dllName
    if ($foundDll) {
        Copy-Item -Path $foundDll.FullName -Destination $dllPath -Force
        Write-Host " ✅ Trouvée par scan complet dans : $($foundDll.DirectoryName)" -ForegroundColor Green
        $found = $true
    }
}

# ---------------------------------------------------------------------------
# ÉCHEC FINAL
# ---------------------------------------------------------------------------
if (-not $found) {
    Write-Error "❌ DLL '$dllName' introuvable dans les archives UUP."
    
    if ($DebugMode) {
        Write-Host "`n[DEBUG] Fichiers ESD disponibles :" -ForegroundColor Yellow
        Get-ChildItem $uupDir -Filter "*.esd" | ForEach-Object { Write-Host "  - $($_.Name)" }
        Write-Host "`n[DEBUG] Inspection manuelle recommandée :" -ForegroundColor Yellow
        if ($mainEsd) {
            Write-Host "  wimlib-imagex dir `"$($mainEsd.FullName)`" 1 | Select-String winrt" -ForegroundColor Gray
        }
    }
    
    Write-Host "`n💡 Solution de secours :" -ForegroundColor Cyan
    Write-Host "  1. Place la DLL vérifiée dans : .\chocolatey\scripts\offline\$dllName" -ForegroundColor Gray
    Write-Host "  2. Relance avec : -ForceOffline" -ForegroundColor Gray
    Write-Host "  Hash attendu : $expectedHash" -ForegroundColor Gray
    
    Write-Host "`nFichiers UUP : $uupDir" -ForegroundColor Yellow
    Write-Host "Extraction : $extractDir" -ForegroundColor Yellow
    exit 1
}

# ---------------------------------------------------------------------------
# VÉRIFICATION + INSTALLATION
# ---------------------------------------------------------------------------
Write-Host "`n[Validation] Vérification signature et hash..." -ForegroundColor Cyan
$sig = Get-AuthenticodeSignature $dllPath
$hash = (Get-FileHash $dllPath -Algorithm SHA256).Hash
Write-Host " SHA256 : $hash" -ForegroundColor Gray

if ($hash -eq $expectedHash) {
    Write-Host "✅ Hash correspond à la référence Microsoft officielle" -ForegroundColor Green
} else {
    Write-Warning "⚠️ Hash différent de la référence attendue"
    if (-not $DebugMode) {
        $confirm = Read-Host "Continuer quand même ? (O/N)"
        if ($confirm -notlike "O*") { exit 1 }
    }
}

if ($sig.Status -eq "Valid" -and $sig.SignerCertificate.Subject -match "Microsoft") {
    Write-Host "✅ Signature Microsoft valide" -ForegroundColor Green
} else {
    Write-Warning "⚠️ Signature : $($sig.Status) - Sujet : $($sig.SignerCertificate.Subject)"
}

Write-Host "`n[Installation] Copie vers le dossier Adobe..." -ForegroundColor Cyan
if (Test-Path $TargetFolder) {
    $destPath = Join-Path $TargetFolder $dllName
    if (Test-Path $destPath) {
        $backup = "$destPath.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item -Path $destPath -Destination $backup -Force
        Write-Host " Backup créé : $backup" -ForegroundColor Gray
    }
    Copy-Item -Path $dllPath -Destination $TargetFolder -Force
    Write-Host "✅ DLL installée : $destPath" -ForegroundColor Green
} else {
    Write-Warning "⚠️ Dossier Adobe non trouvé : $TargetFolder"
    Write-Host " DLL disponible ici : $dllPath" -ForegroundColor Yellow
    $Cleanup = $false
}

# ---------------------------------------------------------------------------
# NETTOYAGE
# ---------------------------------------------------------------------------
if ($Cleanup) {
    Write-Host "`n[Nettoyage] Suppression des fichiers temporaires..." -ForegroundColor Gray
    Remove-Item "$env:TEMP\wimlib_err_*.log" -Force -ErrorAction SilentlyContinue
    if (-not $ForceOffline) {
        Remove-Item $ariaFile   -Force -ErrorAction SilentlyContinue
        Remove-Item $uupDir     -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host "✅ Nettoyage terminé" -ForegroundColor Green
}

Write-Host "`n=== 🎉 TERMINÉ AVEC SUCCÈS ===" -ForegroundColor Magenta
Write-Host "Redémarre Adobe Reader pour tester le fix !" -ForegroundColor Cyan
Write-Host "En cas de problème, relance avec -DebugMode pour plus de détails.`n" -ForegroundColor Gray
# =============================================================================
# uup-extract-dll.ps1 - V6.2 (Mars 2026 - WIMLIB ROBUSTE + NULLGLOB)
# Fix automatique pour Adobe Reader sur Windows 7
# =============================================================================
[CmdletBinding()]
param(
    [string]$UupId = "f8aba250-e2aa-4a80-bc91-fb471f135948",
    [string]$Arch = "x86",
    [switch]$DryRun   = $false,
    [switch]$Cleanup  = $true,
    [string]$TargetFolder = "$env:ProgramFiles (x86)\Adobe\Acrobat Reader DC\Reader"
)

# ---------------------------------------------------------------------------
# PRÉPARATION GÉNÉRALE
# ---------------------------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$siteBase = "https://uupdump.net"
$dllName  = "api-ms-win-core-winrt-l1-1-0.dll"

Write-Host "`n=== UUP Dump V6.2 - Fix Adobe Reader WinRT (x86) ===" -ForegroundColor Cyan
Write-Host "DLL cible : $dllName" -ForegroundColor Gray
Write-Host "ID UUP : $UupId" -ForegroundColor Green

$aria2Url = "$siteBase/get.php?id=$UupId&pack=en-us&edition=core&aria2=1"
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

# ---------------------------------------------------------------------------
# EXTRACTION - wimlib direct (mode robuste)
# ---------------------------------------------------------------------------
Write-Host "`nExtraction de la DLL..." -ForegroundColor Cyan
$dllPath = Join-Path $extractDir $dllName
$found   = $false

$mainEsd = Get-ChildItem -Path $uupDir -File -Filter "*.esd" | Sort-Object Length -Descending | Select-Object -First 1
if (-not $mainEsd) { Write-Error "Aucun ESD trouvé."; exit 1 }

Write-Host " Archive principale : $($mainEsd.Name) ($([math]::Round($mainEsd.Length / 1MB)) Mo)" -ForegroundColor Gray

# Lister les index disponibles
$indexes = (& $wimlib info $mainEsd.FullName | Select-String "Image [0-9]+") |
    ForEach-Object { if ($_ -match "Image\s+(\d+)") { [int]$matches[1] } }
if (-not $indexes) { $indexes = 1 }

foreach ($idx in $indexes) {
    Write-Host " Tentative wimlib (image $idx)..." -ForegroundColor Yellow
    
    # 2>&1 | Out-Null empêche PowerShell de planter sur les messages stderr de wimlib
    # --nullglob permet de ne pas échouer si le fichier est absent d'un des chemins spécifiés
    try {
        & $wimlib extract $mainEsd.FullName $idx `
            "Windows\System32\$dllName" `
            "Windows\SysWOW64\$dllName" `
            "Windows\WinSxS\*\$dllName" `
            --dest-dir="$extractDir" --no-acls --nullglob 2>&1 | Out-Null
    } catch {
        # On absorbe silencieusement les erreurs de processus ici
    }

    if (Test-Path $dllPath) {
        Write-Host " ✅ Trouvée via wimlib (image $idx)" -ForegroundColor Green
        $found = $true
        break
    }
}

# ---------------------------------------------------------------------------
# FALLBACK : 7‑ZIP
# ---------------------------------------------------------------------------
if (-not $found) {
    Write-Host "Fallback 7‑Zip..." -ForegroundColor Yellow
    $tempEsdDir = Join-Path $extractDir "esd_main"
    New-Item -ItemType Directory -Path $tempEsdDir -Force | Out-Null
    try { & $sevenZip x $mainEsd.FullName -o"$tempEsdDir" -y 2>&1 | Out-Null } catch {}

    # Extraire sous-archives (WIM/CAB/ESD)
    $subArchives = Get-ChildItem -Path $tempEsdDir -Recurse -File | Where-Object { $_.Extension -match '\.(wim|cab|esd)$' }
    foreach ($sub in $subArchives) {
        $subDir = Join-Path $tempEsdDir "sub_$($sub.BaseName)"
        New-Item -ItemType Directory -Path $subDir -Force | Out-Null
        try { & $sevenZip x $sub.FullName -o"$subDir" -y 2>&1 | Out-Null } catch {}
    }

    $foundDll = Get-ChildItem -Path $tempEsdDir -Recurse -File -Filter $dllName -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($foundDll) {
        Copy-Item -Path $foundDll.FullName -Destination $dllPath -Force
        Write-Host " ✅ Trouvée via 7‑Zip fallback" -ForegroundColor Green
        $found = $true
    }
}

# ---------------------------------------------------------------------------
# FALLBACK : CAB
# ---------------------------------------------------------------------------
if (-not $found) {
    Write-Host "Fallback CAB..." -ForegroundColor Yellow
    $cabs = Get-ChildItem -Path $uupDir -File -Filter "*.cab"
    foreach ($cab in $cabs) {
        & "$env:SystemRoot\System32\expand.exe" "$($cab.FullName)" -F:$dllName "$extractDir" 2>$null | Out-Null
        if (Test-Path $dllPath) {
            Write-Host " ✅ Trouvée dans $($cab.Name)" -ForegroundColor Green
            $found = $true
            break
        }
    }
}

if (-not $found) {
    Write-Error "DLL '$dllName' non trouvée."
    Write-Host "Fichiers UUP : $uupDir" -ForegroundColor Yellow
    Write-Host "Extraction : $extractDir" -ForegroundColor Yellow
    exit 1
}

# ---------------------------------------------------------------------------
# VÉRIFICATION + INSTALLATION
# ---------------------------------------------------------------------------
Write-Host "`nVérification signature..." -ForegroundColor Cyan
$sig = Get-AuthenticodeSignature $dllPath
if ($sig.Status -eq "Valid" -and $sig.SignerCertificate.Subject -match "Microsoft") {
    Write-Host "✅ Signature Microsoft valide" -ForegroundColor Green
} else {
    Write-Warning "Signature : $($sig.Status)"
}

$hash = (Get-FileHash $dllPath -Algorithm SHA256).Hash
Write-Host " SHA256 : $hash" -ForegroundColor Gray

Write-Host "`nInstallation..." -ForegroundColor Cyan
if (Test-Path $TargetFolder) {
    $destPath = Join-Path $TargetFolder $dllName
    Copy-Item -Path $dllPath -Destination $TargetFolder -Force
    Write-Host "✅ DLL installée : $destPath" -ForegroundColor Green
} else {
    Write-Warning "Dossier Adobe non trouvé : $TargetFolder"
    Write-Host " DLL dispo ici : $dllPath" -ForegroundColor Yellow
    $Cleanup = $false
}

# ---------------------------------------------------------------------------
# NETTOYAGE
# ---------------------------------------------------------------------------
if ($Cleanup) {
    Write-Host "`nNettoyage..." -ForegroundColor Gray
    Remove-Item $ariaFile   -Force -ErrorAction SilentlyContinue
    Remove-Item $uupDir     -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "`n=== TERMINÉ AVEC SUCCÈS ===" -ForegroundColor Magenta
Write-Host "Redémarrez Adobe Reader pour tester !" -ForegroundColor Cyan
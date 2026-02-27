# =============================================================================
# uup-extract-dll.ps1 - V5.7 (Février 2026 - Support CAB + ESD)
# Fix automatique pour Adobe Reader sur Windows 7
# =============================================================================
[CmdletBinding()]
param(
    [string]$UupId = "f8aba250-e2aa-4a80-bc91-fb471f135948",
    [string]$Search = "19045 x86",
    [string]$Arch = "x86",
    [switch]$DryRun = $false,
    [switch]$Cleanup = $true,
    [string]$TargetFolder = "$env:ProgramFiles (x86)\Adobe\Acrobat Reader DC\Reader"
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$siteBase = "https://uupdump.net"
$dllName = "api-ms-win-core-winrt-l1-1-0.dll"

Write-Host "`n=== UUP Dump V5.7 - Fix Adobe Reader WinRT (x86) ===" -ForegroundColor Cyan
Write-Host "DLL cible : $dllName" -ForegroundColor Gray
Write-Host "ID UUP : $UupId (Architecture: $Arch)" -ForegroundColor Green

$aria2Url = "$siteBase/get.php?id=$UupId&pack=en-us&edition=core&aria2=1"
Write-Host "URL source : $aria2Url" -ForegroundColor Gray

if ($DryRun) {
    Write-Host "`n[DRY-RUN] Prêt. Relancez sans -DryRun." -ForegroundColor Green
    exit 0
}

# =============================================================================
# VÉRIFICATION OUTILS (aria2 + 7-Zip)
# =============================================================================
$aria2 = Join-Path $env:ProgramData "chocolatey\bin\aria2c.exe"
$sevenZip = Join-Path $env:ProgramData "chocolatey\bin\7z.exe"

if (-not (Test-Path $aria2)) {
    Write-Host "Installation aria2..." -ForegroundColor Yellow
    choco install aria2 -y --no-progress | Out-Null
}

if (-not (Test-Path $sevenZip)) {
    Write-Host "Installation 7-Zip (requis pour fichiers ESD)..." -ForegroundColor Yellow
    choco install 7zip -y --no-progress | Out-Null
    $sevenZip = "C:\Program Files\7-Zip\7z.exe"
    if (-not (Test-Path $sevenZip)) {
        $sevenZip = Join-Path $env:ProgramData "chocolatey\bin\7z.exe"
    }
}

if (-not (Test-Path $sevenZip)) {
    Write-Error "7-Zip introuvable. Installez-le manuellement."
    exit 1
}

Write-Host "7-Zip : $sevenZip" -ForegroundColor Gray

# =============================================================================
# PRÉPARATION
# =============================================================================
$ariaFile = Join-Path $env:TEMP "uup_$UupId.aria2.txt"
$uupDir = Join-Path $env:TEMP "UUPs_$UupId"
$extractDir = Join-Path $env:TEMP "UUP_extract_$UupId"

Remove-Item $uupDir -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $uupDir -Force | Out-Null
New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

# =============================================================================
# TÉLÉCHARGEMENT
# =============================================================================
Write-Host "`nTéléchargement de la liste..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $aria2Url -OutFile $ariaFile -UseBasicParsing -UserAgent $UserAgent -TimeoutSec 120

Write-Host "Téléchargement des fichiers (peut prendre 1-2 min)..." -ForegroundColor Cyan
& $aria2 -i $ariaFile -d $uupDir --continue=true --max-connection-per-server=8 --split=8 --min-split-size=1M --console-log-level=notice --summary-interval=10 "--user-agent=$UserAgent"

if ($LASTEXITCODE -ne 0) {
    Write-Error "aria2 a échoué (code $LASTEXITCODE)"
    exit 1
}
Write-Host "Téléchargement terminé." -ForegroundColor Green

# =============================================================================
# EXTRACTION - PHASE 1 : CAB (avec expand)
# =============================================================================
Write-Host "`nRecherche dans les fichiers CAB..." -ForegroundColor Cyan
$dllPath = Join-Path $extractDir $dllName
$found = $false

$cabs = Get-ChildItem -Path $uupDir -File -Filter "*.cab"
foreach ($cab in $cabs) {
    $null = cmd /c "expand `"$($cab.FullName)`" -F:$dllName `"$extractDir`" 2>&1"
    if (Test-Path $dllPath) {
        Write-Host " -> Trouvée dans CAB : $($cab.Name)" -ForegroundColor Green
        $found = $true
        break
    }
}

# =============================================================================
# EXTRACTION - PHASE 2 : ESD (avec 7-Zip)
# =============================================================================
if (-not $found) {
    Write-Host "Non trouvée dans CAB. Recherche dans les fichiers ESD..." -ForegroundColor Yellow
    
    $esds = Get-ChildItem -Path $uupDir -File -Filter "*.esd"
    Write-Host " $($esds.Count) fichiers ESD à analyser..." -ForegroundColor Gray
    
    foreach ($esd in $esds) {
        Write-Host " Analyse : $($esd.Name)..." -ForegroundColor Gray
        
        # Extraire avec 7-Zip en cherchant récursivement la DLL
        $tempEsdDir = Join-Path $extractDir "esd_temp_$($esd.BaseName)"
        New-Item -ItemType Directory -Path $tempEsdDir -Force | Out-Null
        
        # 7z extrait récursivement
        & $sevenZip x $esd.FullName -o"$tempEsdDir" -r -y $dllName 2>&1 | Out-Null
        
        # Chercher la DLL extraite (peut être dans un sous-dossier)
        $foundDll = Get-ChildItem -Path $tempEsdDir -Recurse -File -Filter $dllName -ErrorAction SilentlyContinue | Select-Object -First 1
        
        if ($foundDll) {
            Copy-Item -Path $foundDll.FullName -Destination $dllPath -Force
            Write-Host " -> Trouvée dans ESD : $($esd.Name)" -ForegroundColor Green
            $found = $true
            break
        }
        
        # Nettoyage temp
        Remove-Item $tempEsdDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if (-not $found) {
    Write-Error "DLL '$dllName' non trouvée dans CAB ni ESD."
    Write-Host "Fichiers disponibles dans : $uupDir" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# VÉRIFICATION SIGNATURE
# =============================================================================
Write-Host "`nVérification signature..." -ForegroundColor Cyan
$sig = Get-AuthenticodeSignature $dllPath
if ($sig.Status -eq "Valid" -and $sig.SignerCertificate.Subject -match "Microsoft") {
    Write-Host "✅ Signature Microsoft valide" -ForegroundColor Green
} else {
    Write-Warning "Signature : $($sig.Status)"
}

$hash = (Get-FileHash $dllPath -Algorithm SHA256).Hash
Write-Host " SHA256 : $hash" -ForegroundColor Gray

# =============================================================================
# INSTALLATION
# =============================================================================
Write-Host "`nInstallation..." -ForegroundColor Cyan
if (Test-Path $TargetFolder) {
    $destPath = Join-Path $TargetFolder $dllName
    if (Test-Path $destPath) {
        $backupPath = "$destPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item -Path $destPath -Destination $backupPath -Force
        Write-Host " Backup : $backupPath" -ForegroundColor Gray
    }
    Copy-Item -Path $dllPath -Destination $TargetFolder -Force
    Write-Host "✅ DLL installée : $destPath" -ForegroundColor Green
} else {
    Write-Warning "Dossier Adobe non trouvé : $TargetFolder"
    Write-Host " DLL dispo ici : $dllPath" -ForegroundColor Yellow
    $Cleanup = $false
}

# =============================================================================
# NETTOYAGE
# =============================================================================
if ($Cleanup) {
    Write-Host "`nNettoyage..." -ForegroundColor Gray
    Remove-Item $ariaFile -Force -ErrorAction SilentlyContinue
    Remove-Item $uupDir -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "`n=== TERMINÉ AVEC SUCCÈS ===" -ForegroundColor Magenta
Write-Host "Redémarrez Adobe Reader pour tester !" -ForegroundColor Cyan
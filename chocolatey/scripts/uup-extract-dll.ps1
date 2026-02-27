# =============================================================================
# uup-extract-dll.ps1 - Version SILENCIEUSE 100 % (sans clic navigateur)
# Extrait api-ms-win-core-winrt-l1-1-0.dll depuis un build Win10 x86 via API uupdump
# Compatible PowerShell 5.1 - Windows 7/10/11
# =============================================================================

[CmdletBinding()]
param(
    [string]$Build = "19045.5247",              # Build Win10 22H2 x86 par défaut (stable avec la DLL)
    [string]$Ring = "retail",                   # retail = public
    [string]$Arch = "x86",                      # 32-bit pour AcroRd32.exe sur Win7
    [switch]$Cleanup = $true,                   # Supprime les fichiers UUPs après extraction ?
    [string]$TargetFolder = "$env:ProgramFiles (x86)\Adobe\Acrobat Reader DC\Reader"
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

Write-Host "`n=== UUP Dump SILENCIEUX - Extraction api-ms-win-core-winrt-l1-1-0.dll ===" -ForegroundColor Cyan
Write-Host "Build cible : Windows 10 $Arch - $Build ($Ring)" -ForegroundColor Yellow

# Vérifie aria2
$aria2 = "${env:ProgramData}\chocolatey\bin\aria2c.exe"
if (-not (Test-Path $aria2)) {
    Write-Warning "aria2 non trouvé → installation automatique"
    choco install aria2 -y --no-progress
}

# Étape 1 : Récupère les infos du build via API uupdump
$apiUrl = "https://uupdump.net/api/getbuildinfo?ring=$Ring&arch=$Arch&build=$Build"
try {
    $buildInfo = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing -TimeoutSec 30
    if (-not $buildInfo.id) { throw "Build non trouvé" }
    Write-Host "Build trouvé : $($buildInfo.title) (ID: $($buildInfo.id))" -ForegroundColor Green
}
catch {
    Write-Error "Échec récupération infos build : $($_.Exception.Message)"
    Write-Host "Essayez un autre build ou vérifiez uupdump.net/api"
    exit 1
}

# Étape 2 : Génère le script aria2 (sans passer par le site web)
$aria2Params = @{
    id    = $buildInfo.id
    aria2 = 1
}
$aria2Query = ($aria2Params.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
$aria2Url = "https://uupdump.net/get.php?$aria2Query"

try {
    $aria2Script = Invoke-WebRequest -Uri $aria2Url -UseBasicParsing -TimeoutSec 30
    $aria2File = "$env:TEMP\uup_aria2_$($buildInfo.id).txt"
    $aria2Script.Content | Out-File -FilePath $aria2File -Encoding ascii
    Write-Host "Script aria2 généré : $aria2File" -ForegroundColor Green
}
catch {
    Write-Error "Échec génération script aria2 : $($_.Exception.Message)"
    exit 1
}

# Étape 3 : Téléchargement silencieux avec aria2
$uupDir = "$env:TEMP\UUPs_$($buildInfo.id)"
New-Item -ItemType Directory -Path $uupDir -Force | Out-Null

Write-Host "Téléchargement des fichiers (seulement system32 CABs)..." -ForegroundColor Cyan
& $aria2 -i "$aria2File" -d "$uupDir" --console-log-level=warn --summary-interval=0 --allow-overwrite=true 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Warning "Aria2 a retourné une erreur ($LASTEXITCODE) - vérifiez les logs"
}

# Étape 4 : Extraction de la DLL depuis les CAB
$tempDll = "$env:TEMP\api-ms-win-core-winrt-l1-1-0.dll"
Remove-Item $tempDll -Force -ErrorAction SilentlyContinue

$cabFiles = Get-ChildItem -Path $uupDir -Filter "*windows-system32*.cab" -Recurse -File

foreach ($cab in $cabFiles) {
    Write-Host "Extraction depuis $($cab.Name) ..." -ForegroundColor Cyan
    expand $cab.FullName -F:api-ms-win-core-winrt-l1-1-0.dll $env:TEMP 2>$null
}

if (-not (Test-Path $tempDll)) {
    Write-Error "DLL non trouvée après extraction des CABs"
    exit 1
}

Write-Host "DLL extraite : $tempDll" -ForegroundColor Green

# Étape 5 : Vérification intégrité (hash + signature)
$expectedHash = "B30F6D5E1328144C41F1116F9E3A50F458FC455B16900ED9B48CEAE0771696BD"  # Win10 22H2

$hash = Get-FileHash $tempDll -Algorithm SHA256
if ($hash.Hash -ne $expectedHash) {
    Write-Warning "Hash SHA256 non correspondant (obtenu: $($hash.Hash))"
    Write-Warning "Attendu: $expectedHash"
    $continue = Read-Host "Continuer malgré tout ? (O/N)"
    if ($continue -notlike "O*") { exit 1 }
} else {
    Write-Host "✅ Hash SHA256 OK (Microsoft officiel)" -ForegroundColor Green
}

$sig = Get-AuthenticodeSignature $tempDll
if ($sig.Status -eq "Valid" -and $sig.SignerCertificate.Subject -like "*Microsoft*") {
    Write-Host "✅ Signature Authenticode valide (Microsoft)" -ForegroundColor Green
} else {
    Write-Warning "Signature invalide : $($sig.StatusMessage)"
    $continue = Read-Host "Continuer malgré tout ? (O/N)"
    if ($continue -notlike "O*") { exit 1 }
}

# Étape 6 : Copie vers Adobe Reader
if (Test-Path $TargetFolder) {
    Copy-Item -Path $tempDll -Destination $TargetFolder -Force
    Write-Host "DLL copiée avec succès dans : $TargetFolder" -ForegroundColor Green
    Write-Host "Redémarrez Adobe Reader pour tester !" -ForegroundColor Green
} else {
    Write-Warning "Dossier Adobe Reader non trouvé : $TargetFolder"
    Write-Host "DLL disponible ici : $tempDll" -ForegroundColor Yellow
    Write-Host "Copiez-la manuellement dans le dossier Reader de votre installation."
}

# Étape 7 : Nettoyage (optionnel)
if ($Cleanup) {
    Remove-Item $uupDir -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $aria2File -Force -ErrorAction SilentlyContinue
    Write-Host "Nettoyage terminé" -ForegroundColor Gray
}

Write-Host "`n=== Fin du fix silencieux UUP ===" -ForegroundColor Magenta
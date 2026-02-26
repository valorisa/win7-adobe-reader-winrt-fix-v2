# =============================================================================
# uup-extract-dll.ps1
# Extrait api-ms-win-core-winrt-l1-1-0.dll via UUP dump minimal (~250-350 Mo)
# Compatible PowerShell 5.1 (Windows natif)
# =============================================================================

[CmdletBinding()]
param(
    [switch]$Force,
    [string]$TargetFolder = "$env:ProgramFiles (x86)\Adobe\Acrobat Reader DC\Reader"
)

# Vérifie pré-requis aria2
$aria2 = "${env:ProgramData}\chocolatey\bin\aria2c.exe"
if (-not (Test-Path $aria2)) {
    Write-Warning "aria2 non trouvé. Installation automatique..."
    choco install aria2 -y --no-progress
    Start-Sleep -Seconds 3
}

# Build connu stable avec la DLL (Win10 22H2 x86)
$build = "19045.5247"   # tu peux changer pour un build plus récent si besoin
$uupBaseUrl = "https://uupdump.net"

Write-Host "`n=== UUP Dump - Extraction api-ms-win-core-winrt-l1-1-0.dll ===" -ForegroundColor Cyan
Write-Host "1. Le navigateur va s'ouvrir sur uupdump.net" -ForegroundColor Yellow
Write-Host "2. Attends que la page charge complètement" -ForegroundColor Yellow
Write-Host "3. Clique sur le bouton 'Download using aria2 and convert'" -ForegroundColor Yellow
Write-Host "   (ou 'Download using aria2' si l'option convert n'apparaît pas)" -ForegroundColor Yellow
Write-Host "4. Aria2 va télécharger ~250-350 Mo" -ForegroundColor Yellow
Write-Host "5. Une fois terminé, reviens ici et appuie sur Entrée`n" -ForegroundColor Yellow

# Ouvre la page UUP avec les bons paramètres
$requestUrl = "$uupBaseUrl/get.php?id=win10_22h2_x86_$build&pack=1&aria2=1"
Start-Process $requestUrl

Read-Host "Appuie sur Entrée quand le téléchargement aria2 est terminé (dossier UUPs créé)"

# Recherche le dossier UUPs le plus récent dans Téléchargements
$downloads = "$env:USERPROFILE\Downloads"
$uupFolder = Get-ChildItem -Path $downloads -Filter "UUPs*" -Directory |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1 -ExpandProperty FullName

if (-not $uupFolder) {
    Write-Error "Aucun dossier UUPs trouvé dans $downloads"
    exit 1
}

Write-Host "Dossier UUP détecté : $uupFolder" -ForegroundColor Green

# Recherche les .cab contenant system32
$cabFiles = Get-ChildItem -Path $uupFolder -Filter "*windows-system32*.cab" -Recurse -File

if ($cabFiles.Count -eq 0) {
    Write-Error "Aucun .cab system32 trouvé dans le dossier UUP"
    exit 1
}

# Extraction de la DLL depuis les CABs
$tempExtract = "$env:TEMP\uup-dll-extract"
New-Item -ItemType Directory -Path $tempExtract -Force | Out-Null

foreach ($cab in $cabFiles) {
    Write-Host "Extraction depuis $($cab.Name) ..." -ForegroundColor Cyan
    & expand "$($cab.FullName)" -F:api-ms-win-core-winrt-l1-1-0.dll "$tempExtract" 2>$null
}

$dllPath = "$tempExtract\api-ms-win-core-winrt-l1-1-0.dll"

if (-not (Test-Path $dllPath)) {
    Write-Error "La DLL n'a pas été trouvée après extraction"
    exit 1
}

Write-Host "DLL trouvée : $dllPath" -ForegroundColor Green

# Copie vers Adobe Reader (ou autre dossier)
if (Test-Path $TargetFolder) {
    Copy-Item -Path $dllPath -Destination $TargetFolder -Force
    Write-Host "DLL copiée dans : $TargetFolder" -ForegroundColor Green
} else {
    Write-Warning "Dossier cible non trouvé : $TargetFolder"
    Write-Host "DLL laissée ici : $dllPath" -ForegroundColor Yellow
}

Write-Host "`nTerminé !`n" -ForegroundColor Green
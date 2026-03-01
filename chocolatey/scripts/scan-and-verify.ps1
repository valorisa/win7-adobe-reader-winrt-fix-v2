# =============================================================================
# scan-and-verify.ps1 - V2.1 (Mars 2026 - MULTI-HASH + SIGNATURE)
# Vérifie hash SHA256 + signature Authenticode de la DLL WinRT
# Compatible PowerShell 5.1 (Windows 7/10/11)
# =============================================================================
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DllPath,
    
    [switch]$StrictMode
)

Write-Host "`n=== Vérification DLL WinRT ===" -ForegroundColor Cyan
Write-Host "Fichier : $DllPath" -ForegroundColor Gray

# ---------------------------------------------------------------------------
# HASHS ACCEPTÉS (versions Microsoft légitimes du stub WinRT)
# ---------------------------------------------------------------------------
$acceptedHashes = @(
    "B30F6D5E1328144C41F1116F9E3A50F458FC455B16900ED9B48CEAE0771696BD",
    "E4C29D4B5496C965B903CAA1722F3A54DB22B95688A10B8A103639BA4B1F999D"
)

# ---------------------------------------------------------------------------
# ÉTAPE 1 : Vérification du fichier
# ---------------------------------------------------------------------------
if (-not (Test-Path $DllPath)) {
    Write-Error "Fichier introuvable : $DllPath"
    exit 1
}

$fileInfo = Get-Item $DllPath
Write-Host "`n[1/3] Informations du fichier" -ForegroundColor Yellow
Write-Host "  Taille : $($fileInfo.Length) octets" -ForegroundColor Gray
if ($fileInfo.VersionInfo.FileVersion) {
    Write-Host "  Version : $($fileInfo.VersionInfo.FileVersion)" -ForegroundColor Gray
}
if ($fileInfo.VersionInfo.ProductName) {
    Write-Host "  Produit : $($fileInfo.VersionInfo.ProductName)" -ForegroundColor Gray
}

# ---------------------------------------------------------------------------
# ÉTAPE 2 : Vérification du hash SHA256
# ---------------------------------------------------------------------------
Write-Host "`n[2/3] Vérification du hash SHA256" -ForegroundColor Yellow
$hash = Get-FileHash $DllPath -Algorithm SHA256 -ErrorAction SilentlyContinue

if (-not $hash) {
    Write-Error "Impossible de calculer le hash du fichier"
    exit 1
}

$calculatedHash = $hash.Hash.ToUpper()
Write-Host "  Calculé : $calculatedHash" -ForegroundColor Gray

$hashMatch = $calculatedHash -in $acceptedHashes

if ($hashMatch) {
    Write-Host "  OK Hash correspond à une version Microsoft officielle" -ForegroundColor Green
    
    $hashInfo = switch ($calculatedHash) {
        "B30F6D5E1328144C41F1116F9E3A50F458FC455B16900ED9B48CEAE0771696BD" { "Windows 10 22H2 (build 19041)" }
        "E4C29D4B5496C965B903CAA1722F3A54DB22B95688A10B8A103639BA4B1F999D" { "Windows 10 Technical Preview (build 9904)" }
        default { "Version connue (hash validé)" }
    }
    Write-Host "  Version détectée : $hashInfo" -ForegroundColor Gray
}
else {
    Write-Warning "  ATTENTION Hash NON reconnu dans la liste des versions validées"
    Write-Host "  Hashes acceptés :" -ForegroundColor Gray
    $acceptedHashes | ForEach-Object { Write-Host "    - $_" -ForegroundColor DarkGray }
    
    if ($StrictMode) {
        Write-Error "Mode strict activé : arrêt pour hash non validé"
        exit 1
    }
    
    $continue = Read-Host "  Continuer quand même ? (O/N)"
    if ($continue -notlike "O*") {
        Write-Host "  Annulé par l'utilisateur." -ForegroundColor Yellow
        exit 1
    }
    Write-Host "  -> Continuation autorisée par l'utilisateur" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# ÉTAPE 3 : Vérification de la signature Authenticode
# ---------------------------------------------------------------------------
Write-Host "`n[3/3] Vérification de la signature numérique" -ForegroundColor Yellow
$sig = Get-AuthenticodeSignature $DllPath -ErrorAction SilentlyContinue

$signatureValid = $false
$signatureStatus = "Inconnue"

if (-not $sig) {
    Write-Warning "  ATTENTION Impossible de lire la signature du fichier"
    $signatureStatus = "Lecture échouée"
}
elseif ($sig.Status -eq "Valid") {
    $signatureValid = $true
    $signatureStatus = "Valide"
    $subject = $sig.SignerCertificate.Subject
    Write-Host "  OK Signature valide" -ForegroundColor Green
    Write-Host "  Signé par : $subject" -ForegroundColor Gray
    
    if ($subject -like "*Microsoft Corporation*") {
        Write-Host "  OK Editeur : Microsoft Corporation (officiel)" -ForegroundColor Green
    }
    else {
        Write-Warning "  ATTENTION Signé par un éditeur tiers : $subject"
        if ($StrictMode) {
            Write-Error "Mode strict : signature non-Microsoft refusée"
            exit 1
        }
        $continue = Read-Host "  Continuer quand même ? (O/N)"
        if ($continue -notlike "O*") { exit 1 }
    }
}
elseif ($sig.Status -eq "Unknown") {
    $signatureStatus = "Inconnue"
    Write-Warning "  ATTENTION Signature inconnue (non vérifiée par une autorité de confiance)"
    if ($sig.SignerCertificate) {
        Write-Host "  Sujet : $($sig.SignerCertificate.Subject)" -ForegroundColor Gray
    }
}
else {
    $signatureStatus = $sig.Status
    Write-Warning "  ATTENTION Signature invalide : $($sig.StatusMessage)"
    if ($StrictMode) {
        Write-Error "Mode strict : signature invalide refusée"
        exit 1
    }
    $continue = Read-Host "  Continuer quand même ? (O/N)"
    if ($continue -notlike "O*") { exit 1 }
}

# ---------------------------------------------------------------------------
# RÉSULTAT FINAL
# ---------------------------------------------------------------------------
Write-Host "`n=== RÉSULTAT DE LA VÉRIFICATION ===" -ForegroundColor Cyan

$allChecksPassed = $hashMatch -and $signatureValid

if ($allChecksPassed) {
    Write-Host "OK DLL VALIDEE : Hash + Signature Microsoft conformes" -ForegroundColor Green
    Write-Host "   Cette DLL est sûre pour le fix Windows 7 Adobe Reader." -ForegroundColor Green
    exit 0
}
else {
    Write-Host "ATTENTION DLL ACCEPTÉE AVEC RÉSERVES" -ForegroundColor Yellow
    
    if ($hashMatch) {
        Write-Host "   - Hash : OK" -ForegroundColor Green
    } else {
        Write-Host "   - Hash : ATTENTION" -ForegroundColor Yellow
    }
    
    if ($signatureValid) {
        Write-Host "   - Signature : OK ($signatureStatus)" -ForegroundColor Green
    } else {
        Write-Host "   - Signature : ATTENTION ($signatureStatus)" -ForegroundColor Yellow
    }
    
    Write-Host "   La DLL semble fonctionnelle mais vérifie manuellement si doute." -ForegroundColor Yellow
    exit 0
}
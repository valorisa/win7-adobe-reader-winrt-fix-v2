# =============================================================================
# main-fix.ps1
# Orchestrateur principal du fix Adobe Reader Win7 (V2)
# Compatible PowerShell 5.1
# Lance les étapes dans l'ordre : extraction DLL → vérif → choix action
# =============================================================================

Write-Host "`n=== Win7 Adobe Reader WinRT Fix - V2 (Full Auto) ===" -ForegroundColor Cyan
Write-Host "Date : $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
Write-Host "Objectif : réparer api-ms-win-core-winrt-l1-1-0.dll manquante`n" -ForegroundColor Yellow

# Vérifie si on est admin (recommandé pour copie dans Program Files)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Script recommandé en mode Administrateur pour copier la DLL dans le dossier Adobe."
    Write-Host "Tu peux continuer, mais la copie finale risque d'échouer.`n" -ForegroundColor Yellow
}

# Étape 1 : Extraction silencieuse DLL via UUP
Write-Host "Étape 1 : Extraction silencieuse DLL via UUP..." -ForegroundColor Cyan
& ".\scripts\uup-extract-dll.ps1" -Cleanup $true

$dllTempPath = "$env:TEMP\uup-dll-extract\api-ms-win-core-winrt-l1-1-0.dll"
if (-not (Test-Path $dllTempPath)) {
    Write-Error "Échec extraction DLL. Arrêt."
    exit 1
}

# Étape 2 : Vérification hash + signature
Write-Host "`nÉtape 2/3 : Vérification de l'intégrité de la DLL" -ForegroundColor Cyan
& ".\scripts\scan-and-verify.ps1" -DllPath $dllTempPath

# (le script scan-and-verify.ps1 doit afficher ✅ si OK, sinon il sort)

# Étape 3 : Choix de l'action
Write-Host "`nÉtape 3/3 : Que veux-tu faire ?" -ForegroundColor Cyan
Write-Host "1 = Copier la DLL dans le dossier Adobe Reader (recommandé)" -ForegroundColor Green
Write-Host "2 = Rollback complet vers Adobe Reader XI 11.0.23" -ForegroundColor Yellow
Write-Host "Q = Quitter`n"

$choice = Read-Host "Ton choix (1/2/Q)"

switch ($choice.ToUpper()) {
    "1" {
        $target = "$env:ProgramFiles (x86)\Adobe\Acrobat Reader DC\Reader"
        if (Test-Path $target) {
            Copy-Item -Path $dllTempPath -Destination $target -Force
            Write-Host "`nDLL copiée avec succès dans : $target" -ForegroundColor Green
            Write-Host "Redémarre Adobe Reader pour tester.`n" -ForegroundColor Green
        } else {
            Write-Warning "Dossier Adobe Reader non trouvé : $target"
            Write-Host "Copie manuelle nécessaire : $dllTempPath → dossier Reader" -ForegroundColor Yellow
        }
    }
    "2" {
        Write-Host "Lancement du rollback vers Reader XI..." -ForegroundColor Yellow
        & ".\scripts\rollback-reader-xi.ps1"
    }
    "Q" { Write-Host "Au revoir !" -ForegroundColor Gray; exit 0 }
    default { Write-Host "Choix invalide. Fin." -ForegroundColor Red }
}

Write-Host "`nOpération terminée. Merci d'avoir utilisé le fix V2 ! 😈🚀" -ForegroundColor Magenta
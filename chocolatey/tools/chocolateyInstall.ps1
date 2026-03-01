$ErrorActionPreference = 'Continue'
$packageName   = 'win7-adobe-fix'
$toolsDir      = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$installPath   = "$env:ProgramData\$packageName"
$installParams = $env:chocolateyPackageParameters

Write-Host "`n=== Installation de $packageName - V2.0.1 ===" -ForegroundColor Cyan
Write-Host "toolsDir : $toolsDir" -ForegroundColor Gray
Write-Host "installPath : $installPath" -ForegroundColor Gray

try {
    # Création du dossier persistant
    Write-Host "`nCréation du dossier : $installPath" -ForegroundColor Gray
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    
    # Résolution du chemin source (plus robuste)
    $scriptsSource = Resolve-Path "$toolsDir\..\scripts" -ErrorAction SilentlyContinue
    if (-not $scriptsSource) {
        $scriptsSource = "$toolsDir\..\scripts"
    }
    Write-Host "Source scripts : $scriptsSource" -ForegroundColor Gray
    
    if (-not (Test-Path $scriptsSource)) {
        Write-Error "Dossier scripts introuvable : $scriptsSource"
        Write-Host "Contenu de toolsDir :" -ForegroundColor Yellow
        Get-ChildItem $toolsDir | ForEach-Object { Write-Host "  - $($_.Name)" }
        exit 1
    }
    
    # Copie robuste avec robocopy (plus fiable que Copy-Item pour les récursions)
    Write-Host "`nCopie des scripts via robocopy..." -ForegroundColor Gray
    $robocopyArgs = @(
        "`"$scriptsSource`"",      # Source
        "`"$installPath`"",        # Destination
        "/E",                      # Copie récursive (sous-dossiers inclus)
        "/NFL", "/NDL",            # Pas de liste de fichiers/dossiers (moins de bruit)
        "/NJH", "/NJS",            # Pas d'en-tête/statistiques
        "/NC", "/NS", "/NP",       # Pas de couleurs, tailles, progression
        "/XX",                     # Exclure les fichiers extra (sécurité)
        "/R:1", "/W:1"             # 1 retry, 1 sec wait (rapide en cas d'erreur)
    )
    
    $robocopyResult = Start-Process -FilePath "robocopy.exe" -ArgumentList $robocopyArgs `
        -Wait -NoNewWindow -PassThru
    
    # robocopy retourne des codes spécifiques : 0-7 = succès, 8+ = erreur
    if ($robocopyResult.ExitCode -ge 8) {
        Write-Error "Échec robocopy (code $($robocopyResult.ExitCode))"
        exit 1
    }
    
    # Vérification critique : uup-extract-dll.ps1 DOIT être présent
    if (-not (Test-Path "$installPath\uup-extract-dll.ps1")) {
        Write-Error "Échec critique : uup-extract-dll.ps1 non copié"
        Write-Host "Contenu de installPath :" -ForegroundColor Yellow
        Get-ChildItem $installPath -Recurse | ForEach-Object { Write-Host "  - $($_.Name)" }
        exit 1
    }
    
    Write-Host "`n✅ Scripts copiés avec succès :" -ForegroundColor Green
    Get-ChildItem $installPath | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
    
    # Vérifie que le dossier offline est présent (nouveau en V2.0.1)
    if (Test-Path "$installPath\offline") {
        Write-Host "  + offline/ (mode offline activé)" -ForegroundColor Gray
    }
    
    # Détection du paramètre
    Write-Host "`nParamètres détectés : $installParams" -ForegroundColor Gray
    
    if ($installParams -match '/RollbackXI') {
        Write-Host "`nMode : Rollback vers Adobe Reader XI" -ForegroundColor Yellow
        & "$installPath\rollback-reader-xi.ps1"
    }
    elseif ($installParams -match '/ForceOffline') {
        Write-Host "`nMode : Offline (DLL pré-vérifiée)" -ForegroundColor Cyan
        & "$installPath\uup-extract-dll.ps1" -ForceOffline -Cleanup $true
    }
    else {
        Write-Host "`nMode : Copie DLL silencieuse (défaut)" -ForegroundColor Green
        & "$installPath\uup-extract-dll.ps1" -Cleanup $true
    }
    
    Write-Host "`n=== Installation terminée avec succès ! ===" -ForegroundColor Green
    Write-Host "Pour relancer manuellement : $installPath\main-fix.ps1" -ForegroundColor Cyan
}
catch {
    Write-Error "Erreur lors de l'installation : $_"
    Write-Host "Stack trace : $($_.ScriptStackTrace)" -ForegroundColor Red
    exit 1
}
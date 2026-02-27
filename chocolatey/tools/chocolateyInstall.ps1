$ErrorActionPreference = 'Stop'

$packageName   = 'win7-adobe-fix'
$toolsDir      = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$installPath   = "$env:ProgramData\$packageName"
$installParams = $env:chocolateyPackageParameters

Write-Host "Installation de $packageName - V2.0.1 (silencieux)" -ForegroundColor Cyan

# Création du dossier persistant
New-Item -ItemType Directory -Path $installPath -Force | Out-Null

# Copie des scripts (maintenant inclus dans le package)
Copy-Item -Path "$toolsDir\..\scripts\*" -Destination $installPath -Recurse -Force

# Détection du paramètre
if ($installParams -match '/RollbackXI') {
    Write-Host "Mode : Rollback vers Adobe Reader XI" -ForegroundColor Yellow
    & "$installPath\rollback-reader-xi.ps1"
}
else {
    Write-Host "Mode : Copie DLL silencieuse (défaut)" -ForegroundColor Green
    & "$installPath\uup-extract-dll.ps1" -Cleanup $true
}

Write-Host "`nInstallation terminée avec succès !" -ForegroundColor Green
Write-Host "Pour relancer manuellement : $installPath\main-fix.ps1" -ForegroundColor Cyan
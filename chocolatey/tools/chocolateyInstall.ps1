$ErrorActionPreference = 'Stop'

$packageName   = 'win7-adobe-fix'
$toolsDir      = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$installParams = $env:chocolateyPackageParameters

Write-Host "Installation de $packageName - V2" -ForegroundColor Cyan

# Copie les scripts utiles dans un dossier persistant
$installPath = "$env:ProgramData\$packageName"
New-Item -ItemType Directory -Path $installPath -Force | Out-Null

Copy-Item -Path "$toolsDir\..\scripts\*" -Destination $installPath -Recurse -Force

# Détection paramètre /RollbackXI ou /DLLonly
if ($installParams -match '/RollbackXI') {
    Write-Host "Mode : Rollback vers Adobe Reader XI" -ForegroundColor Yellow
    & "$installPath\rollback-reader-xi.ps1"
}
else {
    Write-Host "Mode : Copie DLL uniquement (défaut)" -ForegroundColor Green
    & "$installPath\uup-extract-dll.ps1"
    # La copie finale se fait dans uup-extract-dll ou manuellement
}

Write-Host "`nInstallation Chocolatey terminée." -ForegroundColor Green
Write-Host "Pour relancer manuellement : $installPath\main-fix.ps1" -ForegroundColor Cyan
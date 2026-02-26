# =============================================================================
# rollback-reader-xi.ps1
# Désinstalle la version actuelle + installe Adobe Reader XI 11.0.23
# (dernière version stable sans dépendance WinRT sur Win7)
# =============================================================================

Write-Host "`n=== Rollback vers Adobe Reader XI 11.0.23 ===" -ForegroundColor Yellow
Write-Host "Cette opération va tenter de désinstaller la version actuelle puis installer XI"
Write-Host "Exécute en Administrateur pour meilleurs résultats`n"

$confirm = Read-Host "Confirmer le rollback ? (O/N)"
if ($confirm -notlike "O*") {
    Write-Host "Annulé." -ForegroundColor Gray
    exit 0
}

# Tentative de désinstallation silencieuse des versions DC / récentes
Write-Host "Désinstallation des versions Adobe Reader existantes..."
Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Adobe Reader*" -or $_.Name -like "*Acrobat Reader*" } |
    ForEach-Object {
        Write-Host "Désinstallation : $($_.Name)"
        $_.Uninstall() | Out-Null
    }

# Chemins classiques d'installation Reader XI
$installerUrl = "https://ardownload.adobe.com/pub/adobe/reader/win/11.x/11.0.23/en_US/AdbeRdr11023_en_US.exe"
$installerPath = "$env:TEMP\AdbeRdr11023_en_US.exe"

Write-Host "`nTéléchargement de Reader XI 11.0.23..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing

if (-not (Test-Path $installerPath)) {
    Write-Error "Échec du téléchargement de l'installateur"
    exit 1
}

# Installation silencieuse
Write-Host "Installation silencieuse en cours..." -ForegroundColor Cyan
Start-Process -FilePath $installerPath -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES DISABLEDESKTOPSHORTCUT=1" -Wait -NoNewWindow

Write-Host "`nRollback terminé !" -ForegroundColor Green
Write-Host "Lance Adobe Reader pour vérifier (Help → About devrait montrer 11.0.23)"
Write-Host "Pense à désactiver les mises à jour automatiques dans Edit → Preferences → Updater"
# 🚀 Procédure complète

```text
1. Touche Windows → tape "PowerShell"
2. Clic droit sur "Windows PowerShell"
3. "Exécuter en tant qu'administrateur"
4. Confirme l'invite UAC (Oui)
```

```powershell
cd C:\Users\bbrod\Projets\win7-adobe-reader-winrt-fix-v2

# =============================================================================
# ÉTAPE 1 : Vérifie la structure locale
# =============================================================================
Write-Host "`n=== STRUCTURE LOCALE ===" -ForegroundColor Cyan
tree /F

# =============================================================================
# ÉTAPE 2 : Vérifie les fichiers REQUIREMENTS
# =============================================================================
Write-Host "`n=== VÉRIFICATION REQUIREMENTS ===" -ForegroundColor Cyan

Test-Path ".\chocolatey\tools\LICENSE.txt"      # Doit = True
Test-Path ".\chocolatey\tools\VERIFICATION.txt" # Doit = True

# =============================================================================
# ÉTAPE 3 : Vérifie le nuspec (tags + description)
# =============================================================================
Write-Host "`n=== NUSPEC ===" -ForegroundColor Cyan
Get-Content ".\chocolatey\win7-adobe-fix.nuspec" | Select-String "<tags>"
Get-Content ".\chocolatey\win7-adobe-fix.nuspec" | Select-String "<description>"

# =============================================================================
# ÉTAPE 4 : Reconstruis le package (optionnel)
# =============================================================================
Write-Host "`n=== REBUILD PACKAGE ===" -ForegroundColor Cyan
Remove-Item ".\win7-adobe-fix.*.nupkg" -Force -ErrorAction SilentlyContinue
cd chocolatey
choco pack win7-adobe-fix.nuspec --outputdirectory ..
cd ..

# =============================================================================
# ÉTAPE 5 : Vérifie le contenu du .nupkg
# =============================================================================
Write-Host "`n=== CONTENU DU PACKAGE ===" -ForegroundColor Cyan
Copy-Item ".\win7-adobe-fix.2.0.1.nupkg" -Destination "$env:TEMP\verify.zip" -Force
Expand-Archive -Path "$env:TEMP\verify.zip" -DestinationPath "$env:TEMP\verify-nupkg" -Force

Write-Host "Fichiers dans tools/ :" -ForegroundColor Yellow
Get-ChildItem "$env:TEMP\verify-nupkg\tools" -File | Select-Object Name

Write-Host "Fichiers dans scripts/ :" -ForegroundColor Yellow
Get-ChildItem "$env:TEMP\verify-nupkg\scripts" -Recurse -File | Select-Object Name

# =============================================================================
# ÉTAPE 6 : Test d'installation locale (optionnel)
# =============================================================================
Write-Host "`n=== TEST INSTALLATION LOCALE ===" -ForegroundColor Cyan
choco install win7-adobe-fix --source . -y --force

# =============================================================================
# ÉTAPE 7 : Test de désinstallation locale (optionnel)
# =============================================================================
Write-Host "`n=== TEST DÉSINSTALLATION LOCALE ===" -ForegroundColor Cyan
choco uninstall win7-adobe-fix -y --force

# =============================================================================
# ÉTAPE 8 : Nettoie les fichiers temporaires
# =============================================================================
Write-Host "`n=== NETTOYAGE ===" -ForegroundColor Cyan
Remove-Item "$env:TEMP\verify-nupkg" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\verify.zip" -Force -ErrorAction SilentlyContinue

Write-Host "`n✅ Moulinette terminée !" -ForegroundColor Green
   

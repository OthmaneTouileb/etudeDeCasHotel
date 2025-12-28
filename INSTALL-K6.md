# Installation de k6 - Solutions

## Option 1 : Installation Manuelle (Recommandé - Pas besoin d'admin)

### Windows

1. **Télécharger k6** :
   - Allez sur : https://github.com/grafana/k6/releases
   - Téléchargez `k6-v0.48.0-windows-amd64.zip` (ou la dernière version)
   - Extrayez le fichier `k6.exe`

2. **Ajouter au PATH** :
   - Créez un dossier `C:\k6` (ou n'importe où vous avez les droits)
   - Copiez `k6.exe` dans ce dossier
   - Ajoutez `C:\k6` à votre PATH utilisateur :
     ```powershell
     [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\k6", "User")
     ```
   - Redémarrez PowerShell

3. **Vérifier l'installation** :
   ```powershell
   k6 version
   ```

### Alternative : Installation dans le dossier du projet

Vous pouvez aussi simplement télécharger k6.exe et le mettre dans un dossier `tools` de votre projet :

```powershell
# Créer le dossier
New-Item -ItemType Directory -Path "tools" -Force

# Télécharger k6 (remplacez par la dernière version)
Invoke-WebRequest -Uri "https://github.com/grafana/k6/releases/download/v0.48.0/k6-v0.48.0-windows-amd64.zip" -OutFile "tools\k6.zip"

# Extraire
Expand-Archive -Path "tools\k6.zip" -DestinationPath "tools" -Force

# Utiliser directement
.\tools\k6-v0.48.0-windows-amd64\k6.exe version
```

## Option 2 : Installation avec Chocolatey (Nécessite Admin)

Si vous voulez utiliser Chocolatey, vous devez :

1. **Ouvrir PowerShell en tant qu'Administrateur** :
   - Clic droit sur PowerShell
   - Sélectionner "Exécuter en tant qu'administrateur"

2. **Installer k6** :
   ```powershell
   choco install k6 -y
   ```

## Option 3 : Utiliser Scoop (Alternative à Chocolatey)

Scoop peut être installé sans droits administrateur :

```powershell
# Installer Scoop (si pas déjà installé)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# Installer k6
scoop install k6
```

## Option 4 : Utiliser Docker (Si Docker est disponible)

Vous pouvez exécuter k6 dans un conteneur Docker :

```powershell
# Créer un alias pour k6 via Docker
function k6 { docker run --rm -i grafana/k6 $args }

# Utiliser
k6 version
k6 run scripts/k6-test-rest.js
```

## Vérification

Après installation, testez :

```powershell
k6 version
```

Vous devriez voir quelque chose comme :
```
k6 v0.48.0 (go1.21.5, windows/amd64)
```

## Utilisation

Une fois installé, vous pouvez exécuter les tests :

```powershell
# Test REST
k6 run scripts/k6-test-rest.js

# Test GraphQL
k6 run scripts/k6-test-graphql.js
```


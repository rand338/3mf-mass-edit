# process_3mf.ps1
# Verarbeitet alle .3mf-Dateien im angegebenen Ordner

param(
    [string]$WorkingDir = "."
)

# Zum Arbeitsverzeichnis wechseln
Set-Location $WorkingDir

# Alle .3mf-Dateien im Ordner finden
$files = Get-ChildItem -Filter "*.3mf"

if ($files.Count -eq 0) {
    Write-Host "Keine .3mf-Dateien gefunden" -ForegroundColor Red
    exit
}

foreach ($file in $files) {
    $originalName = $file.Name
    $baseName = $file.BaseName
    $zipName = "$baseName.zip"
    $tempDir = "${baseName}_temp"
    
    Write-Host "Verarbeite: $originalName" -ForegroundColor Cyan
    
    # 1. Datei zu .zip umbenennen
    Rename-Item -Path $originalName -NewName $zipName
    
    # 2. In temporäres Verzeichnis entpacken
    Expand-Archive -Path $zipName -DestinationPath $tempDir -Force
    
    # 3. Alle .gcode-Dateien im Metadata-Ordner finden und bearbeiten
    $metadataPath = Join-Path $tempDir "Metadata"
    
    if (Test-Path $metadataPath) {
        $gcodeFiles = Get-ChildItem -Path $metadataPath -Filter "*.gcode"
        
        foreach ($gcodeFile in $gcodeFiles) {
            Write-Host "  Bearbeite: $($gcodeFile.Name)" -ForegroundColor Yellow
            
            # Datei einlesen und Zeile einfügen
            $content = Get-Content $gcodeFile.FullName
            $newContent = @()
            
            foreach ($line in $content) {
                $newContent += $line
                if ($line -match "^; nozzle_volume = ") {
                    $newContent += "; nozzle_volume_type = Standard"
                }
            }
            
            # Datei mit neuem Inhalt speichern
            $newContent | Set-Content $gcodeFile.FullName -Encoding UTF8
        }
    } else {
        Write-Host "  Warnung: Metadata-Ordner nicht gefunden" -ForegroundColor Yellow
    }
    
    # 4. Alte ZIP-Datei löschen (vor dem Neupacken)
    Remove-Item -Path $zipName -Force
    
    # 5. Wieder packen
    Compress-Archive -Path "$tempDir\*" -DestinationPath $zipName
    
    # 6. Zurück zu .3mf umbenennen
    Rename-Item -Path $zipName -NewName $originalName
    
    # 7. Temporäres Verzeichnis löschen
    Remove-Item -Path $tempDir -Recurse -Force
    
    Write-Host "Fertig: $originalName" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Alle Dateien wurden verarbeitet!" -ForegroundColor Green

```md
# 3MF Metadata GCode Patcher

Dieses Script verarbeitet alle `.3mf`-Dateien in einem Ordner, entpackt sie, fügt in den enthaltenen `Metadata/*.gcode`-Dateien nach `; nozzle_volume = ...` die Zeile `; nozzle_volume_type = Standard` ein und packt anschließend alles wieder zurück unter dem ursprünglichen Dateinamen. [conversation_history:1]

## Features

- Batch-Verarbeitung aller `.3mf` im Zielordner. [conversation_history:1]
- Findet im entpackten Inhalt den Ordner `Metadata` und bearbeitet dort alle `.gcode`-Dateien (typisch 1–3 Dateien). [conversation_history:1]
- Fügt die Zeile direkt **unter** der passenden `; nozzle_volume = ...`-Zeile ein. [conversation_history:1]
- Packt den Ordner wieder und stellt den ursprünglichen `.3mf`-Namen wieder her. [conversation_history:1]

## Voraussetzungen

- Bash (Linux/WSL empfohlen). [conversation_history:1]
- `unzip` und `zip` müssen installiert sein. [conversation_history:1]
- `sed` (GNU sed empfohlen, da `sed -i` verwendet wird). [conversation_history:1]

## Installation

1. Repository klonen oder Datei herunterladen.
2. Script ausführbar machen:

   ```bash
   chmod +x process_3mf.sh
```


## Nutzung

Im aktuellen Ordner:

```bash
./process_3mf.sh
```

Oder mit Zielordner als Parameter:

```bash
./process_3mf.sh /pfad/zu/deinen/3mf_dateien
```

Wichtig: Das Script überschreibt die ursprüngliche `.3mf`-Datei nach dem Neupacken wieder mit dem bearbeiteten Inhalt (Name bleibt gleich). [conversation_history:1]

## Wie es funktioniert (kurz)

- Jede `.3mf` wird temporär in `.zip` umbenannt (da der Inhalt wie ein ZIP-Archiv behandelt wird). [conversation_history:1]
- Es wird in ein temporäres Verzeichnis entpackt, dann werden alle `Metadata/*.gcode` mit `sed` geändert. [conversation_history:1]
- Danach wird der Inhalt wieder gezippt und zurück auf `.3mf` umbenannt; das Temp-Verzeichnis wird gelöscht. [conversation_history:1]


### Script

```bash
#!/bin/bash

# Verzeichnis mit den .3mf-Dateien (aktuelles Verzeichnis oder als Parameter übergeben)
WORKING_DIR="${1:-.}"

# In das Arbeitsverzeichnis wechseln
cd "$WORKING_DIR" || exit 1

# Alle .3mf-Dateien verarbeiten
for file in *.3mf; do
    # Prüfen ob Dateien existieren
    if [ ! -f "$file" ]; then
        echo "Keine .3mf-Dateien gefunden"
        exit 1
    fi
    
    # Originalnamen speichern
    original_name="$file"
    base_name="${file%.3mf}"
    zip_name="${base_name}.zip"
    
    echo "Verarbeite: $original_name"
    
    # 1. Datei zu .zip umbenennen
    mv "$original_name" "$zip_name"
    
    # 2. Temporäres Verzeichnis erstellen und entpacken
    temp_dir="${base_name}_temp"
    mkdir -p "$temp_dir"
    unzip -q "$zip_name" -d "$temp_dir"
    
    # 3. .gcode-Dateien im Metadata-Ordner finden und bearbeiten
    metadata_dir="$temp_dir/Metadata"
    
    if [ -d "$metadata_dir" ]; then
        # Alle .gcode-Dateien im Metadata-Ordner durchgehen
        find "$metadata_dir" -name "*.gcode" -type f | while read gcode_file; do
            echo "  Bearbeite: $(basename "$gcode_file")"
            
            # Zeile nach "; nozzle_volume = " einfügen
            sed -i '/^; nozzle_volume = /a\; nozzle_volume_type = Standard' "$gcode_file"
        done
    else
        echo "  Warnung: Metadata-Ordner nicht gefunden"
    fi
    
    # 4. Wieder packen
    cd "$temp_dir" || exit 1
    zip -q -r "../$zip_name" ./*
    cd ..
    
    # 5. Zurück zum ursprünglichen Namen (.3mf) umbenennen
    mv "$zip_name" "$original_name"
    
    # 6. Temporäres Verzeichnis löschen
    rm -rf "$temp_dir"
    
    echo "Fertig: $original_name"
    echo ""
done

echo "Alle Dateien wurden verarbeitet"
```


### Hinweise \& License

- Empfehlung: Vorher ein Backup der `.3mf`-Dateien anlegen, da die Dateien in-place aktualisiert werden. [conversation_history:1]
- macOS-Hinweis: Falls `sed -i` Probleme macht (BSD sed), muss die `sed`-Zeile ggf. angepasst werden (z.B. `sed -i '' ...`). [conversation_history:1]
- License: MIT (oder anpassen, falls gewünscht).

```


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

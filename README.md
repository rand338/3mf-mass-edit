# 3MF Metadata GCode Patcher
Ein Cross-Platform Toolset zur Batch-Verarbeitung von `.3mf`-Dateien. Es entpackt die Archive, injiziert automatisch Metadaten in enthaltene GCode-Dateien und verpackt alles wieder – vollautomatisch.

Speziell entwickelt, um in `Metadata/*.gcode` Dateien nach der Zeile `; nozzle_volume = ...` die Zeile `; nozzle_volume_type = Standard` einzufügen. [conversation_history:1][conversation_history:3]

## ✨ Features

- **Multi-Platform:** Native Scripts für Windows (PowerShell) und Linux/macOS (Bash). [conversation_history:3]
- **Batch-Processing:** Verarbeitet automatisch alle `.3mf`-Dateien in einem Ordner.
- **Intelligent:** Findet automatisch 1, 2 oder 3 `.gcode`-Dateien im `Metadata`-Unterordner. [conversation_history:1]
- **Präzise:** Fügt die Konfiguration exakt an der richtigen Stelle ein.
- **Clean:** Hinterlässt keine temporären Dateien und stellt die Original-Dateinamen wieder her.

---

## 📂 Enthaltene Dateien

| Datei | Beschreibung | System |
| :--- | :--- | :--- |
| `process_3mf.ps1` | Native PowerShell-Version (keine externen Tools nötig) | Windows 10/11 |
| `process_3mf.sh` | Bash-Version (nutzt `zip`/`unzip`/`sed`) | Linux, macOS, WSL |

---

## 💻 Nutzung: Windows (PowerShell)

Diese Version nutzt ausschließlich Windows-Bordmittel. [conversation_history:3]

### 1. Vorbereitung
Speichere das Script als `process_3mf.ps1` in deinem Ordner mit den `.3mf`-Dateien.

### 2. Einmalige Einrichtung
Falls noch nie Scripte ausgeführt wurden, öffne PowerShell als Administrator und erlaube die Ausführung:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```


### 3. Ausführung

Rechtsklick auf die Datei → **"Mit PowerShell ausführen"** oder über das Terminal:

```powershell
# Im aktuellen Verzeichnis
.\process_3mf.ps1

# Oder mit Pfad-Angabe
.\process_3mf.ps1 -WorkingDir "C:\Pfad\zu\Dateien"
```


---

## 🐧 Nutzung: Linux / macOS (Bash)

Diese Version ist ideal für Linux-Desktop, Server oder macOS. [conversation_history:1]

### 1. Vorbereitung

Speichere das Script als `process_3mf.sh` und stelle sicher, dass `zip` und `unzip` installiert sind (meist vorinstalliert).

### 2. Rechte vergeben

Mache das Script ausführbar:

```bash
chmod +x process_3mf.sh
```


### 3. Ausführung

```bash
# Im aktuellen Verzeichnis
./process_3mf.sh

# Oder mit Pfad-Angabe
./process_3mf.sh /home/user/pfad/zu/dateien
```


---

## 🔧 Funktionsweise (Technical Deep Dive)

Beide Scripte folgen der gleichen Logik, implementiert in ihrer jeweiligen Umgebungssprache:

1. **Rename:** `.3mf` wird zu `.zip` umbenannt (3MF ist technisch ein ZIP-Container).
2. **Extract:** Inhalt wird in einen temporären Ordner (`*_temp`) entpackt.
3. **Patch:**
    * **Bash:** Nutzt `sed`, um den Textstream zu bearbeiten.
    * **PowerShell:** Liest die Datei in ein Array, injiziert die Zeile und schreibt zurück (UTF-8).
4. **Repack:** Der Ordner wird wieder komprimiert.
5. **Restore:** `.zip` wird zurück zu `.3mf` benannt.
6. **Cleanup:** Temporäre Ordner werden gelöscht.

---

## ⚠️ Wichtige Hinweise

* **Backup:** Das Script arbeitet **in-place**. Es überschreibt die existierenden `.3mf`-Dateien. Erstelle vor dem ersten großen Durchlauf ein Backup!
* **Encoding:** Die GCode-Dateien werden als UTF-8 gespeichert.
* **macOS User:** Das Bash-Script nutzt `sed`. macOS verwendet BSD-sed, was sich leicht von GNU-sed unterscheidet. Das Script sollte funktionieren, aber bei Fehlern (z.B. `invalid command code`) muss ggf. `sed -i '' ...` verwendet werden.

---

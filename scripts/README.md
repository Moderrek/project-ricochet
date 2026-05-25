# Scripts (Narzędzia dla developerów)

Pomocnicze skrypty do testowania, benchmarkingu i pracy nad projektem. Pliki `.sh` to shell scripts dla Linux/Mac.

---

## linux_benchmark.sh - Test wydajności na Linux

Narzędzie do mierzenia FPS (frames per second) gry na Linux.

### Po co?

Sprawdza wydajność gry na starszych komputerach szkolnych. Ważne aby wiedzieć czy gra będzie działać w pracowni szkolnej.

### Użycie

```bash
# Terminal
cd project-ricochet
chmod +x scripts/linux_benchmark.sh
./scripts/linux_benchmark.sh
```

Gra się uruchomi i będzie wyświetlać FPS w konsoli.

### Co robi

Parametry Godot:

```bash
godot --print-fps --max-fps 0 --disable-vsync
```

- `--print-fps`: Wyświetla licznik klatek na sekundę (stdout)
- `--max-fps 0`: Brak limitu FPS (gra działa na maksymalną prędkość)
- `--disable-vsync`: Wyłącza synchronizację z odświeżaniem (V-Sync)

### Typowe wyniki

| Sprzęt | FPS | Status |
|--------|-----|--------|
| Nowoczesny laptop (2023+) | 60+ | ✅ Idealnie |
| Średni laptop (2018-2020) | 45-60 | ✅ Dobrze |
| Stary komputer szkolny (2015-2017) | 30-45 | ⚠️ Powinno działać |
| Bardzo stary (<2015) | <30 | ❌ Może się zacinać |

### Interpretacja wyników

- **60 FPS**: Gra działa idealnie, nie ma lagów
- **30-60 FPS**: Gra działa, ale czasem się zaciąć
- **<30 FPS**: Gra może być niegrywalna

### Dla nauczycieli w pracowni

Przed zainstalowaniem gry w pracowni szkolnej:

1. Skopiuj projekt na jeden ze starszych komputerów
2. Uruchom `./scripts/linux_benchmark.sh`
3. Jeśli FPS > 30 → gra będzie działać
4. Jeśli FPS < 30 → zmień grafiki na niskie (w project.godot)

---

## Dodanie nowych skryptów

Jeśli chcesz dodać nowe narzędzie:

1. Stwórz plik `.sh` w tym folderze
2. Dodaj shebang na górze:
   ```bash
   #!/bin/sh
   # Komentarz: co to robi
   ```
3. Zrób plik executable:
   ```bash
   chmod +x scripts/moj_skrypt.sh
   ```
4. Uruchom:
   ```bash
   ./scripts/moj_skrypt.sh
   ```

---

## Przykład: Skrypt do testowania na Windows

Jeśli potrzebujesz equivalent'u dla Windows, stwórz `windows_benchmark.bat`:

```batch
@echo off
REM Benchmark dla Windows
godot --print-fps --max-fps 0 --disable-vsync
```

Użycie:
```
windows_benchmark.bat
```

---

## Tips

- **Benchmark w edytorze**: F5 w Godot Editor też wyświetla FPS (prawy górny róg)
- **Render Device**: Godot automatycznie wybiera (Direct3D na Windows, OpenGL na Linux/Web)
- **Headless mode**: Możesz uruchomić `godot --headless` bez grafiki (dla testów logiki)
- **Logging**: Dodaj `--print-debug` aby widzieć debug messages w konsoli
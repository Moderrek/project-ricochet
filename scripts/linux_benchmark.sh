#!/bin/sh
# Skrypt do testowania wydajności gry na Linux
# Uruchomia grę bez ograniczenia FPS i wyświetla licznik klatek na sekundę
# Przydatny do sprawdzenia, ile FPS osiąga gra na danym sprzęcie

# Parametry:
# --print-fps     : Wyświetla FPS w konsoli podczas gry
# --max-fps 0     : Brak limitu FPS (gra będzie działać na maksymalną prędkość)
# --disable-vsync : Wyłącza synchronizację z odświeżaniem ekranu (V-Sync)

godot --print-fps --max-fps 0 --disable-vsync

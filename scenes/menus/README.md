# Menus (Ekrany nawigacyjne)

Sceny menu - wszystko co nie jest bezpośrednią rozgrywką. Tutaj gracz porusza się po ekranach, wybiera opcje i widzi wyniki.

## Menu i ekrany

### Menu główne (main_menu.tscn)
Ekran startowy gry. Zawiera:
- **Przycisk Play**: Startuje grę od Level 0 (tutorial)
- **Przycisk Lockers** (w budowie): Przyszła funkcja
- **Przycisk News**: Otwiera stronę konkursu School Games 2026
- **Wyświetlacz monet**: Pokazuje ile masz monet z poprzednich gier (powiązane z SaveManager)
- Efekty audio: Dźwięki hover i click na każdym przycisku
- Animacje: Przyciski się powiększają przy najechaniu myszą

### Menu pauzy (pause_menu.tscn)
Wyskakuje podczas gry po naciśnięciu ESC. Pozwala:
- **Resume**: Powrót do gry
- **Retry**: Restart aktualnego poziomu
- **Main Menu**: Powrót do menu głównego
- **Quit** (nie na HTML5): Zamknięcie gry

Pauza zamraza całą grę (Time.scale = 0) i zatrzymuje animacje.

### Ekran końcowy (end_screen.tscn)
Pokazuje się gdy:
- Upłynął czas (porażka - "SPÓŹNIENIE!")
- Ukończyłeś wszystkie poziomy (wygrana - "CEL OSIĄGNIĘTY!")

Zawiera:
- **Tytuł**: Wygrana/Porażka z odpowiednim kolorem
- **Statystyki**:
  - Czas rozgrywki (MM:SS)
  - Liczba strzałów
  - Liczba odbić od ścian
  - Liczba śmierci
  - Zebrane monety
- **Przyciski**: Menu (powrót do menu głównego), Retry (powtórz grę)
- Monety zebrane w tym przebiegu dodają się do SaveManager (całkowitej puli)

### Kamera kinowa (cinematic_camera.gd)
Specjalna kamera dla menu - nie śledzi gracza, tylko statyczna scena do menu głównego.

## Nawigacja między ekranami

```
Menu Główne
    ↓ [Play]
  Gra (Level 0→1→2)
    ↓ [ESC] lub [Koniec poziomu]
  Menu Pauzy / Ekran Końcowy
    ↓
  Menu Główne lub Retry
```

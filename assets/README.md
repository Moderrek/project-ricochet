# Assets (Zasoby surowe)

Wszystkie surowe pliki graficzne, dźwiękowe i czcionki. Tutaj przechowywane są przed zintegrowaniem z grą w scenach Godot.

**Ważne**: Pliki `.import` to metadane Godot - nie edytuj ich ręcznie.

---

## Czcionki (fonts/)

Czcionki w formacie TTF (TrueType Font) używane w interfejsie.

### Dostępne czcionki

- **Rubik-Regular.ttf** - Zwykły tekst (menu, HUD, dialogów)
- **Rubik-Medium.ttf** - Średnia waga (nagłówki)
- **Rubik-Black.ttf** - Pogrubiona (ważne teksty, tytuły)

### Gdzie są używane

- Menu główne: Rubik-Medium (przyciski), Rubik-Black (tytuł)
- HUD (w grze): Rubik-Regular (timer, licznik monet)
- Ekran końcowy: Rubik-Black (CEL OSIĄGNIĘTY / SPÓŹNIENIE)

### Dodanie nowej czcionki

1. Skopiuj plik `.ttf` do `fonts/`
2. W edytorze Godot: Control node → Theme → Font Family → wybiórz czcionkę
3. Godot automatycznie zaimpletuje `.import`

---

## Ikony (icons/)

Małe grafiki 64x64px na ikonki do Inspector'a w edytorze Godot (nie widoczne dla gracza).

### Dostępne ikony

```
player_icon.png     - Ikona gracza (kula)
coffee_icon.png     - Ikona kawy (collectible)
coin_icon.png       - Ikona monety (cez coin)
wall_icon.png       - Ikona ściany
pallet_icon.png     - Ikona palety
vending_icon.png    - Ikona automatu do kawy
hazard_icon.png     - Ikona niebezpiecznej strefy
```

### Jak działają

W skryptach:
```gdscript
@icon("res://assets/icons/player_icon.png")
extends RigidBody2D
class_name Player
```

Gdy otworzysz scenę w edytorze, ikona pojawia się obok nazwy klasy (czytelność).

### Dodanie nowej ikony

Tę samą składnię `@icon()` - Godot automatycznie wyświetli ikonę.

---

## Obrazki (images/)

Sprites i grafiki do gry - to co widzi gracz.

### Sprite sheets (animacje)

- **cez_coin_spritesheet.png** - Animacja monety (rotacja)
- **coffee_spritesheet.png** - Animacja kawy (bobowanie/rotacja)

Użyte w collectibles do animacji zbierania.

### Pojedyncze sprites

- **player.png** - Gracz (kula)
- **wall.png** - Ściana (tilemap texture)
- **pallet.png** - Europalet
- **vending.png** - Automat do kawy
- **wall_test.png** - Alternatywna tekstura do testów

### Rozmiary monet

- **cez_coin_24x24.png** - Mała (interfejs, HUD)
- **cez_coin_64x64.png** - Duża (w grze)

### Inne grafiki

- **arrow_up.png** - Strzałka do góry (możliwy UI element)
- **arrow_turn_right.png** - Strzałka w prawo (możliwy UI element)
- **camera.png** - Ikona kamery (UI)

### Dodanie nowego sprite'a

1. Skopiuj PNG do `images/`
2. W edytorze: Utwórz Sprite2D node
3. Sprite2D → Texture → Wybiórz plik
4. Ustaw rozmiar i offset

---

## Dźwięki (sounds/)

Efekty dźwiękowe (SFX) i soundtrack gry w formacie OGG (Vorbis - kompresja).

### Efekty dźwiękowe (SFX)

```
sfx_coin.ogg           - Zbieranie monety (ding!)
sfx_gulp.ogg           - Zbieranie kawy (gulp)
sfx_shoot.ogg          - Strzał gracza (pow!)
sfx_hit.ogg            - Uderzenie w ścianę (bum!)
sfx_break.ogg          - Rozbicie/śmierć (crash!)
sfx_photo.ogg          - Foto collectible (snap!)
sfx_ui_click.ogg       - Klik przycisku (menu)
sfx_ui_hover.ogg       - Hover przycisku (menu)
ambient_machine_noise.ogg - Hałas automatu (tło)
```

### Soundtrack

- **soundtrack.ogg** - Główna muzyka gry (pętla)

Gra podczas całej rozgrywki, zatrzymuje się na ekranach menu.

### Gdzie są przypisane

```gdscript
# Player.gd
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound
@onready var bounce_sound: AudioStreamPlayer2D = $BounceSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

# Collectibles
@export var pickup_sound: AudioStream  # Przypisane w Inspector

# Menu
@onready var hover_sound: AudioStreamPlayer = $HoverSound
@onready var click_sound: AudioStreamPlayer = $ClickSound

# GameManager
@onready var soundtrack: AudioStreamPlayer = $Soundtrack
```

### Dodanie nowego dźwięku

1. Konwertuj do OGG (Audacity: File → Export → OGG Vorbis)
2. Skopiuj do `sounds/`
3. W scenach: AudioStreamPlayer2D → Stream → Wybierz plik
4. Godot zaimpletuje `.import`

### Ustawienia OGG

Dla gier zwykle:
- Bitrate: 128 kbps
- Channels: Mono (SFX) lub Stereo (Soundtrack)
- Kwalość: 5-6/10 (wystarczająca dla gier)

---

## Zdjęcia (photos/)

Zdjęcia z eventów szkolnych CKZiU - używane w PhotoManager.

### Zdjęcia w bazie

```
boze_narodzenie.jpg         - Świąteczny stół wigilijny
dyrektorzy.jpg              - Dyrektorowie szkoły
school_game.jpg             - Konkurs School Games 2026
walentyna_tierieszkowa.jpg  - Patronka szkoły (kosmonautka)
druk.jpg                    - Druk/publikacja szkoły
sztafeta_erasmus.jpg        - Międzyszkolna Sztafeta Erasmus
```

### Jak działają

W `resources/photos/photo_database.tres` - każde zdjęcie ma:
- ID (nazwa bez .jpg)
- Title (tytuł)
- Description (opis)
- Texture (ścieżka do PNG/JPG)

Gracz je zbiera w grze → PhotoManager odblokowuje → pojawia się w galerii.

### Dodanie nowego zdjęcia

1. Skopiuj JPG/PNG do `photos/`
2. Otwórz `resources/photos/photo_database.gd`
3. Dodaj nowe PhotoData:
   ```gdscript
   var photo_new = PhotoData.new()
   photo_new.id = "new_photo"
   photo_new.title = "Tytuł Zdjęcia"
   photo_new.description = "Opis..."
   photo_new.texture = load("res://assets/photos/new_photo.jpg")
   ```
4. Dodaj do bazy
5. Testuj: Photo collectible będzie je losować

---

## Format plików - dlaczego OGG a nie MP3?

- **OGG**: Bezpłatny, otwarty format (Godot preferuje)
- **MP3**: Patenty, droższe (nie używamy)
- **WAV**: Duże pliki (nie dla gier)

Godot konwertuje automatycznie do formatu skompresowanego przy eksporcie.

---

## Struktura folderów

```
assets/
├── fonts/          - Czcionki TTF (Rubik)
├── icons/          - Ikony edytora (dla programistów)
├── images/         - Sprites i grafiki (gracz je widzi)
├── photos/         - Zdjęcia z eventów szkoły
└── sounds/         - Efekty dźwiękowe i soundtrack
```

---

## Tips

- **Zawsze konwertuj dźwięki do OGG** - mniejsze pliki, lepsze dla web
- **PNG dla sprite'ów** - przezroczystość
- **JPG dla zdjęć** - mniejsze pliki na dysku
- **Sprite sheets** zamiast pojedynczych PNGów dla animacji
- Godot `.import` pliki - **nie edytuj ręcznie**, usuń jeśli coś się psuje
- Grafiki dla web: **optymalizuj rozmiary** - mniejsze download

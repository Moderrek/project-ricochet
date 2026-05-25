# Resources (Zasoby konfiguracyjne Godot)

Pliki konfiguracyjne i bazy danych gry - definicje levelów, skinów, zdjęć i motywów UI.

Wszystkie pliki to **Godot Resources** (`.tres`) lub skrypty danych (`.gd`).

---

## data/ - Klasy danych

Skrypty definiujące struktury danych dla głównych systemów gry.

### LevelData.gd

Definiuje właściwości każdego poziomu. Klasa szablonowa.

```gdscript
extends Resource
class_name LevelData

@export var level_name: String = "Corridor"
@export_file("*.tscn") var scene_path: String
@export var has_timer: bool = true
@export var requires_player: bool = true
```

**Pola:**
- `level_name` - Nazwa poziomu (Corridor, Lab itp.)
- `scene_path` - Ścieżka do sceny (res://scenes/levels/level_1.tscn)
- `has_timer` - Czy poziom ma timer?
- `requires_player` - Czy gracz musi być spawny? (zwykle yes)

**Jak się używa:**
```gdscript
# W BaseLevel.gd
var level_config: LevelData

func _on_level_loaded():
    if level_config.has_timer:
        start_timer(180)  # 3 minuty
```

### PhotoData.gd

Definiuje jedno zdjęcie do galerii.

```gdscript
extends Resource
class_name PhotoData

@export var id: String = "unique_photo_id"
@export var title: String = "Photo Title"
@export_multiline var description: String = "A brief description."
@export var coin_reward: int = 10
@export_file("*.png", "*.jpg", "*.webp") var image_path: String
```

**Pola:**
- `id` - Unikatowy identyfikator (np. "photo_boze_narodzenie")
- `title` - Tytuł do wyświetlenia
- `description` - Tekst pod zdjęciem
- `coin_reward` - Ile monet daje zbierając to zdjęcie
- `image_path` - Ścieżka do tekstury zdjęcia

**Gdzie się używa:**
- PhotoManager sprawdza zbrane zdjęcia
- Galeria wyświetla je graczowi

### SkinData.gd

Definiuje wygląd gracza (skin).

```gdscript
extends Resource
class_name SkinData

@export var skin_id: String
@export var skin_name: String
@export var skin_icon: Texture2D
@export var rarity: String = "Common"
@export var school_profile: String  # Informatyk, Programista
```

**Pola:**
- `skin_id` - ID skina (np. "default_ball")
- `skin_name` - Nazwa do wyświetlenia
- `skin_icon` - Ikona w szafie
- `rarity` - Rzadkość: "Common", "Rare", "Epic"
- `school_profile` - Zawód szkoły (CKZiU ma różne profili)

**Planowe użycie:**
- System szafy (locker) do zbierania skinów
- Gracz zmienia wygląd kuli

### PhotoDatabase.gd

Zbiera wszystkie PhotoData w jedną bazę.

```gdscript
extends Resource
class_name PhotoDatabase

@export var photos: Array[PhotoData] = []
```

**Po co:**
- Łatwe iterowanie po wszystkich zdjęciach
- PhotoManager losuje z tej bazy

**Użycie:**
```gdscript
# PhotoManager
var db: PhotoDatabase = load("res://resources/photos/photo_database.tres")
var random_photo = db.photos[randi() % db.photos.size()]
```

---

## levels/ - Konfiguracje poziomów

Pliki `.tres` (zasoby Godot) zawierające konfiguracje dla każdego poziomu.

### level_tutorial.tres
Poziom bez timera - gracz uczy się strzelać, zbierać monety. **Zawsze pierwszy.**

### level_first.tres
Pierwszy właściwy poziom - timer zaczyna się z pierwszym strzałem.

### level_2.tres
Drugi poziom - trudniejszy, więcej przeszkód.

### level_test.tres
Poziom testowy do debugowania - nie ładuje się z menu.

**Struktura każdego .tres:**
```
LevelData
├─ level_name: "Tutorial"
├─ scene_path: "res://scenes/levels/level_tutorial.tscn"
├─ has_timer: false
└─ requires_player: true
```

**Jak dodać nowy poziom:**

1. Utwórz nową scenę: `scenes/levels/level_3.tscn`
2. Utwórz Resource: Prawy klik w Project → New Resource → LevelData
3. Wypełnij pola:
   - level_name: "Level 3"
   - scene_path: res://scenes/levels/level_3.tscn
   - has_timer: true
4. Zapisz jako: `resources/levels/level_3.tres`
5. Dodaj do GameManager.gd:
   ```gdscript
   var levels = [
       load("res://resources/levels/level_tutorial.tres"),
       load("res://resources/levels/level_first.tres"),
       load("res://resources/levels/level_2.tres"),
       load("res://resources/levels/level_3.tres"),  # NOWY
   ]
   ```

---

## photos/ - Baza zdjęć

Pliki `.tres` zawierające dane zdjęć szkolnych.

### photo_database.tres
**Główna baza.** Zawiera array wszystkich PhotoData.

### photo_*.tres (jednotwe zdjęcia)
Każde zdjęcie to osobny plik:
- `photo_boze_narodzenie.tres` - Święta
- `photo_dyrektorzy.tres` - Portrety dyrektorów
- `photo_schoolgame.tres` - School Games 2026
- `photo_walentyna.tres` - Walentyna Tierieszkowa (patronka szkoły)
- `photo_sztafeta_erasmus.tres` - Międzyszkolna Sztafeta
- `photo_druk.tres` - Publikacja szkoły

**Struktura każdego photo_*.tres:**
```
PhotoData
├─ id: "photo_schoolgame"
├─ title: "CKZiU School Games 2026"
├─ description: "Konkurs międzyszkolny..."
├─ coin_reward: 10
└─ image_path: "res://assets/photos/school_game.jpg"
```

**Jak dodać nowe zdjęcie:**

1. Umieść zdjęcie: `assets/photos/new_photo.jpg`
2. New Resource → PhotoData
3. Wypełnij:
   ```
   id: "photo_new_event"
   title: "Nowy Event"
   description: "Opis..."
   coin_reward: 10
   image_path: res://assets/photos/new_photo.jpg
   ```
4. Zapisz: `resources/photos/photo_new_event.tres`
5. Dodaj do photo_database.tres:
   - Otwórz photo_database.tres w Inspector
   - Photos → Add Element
   - Drag photo_new_event.tres

---

## themes/ - Motywy UI

Pliki `.tres` z tematami interfejsu (kolory, czcionki, rozmiary).

### soft_ui_theme.tres

Główny motyw UI gry. Definiuje:
- Kolory przycisków, tekstu, tła
- Czcionki (Rubik)
- Rozmiary font'ów
- Style dla kontrolek (Button, Label, Panel)

**Struktura:**
```
Theme
├─ default_font: Rubik-Regular
├─ default_font_size: 24
├─ colors
│  ├─ font_color: white
│  ├─ font_focus_color: yellow
│  ├─ font_pressed_color: orange
│  └─ panel_bg_color: dark_gray
└─ styles
   ├─ Button styles
   ├─ Panel styles
   └─ Label styles
```

**Jak się używa:**

W scenach UI:
```gdscript
# Control node → Inspector → Theme
# Wybierz: soft_ui_theme.tres
```

Wszystkie dzieci tego Control'a będą używać stylów z theme.

**Dodanie nowego stylu:**

1. Otwórz soft_ui_theme.tres w Inspector
2. Theme → Resource Editor
3. Dodaj nowy Element (np. Button styles)
4. Dostosuj kolory, czcionki, marginesy

---

## Jak wszystko się łączy

```
GameManager (autoload)
│
├─→ Ładuje levels/ do rozgrywki
│   └─ LevelData → scena o właściwościach
│
├─→ PhotoManager
│   └─ Losuje z photo_database.tres
│      └─ PhotoData → zdjęcie do odblokowania
│
└─→ Sceny UI
    └─ Używają soft_ui_theme.tres
       └─ Spójny wygląd menu/HUD
```

---

## Tips

- **LevelData, PhotoData, SkinData** - To szablony, niezmienne
- **level_*.tres, photo_*.tres** - Instancje szablonów, zmienne dane
- **Zawsze** oddzielaj dane od logiki
- Resource files (`.tres`) to pliki Godot - łatwe do edycji w Inspector
- Aby zmienić coś globalnie (np. kolor tekstu) → edytuj `soft_ui_theme.tres`

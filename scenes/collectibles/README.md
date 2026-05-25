# Collectibles (Przedmioty do zbierania)

Obiekty które gracz zbiera podczas gry. Każdy ma inny efekt - monety, boost, zdjęcia. Kod jest oparty na **dziedziczeniu** - bardzo prostym i eleganckim wzorze.

## System dziedziczenia

Project Ricochet pokazuje jak **prawidłowo** używać dziedziczenia:

```
BaseCollectible (szablon)
├── CezCoinCollectible (monety)
├── CoffeeCollectible (boost)
└── PhotoCollectible (zdjęcia)
```

**Dzięki dziedziczeniu**:
- Wszystkie collectibles działają tak samo (animation, pickup sound)
- Każdy zmienia tylko swoją logikę zbierania (_on_collect)
- DRY (Don't Repeat Yourself) - kod się nie powtarza

---

## BaseCollectible - Szablon

**Plik**: `base_collectible.gd`

To klasa bazowa dla WSZYSTKICH przedmiotów. Zawiera wspólną logikę:

### Jak działa zbieranie

1. **Gracz dotknie** (Area2D collision)
2. **collect()** się wywoła:
   - Ustaw `_is_collected = true`
   - Odtwórz dźwięk pickup
   - Wywoła `_on_collect()` (virtual - każdy przedmiot robi coś innego)
   - Animacja: **leci w górę i zanika**

3. **Animacja**:
   - Y się przesuwa o -80px (w górę)
   - Modulate alpha fade out (0.0 → przezroczysty)
   - Czas: 0.4 sekundy
   - Tweeny równoległy (parallel)

4. **Usunięcie**: Po animacji i dźwięku - `queue_free()` (przedmiot znika)

### Kod bazowy (pseudokod - to co każdy collectible dziedziczy)

```gdscript
extends Area2D
class_name BaseCollectible

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body):
    if body.is_in_group("player"):
        collect()

func collect() -> void:
    odtwórz dźwięk
    wywoła _on_collect()         # Virtual - nadpisz mnie!
    play_collect_animation()

func play_collect_animation() -> void:
    # Leci w górę i zanika
    tween do Y-80, alpha 0.0 w 0.4s

func _on_collect() -> void: pass  # VIRTUAL - każdy nadpisuje to!
```

---

## CezCoin - Moneta szkolna

**Plik**: `cez_coin/cez_coin.gd`

Najprostszy collectible - dodaje monety do GameManager.

### Co robi

```gdscript
extends BaseCollectible
class_name CezCoinCollectible

@export var value: int = 1  # Ile monet dodać (domyślnie 1)

func _on_collect() -> void:
    GameManager.add_coins(value)  # Dodaj monety!
```

**To wszystko!** Reszta (dźwięk, animacja, detektowanie gracza) pochodzi z BaseCollectible.

### Parametry

- `value`: Ile monet dać (domyślnie 1, ale możesz ustawić 5, 10 itp.)
- `pickup_sound`: Dźwięk zbierania (dziedziczony z BaseCollectible)

### Dodanie na mapę

1. Przeciągnij `cez_coin/cez_coin.tscn`
2. Ustaw `value` w Inspector jeśli chcesz inną liczbę monet
3. Gotowe!

---

## Coffee - Boost

**Plik**: `coffee/coffee.gd`

Kawa daje graczowi boost. Nieco bardziej zaawansowane niż moneta - ma dodatkową animację "bobowania".

### Co robi

```gdscript
extends BaseCollectible
class_name CoffeeCollectible

@export_range(0.0, 100.0) var boost_amount: float = 50.0

func play_hover_animation() -> void:
    # Specjalna animacja: bobowanie (-5px do +5px w Y)
    # Pętla: sinus wave oscyluje do góry i dołu
    
func _on_collect() -> void:
    GameManager.add_boost(boost_amount)  # Dodaj boost!
```

### Animacje

**Hover animation** (podczas lotu):
- Bobuje (-5px → +5px → -5px)
- Pętelnie (loop)
- Ładnie wygląda gdy kawa wypada z automatu

**Collect animation** (zbieranie):
- Tej samej jak inne collectibles (leci w górę, zanika)
- **Override'uje** `play_collect_animation()` aby zatrzymać hover

### Parametry

- `boost_amount`: % boosta (domyślnie 50%, maksymalnie 100%)
- `pickup_sound`: Dźwięk (dziedziczony)

### Dodanie na mapę

1. Przeciągnij `coffee/coffee.tscn`
2. W Inspector ustaw `boost_amount` (50% to domyślnie)
3. Gotowe - będzie bobować jak pada!

---

## Photo - Zdjęcie

**Plik**: `photo/photo.gd`

Zdjęcie odblokowuje losowe zdjęcie z galerii szkolnych eventów.

### Co robi

```gdscript
extends BaseCollectible
class_name PhotoCollectible

@export_range(0.0, 1.0) var spawn_chance: float = 0.5

func _ready():
    # Losowa szansa że się pojawi (50% domyślnie)
    if randf() > spawn_chance:
        queue_free()  # Nie pojawia się!

func _on_collect() -> void:
    var photo = PhotoManager.get_random_locked_photo()
    PhotoManager.unlock_photo(photo)  # Odblokowaniem zdjęcie!
```

### Co się dzieje

1. Photo pojawia się z szansą `spawn_chance` (50% domyślnie)
2. Gracz je zbiera
3. Losowe zdjęcie z PhotoManager się odblokowuje
4. Gracz widzi je w galerii

### Parametry

- `spawn_chance`: Szansa że foto się pojawi (0.0-1.0, gdzie 0.5 = 50%)
- `pickup_sound`: Dźwięk (dziedziczony)

### Zdjęcia w bazie

PhotoManager zawiera zdjęcia:
- Świątkowe eventy szkoły
- Patrona szkoły (Walentyna Tierieszkowa)
- Konkursy międzyszkolne (Sztafeta Erasmus)

---

## Jak stworzyć nowy collectible

**To jest proste dzięki dziedziczeniu!**

### Krok 1: Utwórz nowy skrypt

```gdscript
@icon("res://assets/icons/your_icon.png")
extends BaseCollectible
class_name YourCollectible

@export var effect_amount: float = 10.0

func _on_collect() -> void:
    # Tutaj YOUR LOGIC
    GameManager.do_something(effect_amount)
```

### Krok 2: Utwórz scenę

1. Utwórz nowy folder w `/collectibles/your_collectible/`
2. Skopiuj scenę z `coffee.tscn` lub `cez_coin.tscn`
3. Root: Area2D
4. Dodaj: Sprite2D, CollisionShape2D, AudioStreamPlayer2D
5. Attach skrypt `your_collectible.gd`

### Krok 3: Ustaw w Inspector

- `pickup_sound`: Dźwięk
- `effect_amount`: Twój parametr
- Sprite2D: Grafika

### Krok 4: Testuj

```
F6 na scenie collectible
```

**Gotowe!** Twój collectible będzie działać tak jak wszystkie inne.

---

## Wzór dziedziczenia - dlaczego to piękne

```
Problem bez dziedziczenia:
├── MoneyPickup.gd - 50 linii (detektowanie, animacja, dźwięk, dodawanie)
├── BoostPickup.gd - 50 linii (to samo!)
└── PhotoPickup.gd - 50 linii (to samo!)
= 150 linii powtarzającego się kodu

Rozwiązanie z dziedziczeniem:
├── BaseCollectible.gd - 50 linij (wszystko wspólne)
├── CezCoin.gd - 5 linij (tylko logika)
├── Coffee.gd - 10 linij (tylko logika + hover)
└── Photo.gd - 15 linij (tylko logika)
= 80 linij kodu, bez powtórzeń
```

**Korzyści**:
- Łatwo dodawać nowe collectibles
- Zmiana animacji = zmiana w jednym miejscu
- Mniej bugów (logika w jednym miejscu)
- Kod czytelny i zorganizowany

To jest **DRY** (Don't Repeat Yourself) i **SOLID** (Single Responsibility).

---

## Struktura collectible sceny

```
Collectible (Area2D) - Base
├── Sprite2D        - Grafika
├── CollisionShape2D- Fizykę
└── AudioStreamPlayer2D - Dźwięk
```

Wszystkie collectibles mają identyczną strukturę - różni się tylko skrypt i grafika!

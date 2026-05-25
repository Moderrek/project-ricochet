# Interactables (Obiekty interaktywne)

Obiekty, które gracz może zebrać, na które może wpaść, albo które reagują na uderzenia. Stanowią wyzwania na poziomach.

## Obiekty interaktywne

### Level End Area (level_end_area/)
**Przeznaczenie**: Koniec poziomu - gracz musi tu dotrzeć aby przejść dalej.

**Jak działa**:
- To jest Area2D (detektor kolizji)
- Gdy gracz ja dotknie, automatycznie ładuje **następny poziom** z GameManager
- Zawsze musi być jeden na każdej mapie

**Dodanie na mapę**:
1. Przeciągnij `level_end_area.tscn` na mapę
2. Ustaw pozycję gdzie powinien być koniec poziomu
3. Gotowe - połączy się z GameManager automatycznie

**Kod**:
```gdscript
if body is player:
    GameManager.load_next_level()  # Przechodzi do następnego levela
```

---

### Vending Machine (automat do kawy)
**Przeznaczenie**: Generuje boost (kawy). Każdy gracz lubi kawę.

**Jak działa**:
- Gracz musi w nią **uderzyć z wystarczającą siłą** (domyślnie >200 px/s)
- Automat drży (shake animation)
- Wypuszcza N kawek (domyślnie 1, ale można ustawić więcej)
- Kawy spadają losowo w lewo/prawo
- Gracz je zbiera → +boost

**Ustawienia (w edytorze)**:
```
Impact Threshold: 200.0  - Minimalna siła uderzenia
Coffee Count: 1          - Ile kawek wypuści
Drop Distance: 80.0      - Jak daleko spadają
Drop Spread: 50.0        - Losowość (lewo/prawo)
```

**Dodanie na mapę**:
1. Przeciągnij `vending_machine.tscn`
2. W Inspector ustaw `coffee_scene` na ścieżkę collectibles (Coffee)
3. Ustaw `coffee_count` ile kawek ma wypuścić
4. Gotowe!

**Animacja**:
- Sprite drży 4 razy (shake left-right)
- Kawy animują się w dół z trajektorią
- Jeśli kawa ma metodę `play_hover_animation()`, gra ją po wylądowaniu

---

### Pallet (europalet - przeszkoda)
**Przeznaczenie**: Ciężka przeszkoda logistyczna. Gracz może ją przesunąć.

**Jak działa**:
- To zwykły RigidBody2D (fizyka)
- Gracz może ją uderzyć aby przesunąć
- Служи jako blokada - można nią zagrodzić przejście
- Może być wiele na mapie

**Dodanie na mapę**:
1. Przeciągnij `pallet.tscn`
2. Ustaw pozycję
3. Gracz będzie mógł ją przesunąć strzałami

---

### Door (drzwi) - NIEUŻYWANE
**Status**: Kod istnieje ale **nie jest używany** w grze.

Poprzednio był pomysł żeby drzwi otwierały się pod określone warunki, ale został zastąpiony przez Level End Area, które jest prostsze.

**Jeśli chcesz go aktywować**:
```gdscript
# Door oczekuje na gracz i zmienia scenę
func _on_body_entered(body: Player):
    SceneChanger.change_scene_smooth(next_level_path)
```

Ale jest to teraz **redundantne** - używamy Level End Area zamiast tego.

---

## Dodawanie nowych obiektów interaktywnych

### Szablon
```gdscript
extends Area2D
class_name NewInteractable

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
    if not body.is_in_group("player"):
        return
    
    # Tutaj logika - co się dzieje gdy gracz dotknie
    trigger()

func trigger() -> void:
    # Tutaj implementacja
    pass
```

### Kroki
1. Utwórz nową scenę w `/scenes/interactables/twoj_obiekt/`
2. Root: Area2D lub RigidBody2D
3. Dodaj Sprite2D, CollisionShape2D
4. Utwórz skrypt `twoj_obiekt.gd` extends Area2D/RigidBody2D
5. Zaimplementuj logikę
6. Testuj na mapie: F6

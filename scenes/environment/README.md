# Environment (Elementy scenerii)

Obiekty które stanowią świat gry - ściany, tereny, strefy niebezpieczne itp.

## Obiekty scenerii

### Wall (ściana)
**Przeznaczenie**: Budowanie map - przeszkody fizyczne.

**Jak działa**:
- To StaticBody2D (nie porusza się, ale ma fizykę)
- Gracz odbija się od niej przy uderzeniu
- Można zmienić rozmiar bez edytowania collisiona

**Parametry w Inspector**:
```
Size: Vector2(100, 20)  - Szerokość i wysokość
```

**Zmiana rozmiaru**:
- Zmień `Size` w Inspector
- ColorRect (grafika) i CollisionShape2D automatycznie się updatuje

**Dodanie na mapę**:
1. Przeciągnij `wall.tscn`
2. W Inspector zmień `Size` na odpowiednie wymiary
3. Pozycjonuj na mapie - gotowe!

**Kod**:
```gdscript
# Wall ma @tool - aktualizuje się w edytorze bez uruchamiania gry
@export var size: Vector2 = Vector2(100, 20):
    set(value):
        size = value
        _update_wall()  # Automatic update
```

---

### Hazard Area (strefa niebezpieczna)
**Przeznaczenie**: Strefy śmiertelne - dotyk = restart poziomu.

**Jak działa**:
- Area2D z fizyczną detekcją
- Gdy gracz ją dotknie → `GameManager.restart_current_level()`
- Wizualizuje się na czerwono w edytorze

**WAŻNE - wymaganie**: **Musi mieć dziecko CollisionPolygon2D**

To jest kluczowe - HazardArea nie ma swojego collisiona. Musisz dodać Polygon2D jako dziecko.

**Jak stworzyć HazardArea na mapie**:

1. Przeciągnij `hazard_area.tscn`
2. **Dodaj dziecko CollisionPolygon2D**:
   - Prawy klik na HazardArea → Add Child Node
   - Szukaj "CollisionPolygon2D"
   - Dodaj
3. **Narysuj polygon**:
   - Zaznacz CollisionPolygon2D
   - W edytorze 2D będzie przycisk "Edit Polygon" (lub Edit Mode)
   - Klikaj na canvas aby dodać punkty wielokąta
   - Minimum 3 punkty (trójkąt)
   - Zamknij polygon - Double Click lub Ctrl+Click na pierwszy punkt
4. **Widok w edytorze**:
   - HazardArea automatycznie rysuje się na czerwono
   - Pokazuje dokładnie gdzie będzie strefa niebezpieczna
5. **Testowanie**: F6 na scenie - gracz wchodzi w czerwony obszar = restart

**Zaawansowane - Polygon2D a CollisionPolygon2D**:
- **CollisionPolygon2D**: Fizykę, detektuje kolizje (to czego potrzebujemy)
- **Polygon2D**: Rysuje się na ekranie (visual shape)

HazardArea czyta CollisionPolygon2D i rysuje go wizualnie.

**Kod - jak to działa**:
```gdscript
@tool  # Działa w edytorze
extends Area2D
class_name HazardArea

func _draw() -> void:
    # Rysuje wszystkie CollisionPolygon2D na czerwono
    for child in get_children():
        if child is CollisionPolygon2D:
            draw_colored_polygon(child.polygon, Color.RED)

func _get_configuration_warnings() -> PackedStringArray:
    # Ostrzeżenie w edytorze: "brakuje Polygon!"
    if not _has_polygon():
        return ["HazardArea requires CollisionPolygon2D with valid polygon"]
```

**Ostrzeżenie w edytorze**:
- Jeśli HazardArea nie ma CollisionPolygon2D dziecka
- Zobaczysz żółty warning: "HazardArea requires at least one CollisionPolygon2D"
- Dodaj je!

**Przykład użycia**:
- Strefa toksyczna na mapie
- Strefa gorącej lawy
- Brzeg przepaści
- Dowolna strefa gdzie gracz umiera

---

## Dodawanie nowych elementów scenerii

### Wall-like obiekty (prostokątne)

Jeśli chcesz element ze zmiennym rozmiarem jak Wall:

```gdscript
@tool
extends StaticBody2D

@export var size: Vector2 = Vector2(100, 100):
    set(value):
        size = value
        if Engine.is_editor_hint():
            _update_shape()

func _update_shape():
    # Updatuj CollisionShape2D i ColorRect
    pass
```

### Polygon-based obiekty (dowolny kształt)

Jeśli chcesz element ze skomplikowanym kształtem jak HazardArea:

```gdscript
@tool
extends Area2D

func _draw():
    for child in get_children():
        if child is CollisionPolygon2D:
            # Rysuj polygon
            pass
```

---

## Tips

- **HazardArea musi mieć dziecko CollisionPolygon2D** - to jest wymóg!
- Minimum 3 punkty w polygonie (trójkąt)
- W edytorze polygon pokazuje się na czerwono (visual feedback)
- @tool atrybuty działają w edytorze - przydatne do szybkiego testowania bez uruchamiania gry

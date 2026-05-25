# Shaders (Efekty wizualne)

Specjalne efekty graficzne napisane w GLSL (OpenGL Shading Language). Shaders działają na GPU i modyfikują jak piksele są renderowane - to pozwala na zaawansowane efekty wizualne bez spadku wydajności.

---

## blueprint.gdshader - Efekt siatki

Rysuje na ekranie siatkę - efekt jak papier w kratę. Tło wygląda profesjonalnie.

### Gdzie się używa

- **Menu główne** - Tło menu ma efekt siatki
- **Ekran końcowy** - Efekt siatki za statystykami
- **Ekrany pauzy** - Dekoracyjnie

### Jak działa

Kod uproszczony:
```glsl
void fragment() {
    // Pozycja piksela na ekranie
    vec2 pos = FRAGCOORD.xy / SCREEN_PIXEL_SIZE;
    
    // Linie poziome i pionowe co N pikseli
    float grid_size = 40.0;
    float line_thickness = 1.0;
    
    // Sprawdź czy jesteś na linii
    float grid = mod(pos.x, grid_size) + mod(pos.y, grid_size);
    
    if (grid < line_thickness) {
        COLOR = vec4(0.2, 0.2, 0.2, 0.5);  // Szara linia
    } else {
        COLOR = vec4(0.1, 0.1, 0.1, 1.0);  // Ciemne tło
    }
}
```

### Parametry (edytor → Shader Properties)

```gdscript
@export var grid_size: float = 40.0      # Odstęp między liniami
@export var line_thickness: float = 1.0  # Grubość linii
@export var line_color: Color = Color.GRAY
@export var bg_color: Color = Color.BLACK
```

---

## vignette.gdshader - Przyciemnienie brzegów

Efekt który przyciemnia brzegi ekranu - jak tunel. Zwraca uwagę na centrum ekranu.

### Gdzie się używa

- **Menu główne** - Subtelne przyciemnienie
- **Ekrany informacyjne** - Zwiększa fokus
- **Opcjonalnie na HUD** - Dramatyczne efekty

### Jak działa

Kod uproszczony:
```glsl
void fragment() {
    // Znormalizowana pozycja piksela (0 do 1)
    vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE / SCREEN_PIXEL_SIZE;
    
    // Odległość od centrum
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);
    
    // Vignette gradient
    float vignette = 1.0 - (dist * dist * 2.0);
    vignette = clamp(vignette, 0.0, 1.0);
    
    // Otrzymany obraz * vignette (przyciemnia brzegi)
    COLOR = texture(SCREEN_TEXTURE, SCREEN_UV) * vignette;
}
```

### Parametry

```gdscript
@export var vignette_intensity: float = 0.8  # 0.0 (nie widać) do 1.0 (max ciemno)
@export var vignette_radius: float = 1.2     # Promień efektu
@export var vignette_softness: float = 1.5   # Jak miękko stopniuje się przejście
```

---

## background_blur.gdshader - Rozmycie tła

Rozmywa całe tło - efekt jak szklanka zaparowana. Zwiększa czytelność interfejsu na wierzchu.

### Gdzie się używa

- **Menu pauzy** - Rozmywa grę w tle
- **Dialogi/Popupy** - Rozmywa tło za oknem
- **Fade effecty** - Tło rozmywa się gdy pojawia się menu

### Jak działa

Kod uproszczony (Gaussian blur):
```glsl
void fragment() {
    vec2 blur_amount = vec2(1.0 / SCREEN_PIXEL_SIZE.x, 1.0 / SCREEN_PIXEL_SIZE.y) * blur_size;
    
    // Próbkuj sąsiednie piksele i uśrednij
    vec4 color = vec4(0.0);
    for (int i = -5; i <= 5; i++) {
        for (int j = -5; j <= 5; j++) {
            vec2 offset = vec2(float(i), float(j)) * blur_amount;
            color += texture(SCREEN_TEXTURE, SCREEN_UV + offset);
        }
    }
    
    COLOR = color / (11.0 * 11.0);  // Uśredniaj
}
```

**Ostrzeżenie**: Blur jest **drogi** obliczeniowo - używaj oszczędnie, tylko gdy konieczny.

### Parametry

```gdscript
@export var blur_size: float = 4.0  # Siła rozmycia (większe = bardziej rozmyte)
```

---

## Jak stosować shader do elementu

### Metoda 1: Na Sprite2D

```
1. Zaznacz Sprite2D node
2. Inspector → Material → New ShaderMaterial
3. Shader Material → Shader → Wybierz shader (res://shaders/blueprint.gdshader)
4. Parametry wyświetlą się w Inspector
```

### Metoda 2: Na Control/Panel (UI)

```
1. Zaznacz Control/Panel node
2. Inspector → Material → New ShaderMaterial
3. Shader Material → Shader → Wybierz shader
4. Ustaw parametry
```

### Metoda 3: Globalnie (cały ekran)

```gdscript
# W skrypcie
func _ready():
    var shader_mat = ShaderMaterial.new()
    shader_mat.shader = load("res://shaders/blueprint.gdshader")
    
    # Dostosuj ekran
    get_viewport().set_canvas_transform_override(Transform2D())
    
    # Lub nałóż na Layer
    var layer = CanvasLayer.new()
    layer.material = shader_mat
    add_child(layer)
```

---

## Performance Tips

| Shader | Cost | Gdzie | Rada |
|--------|------|-------|------|
| blueprint | Bardzo niska | Menu, statyczne | Bezpieczny - używaj zawsze |
| vignette | Niska | Menu, pauza | OK - nie spada FPS |
| blur | Wysoka | Dialogi, popup | Ostrożnie - może spowolnić na starym sprzęcie |

**Benchmark na Ubuntu:**
- blueprint: 60 FPS (bez upadku)
- vignette: 60 FPS (bez upadku)
- blur (size=4): 55 FPS (słaby spadek)
- blur (size=8): 40 FPS (duży spadek)

Dla szkoły: **blueprint i vignette można używać wszędzie, blur oszczędnie**.

---

## Edycja shader'ów

Shader to plik tekstowy - można edytować w VS Code.

### Struktura shader'u GDShader

```glsl
shader_type canvas_item;  // Shader dla 2D canvas

// Parametry (widoczne w Inspector)
@export var intensity: float = 1.0;

// main function - wołana dla każdego piksela
void fragment() {
    // color.rgb = wciągnij teksturę
    COLOR = texture(TEXTURE, UV);
    
    // Zastosuj effect
    COLOR *= intensity;
}
```

### Zmiana shader'u

1. Otwórz plik w edytorze (np. blueprint.gdshader)
2. Edytuj kod
3. Zapisz (Ctrl+S)
4. Godot przeładuje shader automatycznie
5. Efekt pojawi się natychmiast

---

## Tips

- Shaders wykonują się na GPU - są szybkie nawet na słabym sprzęcie
- `TEXTURE` - aktualna tekstura elementu
- `SCREEN_TEXTURE` - zawartość całego ekranu
- `UV` - mapowanie tekstury (0.0 do 1.0)
- `FRAGCOORD` - pozycja piksela na ekranie
- Zawsze testuj na twoim docelowym sprzęcie (starsze komputery szkolne!)

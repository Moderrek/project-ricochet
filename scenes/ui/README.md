# UI (Interfejs użytkownika)
Warstwa prezentacji nałożona na właściwą grę (HUD - Heads Up Display).

## Struktura
- `hud.tscn`: Wykorzystuje węzeł `CanvasLayer`, aby zawsze renderować się na wierzchu. Nasłuchuje na zdarzenia z `GameManager`.

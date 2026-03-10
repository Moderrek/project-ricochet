# Levels (Mapy)
Pliki scen definujące geometrię i logikę poszczególnych etapów gry.
Architektura mapy opiera się na koncepcji skierowanego grafu acyklicznego (DAG) z pobocznymi gałęziami (np. bufet)

## Struktura
- `base_level.tscn`: Klasa bazowa (szablon) dla wszystkich poziomów. Zawiera domyślne konfiguracje (kamery, itd). Wszystkie nowe poziomy muszą dziedziczyć z tej sceny.
- `level_0.tscn`: Wyjątkowy poziom gdzie gracz rozpoczyna rozgrywkę i jeszcze nie płynie czas.
- `level_test_tilemap.tscn`: Mapa testowa. Testuje tilemape.
- `level_test.tscn`: Mapa testowa. Testowanie wszystkiego.

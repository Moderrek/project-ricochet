# Project Ricochet

Edukacyjna, zręcznościowa gra logiczna 2D zbudowana na silniku Godot 4.6.1-stable.
Projekt stworzony z myślą o konkursie szkolnym, pełniący funkcję interaktywnej wizytówki CKZiU (Centrum Kształcenia Zawodowego i Ustawicznego w Łodzi).

## O grze i celu projektu

### Itegracja z profilem CKZiU
Projekt bezpośrednio nawiązuje do szkolnych realiów i kierunków kształcenia:
- **Eko Logistyk / Technik Logistyk / Spedytor**: Mechaniki fizycznego przepychania ciężkich ładunków (Europalet) oraz segregacji obiektów na mapie.
- **Technik Programista:** Poziomy oparte na zagadkach z bramkami logicznymi.
- **Technik Analityk / Weterynarii / Fotografii / Tekstronik:** Dedykowane strefy z unikalnymi wyzwaniami (np. omijanie stref toksycznych).
- **Lokacje Szkolne:** Odwzorowanie wirtualnej strzelnicy (minigra celownicza) oraz szkolnego bufetu (strefa regeneracji / zdobywania punktów *Boost*).
- **Patron:** Dyskretne nawiązania do patrona szkoły, Karola Wojtyły, oraz symboliczne wykorzystanie dat, takich jak *Dzień Liczby PI* (14 marca).

## Przewodnik po architekturze
Projekt został zorganizowany zgodnie z paradygmatami programowania obiektowe i zasadą pojedyńczej odpowiedzialności (SOLID).
Każdy podfolder zawiera plik informacyjny `README.md`.

- `/autoloads/`: Skrypty globalne (Menedżer gry, zarządzanie czasem, ekonomia monet, przejścia scen).
* `/scenes/entities/`: Obiekty dynamiczne z własną fizyką (np. zmotoryzowany Gracz ze wskaźnikiem trajektorii `aim_line`).
* `/scenes/interactables/`: Elementy interaktywne na mapie, takie jak automaty z kawą (system Boost), palety, drzwi i monety (Cez Coins).
* `/scenes/levels/`: Struktura świata gry. Mapy dziedziczą po klasie bazowej (`base_level`), pozwalając na nieliniową eksplorację.
* `/scenes/ui/`: Niezależna warstwa interfejsu użytkownika (HUD), komunikująca się z resztą gry wyłącznie poprzez **sygnały**.
* `/shaders/`: Autorskie programy GPU (np. `blueprint.gdshader`).
* `/assets/` & `/resources/`: Surowe grafiki, arkusze animacji, materiały oraz konfiguracje motywów Godota.

## Wydajność i aspekty inżynieryjne
Gra została zaprojektowana z rygorystycznym naciskiem na optymalizację, co pozwala na uruchomienie jej nawet na starszym sprzęcie szkolnym:

1. **Architektura Event-Driven:** Komponenty (np. interfejs użytkownika albo kamera) reagują wyłącznie na wyemitowane sygnały, a nie odpytują co każdą klatkę.
2. **Bezpieczna fizyka:** Instancjonowanie/destrukcja obiektów (np. znajdziek wypadających z automatu) jest kolejkowane na koniec klatki fizycznej. Skraca to czas klatki i eliminuje potencjalne crashe.
3. **Tweens:** Zamiast obiążać procesor węzłami `AnimationPlayer` dla każdego obiektu, gra używa lekkich, generowanychw kodzie interpolacji matematycznych (Tweens). Posiadają one wbudowane machanizmy niszczenia, co zapobiega nakładaniu się animacji.
4. **TileMap:** Sciany i przeszkoy korzystają z jednego, zoptymalizowanego węzła zamiast setek indywidualnych wezłów `StaticBody2D`.

## Licencja
Projekt udostępniony na licencji MIT.

# Autoloads (Singletony)
Ten folder zawiera skrypty ładowane globalnie przy starcie gry.

- `game_manager.gd`: Główny kontroler stanu gry (czas, monety, poziom zycia, poziom boosta)
- `scene_changer.gd`: Obsługuje płynne przejścia (fade in/out) między scenami
- `save_manager.gd`: Zarządza zapisem i odczytem postępów gracza na dysku (w przypadku HTML5 w IndexedDB)

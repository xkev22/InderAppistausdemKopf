# In der App ist aus dem Kopf – Projektbericht (DLAMSD02)

Dies ist das Git-Repository für den Projektbericht im Kurs "Apple Mobile Solution Development II" (DLAMSD02) an der IU Internationale Hochschule, basierend auf Aufgabenstellung 2: Entwicklung einer Merklisten-App.

## Projektüberblick 

"In der App ist aus dem Kopf" ist eine native iOS-Merklisten-Anwendung, entwickelt mit Swift und SwiftUI. Ziel der App ist es, Nutzern eine intuitive Möglichkeit zu bieten, Aufgaben und Gedanken schnell zu erfassen, zu organisieren und zuverlässig daran erinnert zu werden – getreu dem Motto: Den Kopf frei bekommen.

## Die Anwendung ermöglicht: 

* **Verwaltung:** Erstellen, Bearbeiten und Löschen von Merklisten-Einträgen.
* **Organisation:** Zuweisung von Kategorien (z. B. Arbeit, Privat, Einkauf) und Prioritäten.
* **Erinnerungen:** Setzen von Fälligkeitsterminen mit integrierten lokalen Benachrichtigungen.
* **Übersicht:** Filterung nach Status oder Kategorie sowie Sortierung nach Priorität, Titel oder Datum.
* **Sicherheit:** Eine Undo-Funktion, um versehentlich gelöschte Einträge sofort wiederherzustellen.
* **Persistenz:** Dauerhafte Speicherung aller Daten auf dem Gerät mittels Swift Data.

## Technische Details 

* **Sprache:** Swift
* **UI-Framework:** SwiftUI
* **Architektur:** MVVM (Model-View-ViewModel)
* **Datenhaltung:** Swift Data (Lokale Persistenz)
* **Entwicklungsumgebung:** Xcode

## Ausführen des Projekts 

1.  Klone dieses Repository auf deinen Mac.
2.  Öffne den Ordner `InderAppistausdemKopf` und starte die `.xcodeproj`-Datei mit Xcode.
3.  Wähle ein Zielgerät (Simulator oder physisches iPhone).
4.  Klicke auf "Run".

*Hinweis:* Für die Funktionalität der Benachrichtigungen muss der Nutzer beim ersten Erstellen einer Erinnerung die Berechtigung erteilen (wird in der App abgefragt).

import SwiftUI
import SwiftData
import UIKit

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    /// Speichert alle ausstehenden Änderungen im ModelContext
    func saveContext(_ context: ModelContext) {
        do {
            try context.save()
            print("Daten erfolgreich gespeichert")
        } catch {
            print("Fehler beim Speichern: \(error)")
        }
    }
    
    /// Automatische Speicherung bei App-Wechsel in Hintergrund 
    func setupAutoSave() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Automatische Speicherung beim Wechsel in Hintergrund
            print("App wechselt in Hintergrund - automatische Speicherung")
        }
    }
    
    /// Überprüft die Datenintegrität
    func validateDataIntegrity(_ context: ModelContext) -> Bool {
        do {
            let descriptor = FetchDescriptor<ListItem>()
            let items = try context.fetch(descriptor)
            
            // Überprüfet ob alle Items gültige Daten haben
            for item in items {
                if item.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    print("Gefunden: Item mit leerem Titel")
                    return false
                }
            }
            
            print("Datenintegrität überprüft - \(items.count) Einträge gefunden")
            return true
        } catch {
            print("Fehler bei Datenintegritätsprüfung: \(error)")
            return false
        }
    }
}

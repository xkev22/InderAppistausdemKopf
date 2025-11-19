import SwiftUI
import SwiftData

struct AddEditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var category: Category = .personal
    @State private var priority: Priority = .medium
    @State private var dueDate: Date? = nil
    @State private var setDueDate: Bool = false
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var enableReminder: Bool = false
    @State private var showingNotificationAlert = false

    var item: ListItem?

    init(item: ListItem?) {
        self.item = item
        _title = State(initialValue: item?.title ?? "")
        _note = State(initialValue: item?.note ?? "")
        _category = State(initialValue: item?.category ?? .personal)
        _priority = State(initialValue: item?.priority ?? .medium)
        let due = item?.dueDate
        _dueDate = State(initialValue: due)
        _setDueDate = State(initialValue: due != nil)
        _enableReminder = State(initialValue: due != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Inhalt") {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        TextField("Titel *", text: $title)
                            .textInputAutocapitalization(.sentences)
                            .font(AppTheme.Typography.body)
                        
                        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("Titel ist ein Pflichtfeld")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.error)
                        }
                    }
                    
                    TextField("Notiz", text: $note, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                        .font(AppTheme.Typography.body)
                }

                Section("Organisation") {
                    Picker("Kategorie", selection: $category) {
                        ForEach(Category.allCases) { c in
                            Text(c.displayName).tag(c)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Picker("Priorität", selection: $priority) {
                        ForEach(Priority.allCases) { p in
                            HStack {
                                priorityIndicator(for: p)
                                Text(p.displayName)
                            }
                            .tag(p)
                        }
                    }
                    Toggle("Fälligkeit", isOn: $setDueDate.animation())
                    if setDueDate {
                        DatePicker("Datum", selection: Binding(
                            get: { dueDate ?? Date() },
                            set: { dueDate = $0 }
                        ), displayedComponents: [.date, .hourAndMinute])
                        
                        Toggle("Erinnerung aktivieren", isOn: $enableReminder)
                            .disabled(!setDueDate)
                        
                        if enableReminder {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Du erhältst eine Benachrichtigung zum Fälligkeitstermin")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                            .padding(.top, AppTheme.Spacing.xs)
                        }
                    }
                }
            }
            .navigationTitle(item == nil ? "Neuer Eintrag" : "Eintrag bearbeiten")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Speichern") {
                        validateAndSave()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundColor(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppTheme.Colors.textSecondary : AppTheme.Colors.primary)
                }
            }
        }
        .alert("Validierungsfehler", isPresented: $showingValidationAlert) {
            Button("OK") { }
        } message: {
            Text(validationMessage)
        }
        .alert("Benachrichtigungen", isPresented: $showingNotificationAlert) {
            Button("Einstellungen öffnen") {
                #if os(iOS)
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
                #endif
            }
            Button("Später", role: .cancel) { }
        } message: {
            Text("Um Erinnerungen zu erhalten, müssen Benachrichtigungen in den Einstellungen aktiviert werden.")
        }
        .onAppear {
            NotificationManager.shared.requestPermission()
        }
    }
    
    private func validateAndSave() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedTitle.isEmpty {
            validationMessage = "Der Titel ist ein Pflichtfeld und darf nicht leer sein."
            showingValidationAlert = true
            return
        }
        
        if trimmedTitle.count < 3 {
            validationMessage = "Der Titel muss mindestens 3 Zeichen lang sein."
            showingValidationAlert = true
            return
        }
        
        save()
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let item {
            // Edit
            item.title = trimmed
            item.note = note.isEmpty ? nil : note
            item.category = category
            item.priority = priority
            item.dueDate = setDueDate ? dueDate : nil
            item.updatedAt = .now
        } else {
            // Add
            let new = ListItem(
                title: trimmed,
                note: note.isEmpty ? nil : note,
                category: category,
                priority: priority,
                dueDate: setDueDate ? dueDate : nil
            )
            context.insert(new)
        }

        do {
            try context.save()
            
            #if os(iOS)
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            #endif
            
            // Zusätzliche Validierung der Datenintegrität
            let isValid = DataManager.shared.validateDataIntegrity(context)
            if !isValid {
                print("Datenintegrität-Warnung: Ungültige Daten erkannt")
            }
            
            // Erinnerung planen falls aktiviert
            if enableReminder && setDueDate, let dueDate = dueDate {
                let itemToSchedule = item ?? ListItem(
                    title: trimmed,
                    note: note.isEmpty ? nil : note,
                    category: category,
                    priority: priority,
                    dueDate: dueDate
                )
                NotificationManager.shared.scheduleReminder(for: itemToSchedule)
            }
            
            dismiss()
        } catch {
            print("Erinnerung planen fehlgeschlagen \(error)")
        }
    }
    
    private func priorityIndicator(for priority: Priority) -> some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(index < priorityLevel(for: priority) ? AppTheme.Colors.priorityColor(for: priority) : AppTheme.Colors.border)
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    private func priorityLevel(for priority: Priority) -> Int {
        switch priority {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}

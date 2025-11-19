import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [ListItem]
    @State private var showingAddItem = false
    @State private var showingSuccessMessage = false
    @State private var deletedItem: ListItem?
    @State private var showingUndoMessage = false
    @State private var selectedCategory: Category? = nil
    @State private var sortOption: SortOption = .priority
    @State private var statusFilter: StatusFilter = .all
    
    private var items: [ListItem] {
        var filteredItems = allItems
        
        // Filter nach Kategorie
        if let selectedCategory = selectedCategory {
            filteredItems = filteredItems.filter { $0.category == selectedCategory }
        }
        
        // Filter nach Status
        switch statusFilter {
        case .all:
            break // Alle Items anzeigen
        case .open:
            filteredItems = filteredItems.filter { !$0.isDone }
        case .completed:
            filteredItems = filteredItems.filter { $0.isDone }
        }
        
        // Sortierung
        filteredItems.sort { item1, item2 in
            switch sortOption {
            case .priority:
                return item1.priority.sortIndex < item2.priority.sortIndex
            case .title:
                return item1.title.localizedCaseInsensitiveCompare(item2.title) == .orderedAscending
            case .dueDate:
                switch (item1.dueDate, item2.dueDate) {
                case (nil, nil): return false
                case (nil, _): return false
                case (_, nil): return true
                case (let date1?, let date2?): return date1 < date2
                }
            case .createdAt:
                return item1.createdAt > item2.createdAt
            }
        }
        
        return filteredItems
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter und Sortierung
                if !allItems.isEmpty {
                    FilterSortView(
                        selectedCategory: $selectedCategory,
                        sortOption: $sortOption,
                        statusFilter: $statusFilter
                    )
                }
                
                // Hauptinhalt
                Group {
                    if items.isEmpty {
                        if allItems.isEmpty {
                            emptyStateView
                        } else {
                            filteredEmptyStateView
                        }
                    } else {
                        listView
                    }
                }
            }
            .navigationTitle("Merkliste")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddEditItemView(item: nil)
            }
            .overlay(alignment: .top) {
                VStack(spacing: 0) {
                    if showingSuccessMessage {
                        successBanner
                            .padding(.top, 60)
                    } else if showingUndoMessage {
                        undoBanner
                            .padding(.top, 60)
                    }
                    Spacer()
                }
            }
            .onAppear {
                setupDataManager()
                NotificationManager.shared.clearDeliveredNotifications()
                NotificationManager.shared.clearBadgeCount()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.xxl) {
            // Icon mit Animation
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.6))
                .scaleEffect(1.0)
                .animation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true),
                    value: UUID()
                )
            
            VStack(spacing: AppTheme.Spacing.md) {
                Text("Willkommen bei deiner Merkliste!")
                    .font(AppTheme.Typography.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Organisiere deine Aufgaben und Ideen")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: AppTheme.Spacing.sm) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.success)
                        Text("Erstelle deinen ersten Eintrag")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundColor(AppTheme.Colors.categoryColor(for: .work))
                        Text("Organisiere mit Kategorien")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(AppTheme.Colors.primary)
                        Text("Setze Fälligkeitsdaten")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                .padding(.top, AppTheme.Spacing.sm)
            }
            
            Button(action: { showingAddItem = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Ersten Eintrag erstellen")
                }
            }
            .font(AppTheme.Typography.buttonMedium)
            .foregroundColor(.white)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.primary)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .scaleEffect(1.05)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: UUID()
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppTheme.Spacing.xxl)
    }
    
    private var filteredEmptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.xxl) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            VStack(spacing: AppTheme.Spacing.md) {
                Text("Keine Einträge gefunden")
                    .font(AppTheme.Typography.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                if let selectedCategory = selectedCategory {
                    Text("Keine Einträge in der Kategorie \(selectedCategory.displayName)")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Versuche andere Filtereinstellungen")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Button(action: { 
                selectedCategory = nil
                sortOption = .priority
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Filter zurücksetzen")
                }
            }
            .font(AppTheme.Typography.buttonMedium)
            .foregroundColor(AppTheme.Colors.textPrimary)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.secondary.opacity(0.2))
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppTheme.Spacing.xxl)
    }
    
    private var listView: some View {
        List {
            ForEach(items) { item in
                NavigationLink(destination: ItemDetailView(item: item)) {
                    ListItemRowView(item: item)
                }
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(PlainListStyle())
    }
    
    private var successBanner: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppTheme.Colors.success)
                .font(.title3)
            
            Text("Eintrag erfolgreich gespeichert!")
                .font(AppTheme.Typography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(AppTheme.Colors.successLight)
                .shadow(color: AppTheme.Colors.success.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, AppTheme.Spacing.lg)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(AppTheme.Animation.standard) {
                    showingSuccessMessage = false
                }
            }
        }
    }
    
    private var undoBanner: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Icon
            Image(systemName: "trash.circle.fill")
                .foregroundColor(.white)
                .font(.title2)
                .frame(width: 24, height: 24)
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text("Eintrag gelöscht")
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Tippen Sie auf Rückgängig, um den Vorgang rückgängig zu machen")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Rückgängig Button
            Button("Rückgängig") {
                undoDelete()
            }
            .font(AppTheme.Typography.subheadline)
            .fontWeight(.bold)
            .foregroundColor(AppTheme.Colors.error)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(.white)
            .cornerRadius(AppTheme.CornerRadius.small)
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                .fill(AppTheme.Colors.error)
                .shadow(color: AppTheme.Colors.error.opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, AppTheme.Spacing.lg)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(AppTheme.Animation.standard) {
                    showingUndoMessage = false
                    deletedItem = nil
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        guard let firstIndex = offsets.first else { return }
        let itemToDelete = items[firstIndex]
        NotificationManager.shared.cancelReminder(for: itemToDelete)
        deletedItem = itemToDelete
        
        withAnimation(AppTheme.Animation.standard) {
            modelContext.delete(itemToDelete)
            showingUndoMessage = true
            showingSuccessMessage = false
        }
        
        // Haptic Feedback für Löschung
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
    }
    
    private func undoDelete() {
        guard let item = deletedItem else { return }
        
        withAnimation(AppTheme.Animation.standard) {
            modelContext.insert(item)
            showingUndoMessage = false
            deletedItem = nil
        }
        
        // Haptic Feedback für Rückgängig
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        #endif
    }
    
    private func setupDataManager() {
        DataManager.shared.setupAutoSave()
    }
}

struct ListItemRowView: View {
    let item: ListItem
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack {
            Button(action: toggleDone) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isDone ? AppTheme.Colors.success : AppTheme.Colors.textSecondary)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(item.title)
                    .font(AppTheme.Typography.headline)
                    .lineLimit(1)
                    .strikethrough(item.isDone)
                    .foregroundColor(item.isDone ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)
                
                if let note = item.note, !note.isEmpty {
                    Text(note)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(2)
                        .strikethrough(item.isDone)
                }
                
                HStack {
                    Text(item.category.displayName)
                        .font(AppTheme.Typography.caption)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(AppTheme.Colors.categoryColorLight(for: item.category))
                        .foregroundColor(AppTheme.Colors.categoryColor(for: item.category))
                        .cornerRadius(AppTheme.CornerRadius.small)
                        .opacity(item.isDone ? 0.6 : 1.0)
                    
                    priorityIndicator
                        .opacity(item.isDone ? 0.6 : 1.0)
                    
                    if let dueDate = item.dueDate {
                            Text(dueDate, style: .date)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .opacity(item.isDone ? 0.6 : 1.0)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, AppTheme.Spacing.xs)
        .opacity(item.isDone ? 0.7 : 1.0)
    }
    
    private func toggleDone() {
        withAnimation(AppTheme.Animation.quick) {
            item.isDone.toggle()
            item.updatedAt = Date()
            
            // Wenn der Eintrag als erledigt markiert wird, entferne die Benachrichtigung
            if item.isDone {
                NotificationManager.shared.cancelReminder(for: item)
            }
            
            do {
                try modelContext.save()
                #if os(iOS)
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                #endif
            } catch {
                print("Error toggling done status: \(error)")
            }
        }
    }
    
    private var priorityIndicator: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(index < priorityLevel ? AppTheme.Colors.priorityColor(for: item.priority) : AppTheme.Colors.border)
                    .frame(width: 6, height: 6)
            }
        }
    }
    
    private var priorityLevel: Int {
        switch item.priority {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ListItem.self, inMemory: true)
}

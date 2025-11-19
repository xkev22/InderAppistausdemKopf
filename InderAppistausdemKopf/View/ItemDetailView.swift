import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    @State private var showingUndoMessage = false
    @State private var deletedItem: ListItem?
    
    let item: ListItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxl) {

                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text(item.title)
                        .font(AppTheme.Typography.title2)
                    
                    HStack {
                        Text(item.category.displayName)
                            .font(AppTheme.Typography.caption)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(AppTheme.Colors.categoryColorLight(for: item.category))
                            .foregroundColor(AppTheme.Colors.categoryColor(for: item.category))
                            .cornerRadius(AppTheme.CornerRadius.small)
                        
                        priorityIndicator
                        
                        Spacer()
                        
                        if item.isDone {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.Colors.success)
                                .font(.title2)
                        }
                    }
                }
                
                Divider()
            
                if let note = item.note, !note.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("Notiz")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Text(note)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .padding(AppTheme.Spacing.lg)
                            .background(AppTheme.Colors.backgroundSecondary)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                    }
                }
                
                
                if let dueDate = item.dueDate {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("Fälligkeitsdatum")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(AppTheme.Colors.primary)
                            Text(dueDate, style: .date)
                                .font(AppTheme.Typography.body)
                            Text(dueDate, style: .time)
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        .padding(AppTheme.Spacing.lg)
                        .background(AppTheme.Colors.backgroundSecondary)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                    }
                }
                
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text("Details")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        HStack {
                            Text("Erstellt:")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            Spacer()
                            Text(item.createdAt, style: .date)
                                .font(AppTheme.Typography.subheadline)
                        }
                        
                        HStack {
                            Text("Zuletzt geändert:")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            Spacer()
                            Text(item.updatedAt, style: .date)
                                .font(AppTheme.Typography.subheadline)
                        }
                    }
                    .padding(AppTheme.Spacing.lg)
                    .background(AppTheme.Colors.backgroundSecondary)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }
                
                Spacer(minLength: 100)
            }
            .padding(AppTheme.Spacing.lg)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Zurück") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: { showingEditView = true }) {
                        Label("Bearbeiten", systemImage: "pencil")
                    }
                    
                    Button(action: { showingDeleteAlert = true }) {
                        Label("Löschen", systemImage: "trash")
                    }
                    .foregroundColor(.red)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            AddEditItemView(item: item)
        }
        .alert("Eintrag löschen", isPresented: $showingDeleteAlert) {
            Button("Löschen", role: .destructive) {
                deleteItem()
            }
            Button("Abbrechen", role: .cancel) { }
        } message: {
            Text("Möchten Sie diesen Eintrag wirklich löschen? Sie können die Aktion innerhalb von 5 Sekunden rückgängig machen.")
        }
        .overlay(alignment: .top) {
            if showingUndoMessage {
                undoBanner
            }
        }
    }
    
    private var priorityIndicator: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(index < priorityLevel ? AppTheme.Colors.priorityColor(for: item.priority) : AppTheme.Colors.border)
                    .frame(width: 8, height: 8)
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
    
    private var undoBanner: some View {
        HStack {
            Image(systemName: "trash.circle.fill")
                .foregroundColor(AppTheme.Colors.error)
            Text("Eintrag gelöscht")
                .font(AppTheme.Typography.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Button("Rückgängig") {
                undoDelete()
            }
            .font(AppTheme.Typography.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(AppTheme.Colors.primary)
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.errorLight)
        .cornerRadius(AppTheme.CornerRadius.medium)
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
    
    private func deleteItem() {
        NotificationManager.shared.cancelReminder(for: item)

        deletedItem = item
        
        withAnimation(AppTheme.Animation.standard) {
            modelContext.delete(item)
            showingUndoMessage = true
        }
        
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
    
    private func undoDelete() {
        guard let item = deletedItem else { return }
        
        withAnimation(AppTheme.Animation.standard) {
            modelContext.insert(item)
            showingUndoMessage = false
            deletedItem = nil
        }

        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        #endif
    }
}

#Preview {
    NavigationStack {
        ItemDetailView(item: ListItem(
            title: "Beispiel Eintrag",
            note: "Dies ist eine Beispiel-Notiz für die Detailansicht.",
            category: .work,
            priority: .high,
            dueDate: Date().addingTimeInterval(86400)
        ))
    }
}

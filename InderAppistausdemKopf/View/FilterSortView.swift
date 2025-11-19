import SwiftUI

struct FilterSortView: View {
    @Binding var selectedCategory: Category?
    @Binding var sortOption: SortOption
    @Binding var statusFilter: StatusFilter
    
    var body: some View {
        HStack {
            // Filter Button
            Menu {
                Button("Alle Kategorien") {
                    selectedCategory = nil
                }
                
                ForEach(Category.allCases) { category in
                    Button(category.displayName) {
                        selectedCategory = category
                    }
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text(selectedCategory?.displayName ?? "Alle Kategorien")
                        .lineLimit(1)
                }
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(selectedCategory != nil ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .fill(selectedCategory != nil ? AppTheme.Colors.primary.opacity(0.1) : AppTheme.Colors.backgroundSecondary)
                )
            }
            
            // Status Filter Button
            Menu {
                ForEach(StatusFilter.allCases) { status in
                    Button(status.displayName) {
                        statusFilter = status
                    }
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: statusFilter.icon)
                    Text(statusFilter.displayName)
                        .lineLimit(1)
                }
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(statusFilter != .all ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .fill(statusFilter != .all ? AppTheme.Colors.primary.opacity(0.1) : AppTheme.Colors.backgroundSecondary)
                )
            }
            
            Spacer()
            
            // Sort Button
            Menu {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: { sortOption = option }) {
                        HStack {
                            Text(option.displayName)
                            if sortOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(sortOption.displayName)
                }
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .fill(AppTheme.Colors.backgroundSecondary)
                )
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.sm)
    }
}

enum StatusFilter: CaseIterable, Identifiable {
    case all
    case open
    case completed
    
    var id: String { rawValue }
    
    var rawValue: String {
        switch self {
        case .all: return "all"
        case .open: return "open"
        case .completed: return "completed"
        }
    }
    
    var displayName: String {
        switch self {
        case .all: return "Alle"
        case .open: return "Offen"
        case .completed: return "Erledigt"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .open: return "circle"
        case .completed: return "checkmark.circle.fill"
        }
    }
}

enum SortOption: CaseIterable {
    case priority
    case title
    case dueDate
    case createdAt
    
    var displayName: String {
        switch self {
        case .priority: return "Priorität"
        case .title: return "Titel"
        case .dueDate: return "Fälligkeit"
        case .createdAt: return "Erstellt"
        }
    }
    
    var sortDescriptor: SortDescriptor<ListItem> {
        switch self {
        case .priority:
            return SortDescriptor(\ListItem.priority.sortIndex, order: .forward)
        case .title:
            return SortDescriptor(\ListItem.title, order: .forward)
        case .dueDate:
            return SortDescriptor(\ListItem.dueDate, order: .forward)
        case .createdAt:
            return SortDescriptor(\ListItem.createdAt, order: .reverse)
        }
    }
}

#Preview {
    FilterSortView(
        selectedCategory: .constant(nil),
        sortOption: .constant(.priority),
        statusFilter: .constant(.all)
    )
}

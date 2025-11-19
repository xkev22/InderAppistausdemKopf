import SwiftUI

struct AppTheme {
    
    struct Colors {
        static let primary = Color.blue
        
        static let secondary = Color.gray
        
        static let background = Color(.systemBackground)
        static let backgroundSecondary = Color(.secondarySystemBackground)
        
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        
        static let success = Color.green
        static let successLight = Color.green.opacity(0.1)
        static let error = Color.red
        static let errorLight = Color.red.opacity(0.1)
        
        static let border = Color.gray.opacity(0.3)
    }
    
    
    struct Typography {

        static let title2 = Font.title2.weight(.semibold)

        static let headline = Font.headline.weight(.semibold)
        static let body = Font.body

        static let subheadline = Font.subheadline
        static let caption = Font.caption

        static let buttonMedium = Font.body.weight(.medium)
    }
    
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xxl: CGFloat = 24
    }
    
    struct CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
    }
    
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
    }
}

extension AppTheme.Colors {
    static func categoryColor(for category: Category) -> Color {
        switch category {
        case .work: return Color.blue
        case .personal: return Color.green
        case .shopping: return Color.orange
        case .household: return Color.purple
        case .appointments: return Color.red
        case .other: return Color.gray
        }
    }
    
    static func categoryColorLight(for category: Category) -> Color {
        return categoryColor(for: category).opacity(0.2)
    }
}

extension AppTheme.Colors {
    static func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .high: return Color.red
        case .medium: return Color.orange
        case .low: return Color.green
        }
    }
}

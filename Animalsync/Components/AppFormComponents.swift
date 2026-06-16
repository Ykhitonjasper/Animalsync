import SwiftUI

struct AppFormSection<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            SectionHeader(title: title, subtitle: subtitle)
            VStack(spacing: 0) {
                content()
            }
            .glassBg(padding: 0, material: .thinMaterial)
        }
    }
}

struct AppFormTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption.weight(.bold))
                .tracking(0.4)
                .foregroundStyle(Color.appBrand)
            TextField(placeholder, text: $text)
                .font(.body)
                .keyboardType(keyboardType)
        }
        .padding(AppTheme.spacingMD)
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.appBorder)
        }
    }
}

struct AppFormPicker<Selection: Hashable, Content: View>: View {
    let label: String
    @Binding var selection: Selection
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.caption.weight(.bold))
                .tracking(0.4)
                .foregroundStyle(Color.appBrand)
            Picker(label, selection: $selection) {
                content()
            }
            .pickerStyle(.menu)
            .tint(Color.appBrand)
        }
        .padding(AppTheme.spacingMD)
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.appBorder)
        }
    }
}

struct AppFormDatePicker: View {
    let label: String
    @Binding var date: Date
    var maxDate: Date? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.caption.weight(.bold))
                .tracking(0.4)
                .foregroundStyle(Color.appBrand)
            if let maxDate {
                DatePicker(label, selection: $date, in: ...maxDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .tint(Color.appBrand)
            } else {
                DatePicker(label, selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .tint(Color.appBrand)
            }
        }
        .padding(AppTheme.spacingMD)
    }
}

struct AppFormToggle: View {
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appMuted)
                }
            }
        }
        .tint(Color.appBrand)
        .padding(AppTheme.spacingMD)
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.appBorder)
        }
    }
}

struct AppFormStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        Stepper(value: $value, in: range) {
            Text(title)
                .font(.body.weight(.semibold))
        }
        .tint(Color.appBrand)
        .padding(AppTheme.spacingMD)
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.appBorder)
        }
    }
}

struct AppFormInfoRow: View {
    let title: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            Spacer()
            Text(value)
                .font(.body.weight(.semibold))
                .foregroundStyle(valueColor)
        }
        .padding(AppTheme.spacingMD)
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.appBorder)
        }
    }
}

struct AppFormButton: View {
    let title: String
    var icon: String? = nil
    var role: ButtonRole? = nil
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(role: role, action: action) {
            HStack {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.body.weight(.semibold))
                Spacer()
                if isLoading {
                    ProgressView()
                } else if role == nil {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appMuted)
                }
            }
            .foregroundStyle(role == .destructive ? .red : Color.appBrand)
            .padding(AppTheme.spacingMD)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.appBorder)
        }
    }
}

struct AppFormNavigationRow<Destination: View>: View {
    let title: String
    var icon: String
    var subtitle: String? = nil
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 14) {
                AppIconBadge(symbol: icon, size: 36, tint: .appBrand)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color.appMuted)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appMuted)
            }
            .padding(AppTheme.spacingMD)
        }
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.appBorder)
        }
    }
}

struct AppFormLinkRow: View {
    let title: String
    let icon: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 14) {
                AppIconBadge(symbol: icon, size: 36, tint: .appBrand)
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appMuted)
            }
            .padding(AppTheme.spacingMD)
        }
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.appBorder)
        }
    }
}

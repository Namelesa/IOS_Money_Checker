import SwiftUI

struct SettingsView: View {
    @State private var syncPeriod: String = "Daily"
    @State private var enableNotifications: Bool = UserDefaults.standard.bool(forKey: "enableNotifications")
    @Binding var transactionCount: Int

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                VStack(alignment: .leading, spacing: 15) {
                    Text("Sync Period")
                        .font(.headline)
                    Picker("Sync Period", selection: $syncPeriod) {
                        Text("Daily").tag("Daily")
                        Text("Weekly").tag("Weekly")
                        Text("Monthly").tag("Monthly")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 15) {
                    Text("Notifications")
                        .font(.headline)
                    Toggle("Enable Notifications", isOn: $enableNotifications)
                        .onChange(of: enableNotifications) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "enableNotifications")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 15) {
                    Text("Transactions Count")
                        .font(.headline)
                    Picker("Transactions Count", selection: $transactionCount) {
                        ForEach(1...10, id: \.self) { count in
                            Text("\(count)").tag(count)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
        }
    }
}

#Preview {
    SettingsView(transactionCount: .constant(5))
}

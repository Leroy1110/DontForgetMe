import SwiftUI

struct ContentView: View {
    @StateObject private var manager = ItemManager()
    
    // Holds the user‑typed name for a new category.
    @State private var newCategoryName = ""
    
    // Persist notification time in UserDefaults so it survives relaunches.
    @AppStorage("notificationHour") private var notificationHour: Int = 7
    @AppStorage("notificationMinute") private var notificationMinute: Int = 30
    
    @State private var selectedTime = Date()
    @State private var showTimePicker = false


    var body: some View {
        NavigationView {
            VStack {
                // List of categories
                List {
                    ForEach(manager.categories) { category in
                        // Navigate to the items view for the selected category.
                        NavigationLink(destination: CategoryView(category: category, manager: manager)) {
                            Text(category.name)
                        }
                    }
                    .onDelete { indexSet in
                        // Allow swipe‑to‑delete on categories.
                        manager.categories.remove(atOffsets: indexSet)
                    }
                }
                
                // Global reminder time button
                Button(action: {
                    showTimePicker.toggle()
                }) {
                    Label("Change General Reminder Time", systemImage: "clock")
                }
                
                // Add new category
                HStack {
                    TextField("New Category", text: $newCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        if !newCategoryName.isEmpty {
                            manager.addCategory(named: newCategoryName)
                            newCategoryName = ""
                        }
                    }
                }
                .padding()
                
                // Time picker
                if showTimePicker {
                    DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .onChange(of: selectedTime) { newValue in
                            let calendar = Calendar.current
                            notificationHour = calendar.component(.hour, from: newValue)
                            notificationMinute = calendar.component(.minute, from: newValue)
                            
                            // Remove any existing scheduled notifications
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            
                            // Schedule new daily notification
                            NotificationManager.instance.scheduleDailyNotification(
                                at: notificationHour,
                                minute: notificationMinute,
                                title: "Don't Forget Me!",
                                body: "Check that you marked all your items for today"
                            )
                        }
                }
            }
            .navigationTitle("Don't Forget Me")
            .onAppear {
                // Ask for notification permission once at launch
                NotificationManager.instance.requestAuthorization()
                
                // Schedule (or reschedule) the daily notification at saved time
                NotificationManager.instance.scheduleDailyNotification(
                    at: notificationHour,
                    minute: notificationMinute,
                    title: "Don't Forget Me!",
                    body: "Check that you marked all your items for today"
                )
                // Sync the picker with saved time
                selectedTime = Calendar.current.date(bySettingHour: notificationHour, minute: notificationMinute, second: 0, of: Date()) ?? Date()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


import SwiftUI

struct ContentView: View {
    @StateObject private var manager = ItemManager()
    @State private var newCategoryName = ""
    @AppStorage("notificationHour") private var notificationHour: Int = 7
    @AppStorage("notificationMinute") private var notificationMinute: Int = 30
    @State private var selectedTime = Date()
    @State private var showTimePicker = false


    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(manager.categories) { category in
                        NavigationLink(destination: CategoryView(category: category, manager: manager)) {
                            Text(category.name)
                        }
                    }
                    .onDelete { indexSet in
                        manager.categories.remove(atOffsets: indexSet)
                    }
                }
                Button(action: {
                    showTimePicker.toggle()
                }) {
                    Label("שנה שעת תזכורת כללית", systemImage: "clock")
                }
                HStack {
                    TextField("קטגוריה חדשה (למשל: בית ספר)", text: $newCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("הוסף") {
                        if !newCategoryName.isEmpty {
                            manager.addCategory(named: newCategoryName)
                            newCategoryName = ""
                        }
                    }
                }
                .padding()
                
                if showTimePicker {
                    DatePicker("בחר שעה", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .onChange(of: selectedTime) { newValue in
                            let calendar = Calendar.current
                            notificationHour = calendar.component(.hour, from: newValue)
                            notificationMinute = calendar.component(.minute, from: newValue)
                            
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            
                            NotificationManager.instance.scheduleDailyNotification(
                                at: notificationHour,
                                minute: notificationMinute,
                                title: "Don't Forget Me!",
                                body: "בדוק אם סימנת את כל הפריטים שלך להיום"
                            )
                        }
                }
            }
            .navigationTitle("Don't Forget Me")
            .onAppear {
                NotificationManager.instance.requestAuthorization()
                NotificationManager.instance.scheduleDailyNotification(
                    at: notificationHour,
                    minute: notificationMinute,
                    title: "Don't Forget Me!",
                    body: "בדוק אם סימנת את כל הפריטים שלך להיום"
                )
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


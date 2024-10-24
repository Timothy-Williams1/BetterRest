//
//  ContentView.swift
//  BetterRest
//
//  Created by Student on 10/16/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepeAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
   static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        
        NavigationStack{
            
            Form {
                // Challenge 1
                Section("When do you want to wake up?"){
                    DatePicker("Please enter a date", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                // Challenge 1
                Section("Desierd amount of sleep"){
                    Stepper("\(sleepeAmount.formatted()) hours", value: $sleepeAmount, in: 4...12, step: 0.25)
                }
                
                // Challenge 1
                Section("Daily coffee intake"){
                    //Challenge 2
                    Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeeAmount) {
                        ForEach(0..<21) {
                            Text("\($0)")
                        }
                    }
                }
            }
            
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            
            .alert(alertTitle, isPresented: $showingAlert) {
                Button ("Ok") { }
            } message: {
                Text(alertMessage)
//            Text(Date.now.formatted(date: .long, time: .shortened))
        }
    }
}

    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let modle = try SleepCalculater(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try modle.prediction(wake: Double(hour + minute), estimatedSleep: sleepeAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "your ideal time is ..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showingAlert = true
    }
}
//    func exampleDates() {
//        var components = DateComponents()
//        components.hour = 8
//        components.minute = 0
//        let date = Calendar.current.date(from: components) ?? .now
#Preview {
    ContentView()
}

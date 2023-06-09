//
//  ContentView.swift
//  BetterRest
//
//  Created by Tamim Khan on 15/4/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    
    @State private var alertTitle = ""
    @State private var alertMessege = ""
    @State private var showingAlert = false
    
    
   static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
        
    }
    
    
    var body: some View {
        NavigationView{
           Form{
               VStack(alignment: .leading, spacing: 0){
                   Text("When do you want to wake up?")
                       .font(.headline)
                   
                   DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                       .labelsHidden()
               }
               VStack(alignment: .leading, spacing: 0){
                   Text("Desired amount of sleep")
                       .font(.headline)
                   
                   Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
               }
               VStack(alignment: .leading, spacing: 0){
                   Text("Daily coffee intake")
                       .font(.headline)
                   
//                   Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                   
                   Picker("Number of cups", selection: $coffeeAmount) {
                               ForEach(1...20, id: \.self) { count in
                                   Text("\(count) cup\(count == 1 ? "" : "s")")
                               }
                           }
                           .pickerStyle(MenuPickerStyle())
               }
            }
            
            .navigationTitle("Betterrest")
            .toolbar{
                Button("calculate", action: calculatedBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlert){
                Button("ok"){}
            }message: {
                Text(alertMessege)
            }
        }
    }
    func calculatedBedTime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            
            alertTitle = "your ideal bed time is.."
            alertMessege = sleepTime.formatted(date: .omitted, time: .shortened)
            
            
        }catch{
            alertTitle = "Error"
            alertMessege = "There was a problem calculating your bed time"
        }
        showingAlert = true
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

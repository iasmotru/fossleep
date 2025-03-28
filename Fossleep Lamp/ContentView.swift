//
//  ContentView.swift
//  Fossleep Lamp
//
//  Created by Мария Денисовна on 27.03.2025.
//

import SwiftUI
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Connect to the discovered peripheral
        self.peripheral = peripheral
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Discover services
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("Failed to connect: \(error.localizedDescription)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        if let services = peripheral.services {
            for service in services {
                // Discover characteristics for each service
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        if let characteristics = service.characteristics {
            for _ in characteristics {
                // Handle discovered characteristics
            }
        }
    }
}

struct SplashScreenView: View {
    var body: some View {
        VStack {
            Image("Splash")
                .resizable()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView: View {
    @State private var showSplash = true
    @State private var selectedColor: Color = .white
    @State private var intensity: Double = 0.5
    @State private var turnOffTime: Date = Date()
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var connectionStatus: String = "Not Connected"

    var body: some View {
        if showSplash {
            SplashScreenView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSplash = false
                        }
                    }
                }
        } else {
            VStack {
                
                VStack{
                    Text(connectionStatus)
                        .padding()
                    
                    Button("ПОДКЛЮЧИТЬ ЛАМПУ") {
                        bluetoothManager.startScanning()
                        connectionStatus = "Connecting..."
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .foregroundColor(Color("Light0"))
                    .fontWeight(.semibold)
                    .background(Color("Green500"))}
                .padding()
                .background(Color("Light100"))
                

                VStack{
                    ColorPicker("Цвет лампы", selection: $selectedColor)
                        .padding()
                    
                    Slider(value: $intensity, in: 0...1, step: 0.1) {
                        Text("Intensity")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)}
                .padding()
                .foregroundColor(Color("Green500"))
                .background(Color("Light100"))

                VStack{
                    DatePicker("Время выключения", selection: $turnOffTime, displayedComponents: .hourAndMinute)
                        .padding()
                    
                    Button("УСТАНОВИТЬ ТАЙМЕР") {
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    .padding()
                    .foregroundColor(Color("Light0"))
                    .fontWeight(.semibold)
                    .background(Color("Green500"))}
                    .padding()
                    .background(Color("Light100"))
            }

            .padding()
            .background(Image("Background"))
            .edgesIgnoringSafeArea(.all)
            
        }
    }
    
}

#Preview {
    ContentView()
}

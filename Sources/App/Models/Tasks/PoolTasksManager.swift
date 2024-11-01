//
//  TaskManager.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 23.10.24.
//

struct PoolTasksManager {
    static func tasks(waterStatus: WaterStatus, poolStatus: PoolStatus) -> [PoolTask] {
        tasks(for: waterStatus) + tasks(for: poolStatus)
    }
    
    static func tasks(for waterStatus: WaterStatus) -> [PoolTask] {
        var tasks = [PoolTask]()
        
        if let phTask = PhTask(value: waterStatus.ph).create() {
            tasks.append(phTask)
        }
        
        if let chlorineTask = ChlorineTask(value: waterStatus.chlorine).create() {
            tasks.append(chlorineTask)
        }
        
        if let alkalinity = waterStatus.alkalinity,
           let alkalinityTask = AlkalinityTask(value: alkalinity).create() {
            tasks.append(alkalinityTask)
        }
        
        if let temperature = waterStatus.temperature,
           let temperatureTask = TemperatureTask(value: temperature).create() {
            tasks.append(temperatureTask)
        }
        
        return tasks
    }
    
    static func tasks(for poolStatus: PoolStatus) -> [PoolTask] {
        var tasks = [PoolTask]()
        
        if let skimTask = SkimTask(lastTimeDone: poolStatus.skimDate).task {
            tasks.append(skimTask)
        }
        
        if let vacuumTask = VacuumTask(lastTimeDone: poolStatus.vacuumDate).task {
            tasks.append(vacuumTask)
        }
        
        if let brushTask = BrushTask(lastTimeDone: poolStatus.brushDate).task {
            tasks.append(brushTask)
        }
        
        if let emptyBasketTask = EmptyBasketTask(lastTimeDone: poolStatus.emptyBasketsDate).task {
            tasks.append(emptyBasketTask)
        }
        
        if let testWaterTask = TestWaterTask(lastTimeDone: poolStatus.testWaterDate).task {
            tasks.append(testWaterTask)
        }
        
        if let cleanFilterTask = CleanFilterTask(lastTimeDone: poolStatus.cleanFilterDate).task {
            tasks.append(cleanFilterTask)
        }
        
        if let runPumpTask = RunPumpTask(lastTimeDone: poolStatus.runPumpDate).task {
            tasks.append(runPumpTask)
        }
        
        if let inspectTask = InspectTask(lastTimeDone: poolStatus.inspectDate).task {
            tasks.append(inspectTask)
        }
        
        return tasks
    }
}

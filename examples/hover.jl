using Crazyflie
using ProgressMeter

# temporary
using PyCall
using DelimitedFiles

function reset_estimator(cf)
    cf.param.set_value("kalman.resetEstimation", "1")
    sleep(0.1)
    cf.param.set_value("kalman.resetEstimation", "0")
    lconfig = logger.LogConfig(name="Kalman Variance", period_in_ms=500)
    lconfig.add_variable("kalman.varPX", "float")
    lconfig.add_variable("kalman.varPY", "float")
    lconfig.add_variable("kalman.varPZ", "float")
    varx = ones(10)*1000
    vary = ones(10)*1000
    varz = ones(10)*1000
    record(cf, lconfig) do logs
        for entry in logs
            data = entry[2]
            push!(varx, data["kalman.varPX"])
            push!(vary, data["kalman.varPY"])
            push!(varz, data["kalman.varPZ"])
            popfirst!(varx); popfirst!(vary); popfirst!(varz)
            threshx = (maximum(varx) - minimum(varx)) < 0.001
            threshy = (maximum(vary) - minimum(vary)) < 0.001
            threshz = (maximum(varz) - minimum(varz)) < 0.001
            if threshx && threshy && threshz
                break
            end
        end
    end
end

function enable_commander(cf)
    cf.param.set_value("commander.enHighLevel", "1")
    cf.high_level_commander
end

# because commander.land is not reliable
function land(commander, duration)
    print("Landing\n")
    for i = 1:10
        commander.land(0.0, duration)
        sleep(0.1)
    end
    sleep(duration)
    commander.stop()
end

# because commander.takeoff is not reliable
function takeoff(commander, height, duration)
    print("Taking Off\n")
    for i = 1:5
        commander.takeoff(height, duration)
        sleep(0.1)
    end
    sleep(duration)
end

function hover(uri="radio://0/80/2M")
    play(uri) do cf
        commander = enable_commander(cf)
        reset_estimator(cf)
        takeoff(commander, 1.0, 2.0) # height, duration
        sleep(5.0)
        land(commander, 5.0) # duration
    end
    return nothing
end

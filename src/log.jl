function record(alg, cf, lconfig)
    logs = synclogger.SyncLogger(cf, lconfig)
    logs.connect()
    try
        alg(logs)
    catch e
        @show e
        # Catch keyboard interrupts if desired
    end
    logs.disconnect()
end

function log_posn(uri=_first_available())
    play(uri) do cf
        lconfig = logger.LogConfig(name="Position", period_in_ms=100)
        lconfig.add_variable("stateEstimate.x", "float")
        lconfig.add_variable("stateEstimate.y", "float")
        lconfig.add_variable("stateEstimate.z", "float")
        record(cf, lconfig) do logs
            for entry in logs
                data = entry[2]
                print("x = ", data["stateEstimate.x"], ", ")
                print("y = ", data["stateEstimate.y"], ", ")
                print("z = ", data["stateEstimate.z"], "\n")
            end
        end
    end
end

function log_quat(uri=_first_available())
    play(uri) do cf
        lconfig = logger.LogConfig(name="Quaternion", period_in_ms=100)
        lconfig.add_variable("stateEstimate.qx", "float")
        lconfig.add_variable("stateEstimate.qy", "float")
        lconfig.add_variable("stateEstimate.qz", "float")
        lconfig.add_variable("stateEstimate.qw", "float")
        record(cf, lconfig) do logs
            for entry in logs
                data = entry[2]
                print("qx = ", data["stateEstimate.qx"], ", ")
                print("qy = ", data["stateEstimate.qy"], ", ")
                print("qz = ", data["stateEstimate.qz"], ", ")
                print("qw = ", data["stateEstimate.qw"], "\n")
            end
        end
    end
end

function log_config(uri=_first_available())
    play(uri) do cf
        lconfig = logger.LogConfig(name="Configuration", period_in_ms=100)
        lconfig.add_variable("stateEstimateZ.x", "int16_t")
        lconfig.add_variable("stateEstimateZ.y", "int16_t")
        lconfig.add_variable("stateEstimateZ.z", "int16_t")
        lconfig.add_variable("stateEstimate.qx", "float")
        lconfig.add_variable("stateEstimate.qy", "float")
        lconfig.add_variable("stateEstimate.qz", "float")
        lconfig.add_variable("stateEstimate.qw", "float")
        record(cf, lconfig) do logs
            for entry in logs
                data = entry[2]
                print("x = ", data["stateEstimateZ.x"]/100.0, ", ")
                print("y = ", data["stateEstimateZ.y"]/100.0, ", ")
                print("z = ", data["stateEstimateZ.z"]/100.0, ", ")
                print("qx = ", data["stateEstimate.qx"], ", ")
                print("qy = ", data["stateEstimate.qy"], ", ")
                print("qz = ", data["stateEstimate.qz"], ", ")
                print("qw = ", data["stateEstimate.qw"], "\n")
            end
        end
    end
end

#  function plot_state()
#  end

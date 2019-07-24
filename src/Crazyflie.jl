module Crazyflie

using PyCall

export scan, connect, disconnect, play
export bootloader, crtp, drivers, positioning, utils
export crazyflie, synccrazyflie, logger, synclogger, mem
export record, log_posn, log_quat, log_config
#  export reset_estimator, upload_traj, enable_commander
#  export land

export motor_ramp_test, log_posn, log_quat

const bootloader = PyNULL()
const crtp = PyNULL()
const drivers = PyNULL()
const positioning = PyNULL()
const utils = PyNULL()
const crazyflie = PyNULL()
const synccrazyflie = PyNULL()
const logger = PyNULL()
const synclogger = PyNULL()
const mem = PyNULL()

function __init__()
    copy!(bootloader, pyimport("cflib.bootloader"))
    copy!(crtp, pyimport("cflib.crtp"))
    copy!(drivers, pyimport("cflib.drivers"))
    copy!(positioning, pyimport("cflib.positioning"))
    copy!(utils, pyimport("cflib.utils"))
    copy!(crazyflie, pyimport("cflib.crazyflie"))
    copy!(synccrazyflie, pyimport("cflib.crazyflie.syncCrazyflie"))
    copy!(logger, pyimport("cflib.crazyflie.log"))
    copy!(synclogger, pyimport("cflib.crazyflie.syncLogger"))
    copy!(mem, pyimport("cflib.crazyflie.mem"))

    crtp.init_drivers(enable_debug_driver=false)
    nothing
end

function scan()
    available = crtp.scan_interfaces()
    if isempty(available)
        print("No crazyflies found.\n")
    end
    print("Found $(size(available, 1)) crazyflies:\n")
    for device in eachrow(available)
        print("\t" * device[1] * "\n")
    end
    nothing
end

function _first_available()
    available = crtp.scan_interfaces()
    if isempty(available)
        error("No crazyflies found. " *
              "Please specifiy a URI or try again. \n")
    end
    return available[1,1]
end

function connect(uri=_first_available())
    scf = synccrazyflie.SyncCrazyflie(uri, cf=crazyflie.Crazyflie(rw_cache="./cache"))
    scf.open_link()
    return scf
end

function play(alg, uri=_first_available())
    scf = connect(uri)
    try
        alg(scf.cf)
    catch e
        @show e
        # Catch keyboard interrupts if desired
    end
    disconnect(scf)
end

function disconnect(scf)
    scf.close_link()
    nothing
end
#
#  function upload_traj(cf, id, traj)
#      trajmem = cf.mem.get_mems(mem.MemoryElement.TYPE_TRAJ)[1]
#      total_duration = 0
#      for row in traj
#          duration = row[1]
#          x = mem.Poly4D.Poly(row[2:9])
#          y = mem.Poly4D.Poly(row[10:17])
#          z = mem.Poly4D.Poly(row[18:25])
#          yaw = mem.Poly4D.Poly(row[26:33])
#          push!(trajmem.poly4Ds, mem.Poly4D(duration, x, y, z, yaw))
#          total_duration += duration
#      end
#
#      py"""
#      import time
#      class Uploader:
#          def __init__(self):
#              self._is_done = False
#
#          def upload(self, trajectory_mem):
#              print('Uploading data')
#              trajectory_mem.write_data(self._upload_done)
#
#              while not self._is_done:
#                  time.sleep(0.2)
#
#          def _upload_done(self, mem, addr):
#              print('Data uploaded')
#              self._is_done = True
#      """
#      py"Uploader().upload($trajmem)"
#      cf.high_level_commander.define_trajectory(id, 0, length(trajmem.poly4Ds))
#      return total_duration
#  end
#
#  function reset_estimator(cf)
#      cf.param.set_value("kalman.resetEstimation", "1")
#      sleep(0.1)
#      cf.param.set_value("kalman.resetEstimation", "0")
#      lconfig = logger.LogConfig(name="Kalman Variance", period_in_ms=500)
#      lconfig.add_variable("kalman.varPX", "float")
#      lconfig.add_variable("kalman.varPY", "float")
#      lconfig.add_variable("kalman.varPZ", "float")
#      varx = ones(10)*1000
#      vary = ones(10)*1000
#      varz = ones(10)*1000
#      record(cf, lconfig) do logs
#          for entry in logs
#              data = entry[2]
#              push!(varx, data["kalman.varPX"])
#              push!(vary, data["kalman.varPY"])
#              push!(varz, data["kalman.varPZ"])
#              popfirst!(varx); popfirst!(vary); popfirst!(varz)
#              threshx = (maximum(varx) - minimum(varx)) < 0.001
#              threshy = (maximum(vary) - minimum(vary)) < 0.001
#              threshz = (maximum(varz) - minimum(varz)) < 0.001
#              if threshx && threshy && threshz
#                  break
#              end
#          end
#      end
#  end
#
#  function enable_commander(cf)
#      cf.param.set_value("commander.enHighLevel", "1")
#      cf.high_level_commander
#  end
#
#  # commander take off because commander.land is not reliable
#  function land(commander, duration)
#      print("Landing\n")
#      for i = 1:10
#          # keep sending land messages because
#          # it doesn't recieve it sometimes
#          commander.land(0.0, duration)
#          sleep(0.1)
#      end
#      sleep(duration)
#      commander.stop()
#  end

include("log.jl")
include("examples.jl")

end # module

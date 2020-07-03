onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fifo_81_50_opt

do {wave.do}

view wave
view structure
view signals

do {fifo_81_50.udo}

run -all

quit -force

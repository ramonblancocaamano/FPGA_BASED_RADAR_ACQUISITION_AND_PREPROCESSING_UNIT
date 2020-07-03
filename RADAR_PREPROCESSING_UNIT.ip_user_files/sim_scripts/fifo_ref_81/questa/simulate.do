onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fifo_ref_81_opt

do {wave.do}

view wave
view structure
view signals

do {fifo_ref_81.udo}

run -all

quit -force

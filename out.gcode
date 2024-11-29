; START SEQUENCE (in printers.json)
G21 ; metric pos
G90 ; absolute pos
M82 ; abs extr
M107 ; fan off
G28 ; homing
G1 Z5.0 F9000 ; 5mm above bed
M109 S190 ; heat nozzle
M106 ; fan full speed
M190 S50 ; heat bed
G92 E0 ; abs extr = 0
G1 F200 E3 ; 3 mm of extr to clean nozzle
G92 E0 ; reset E axis
G1 F9000 ; not sure about this one

; LAYER 1
G0 X0.000000 Y0.000000 Z0.500000 F9000.000000
G1 X0.000000 Y0.000000 Z0.500000 F300.000000 E0.000000
G1 X50.000000 Y0.000000 Z0.500000 F300.000000 E15.915494
G1 X50.000000 Y50.000000 Z0.500000 F300.000000 E15.915494
G1 X0.000000 Y50.000000 Z0.500000 F300.000000 E15.915494
G1 X0.000000 Y0.000000 Z0.500000 F300.000000 E15.915494
G1 X0.000000 Y0.000000 Z0.500000 F300.000000 E0.000000
G1 X70.000000 Y0.000000 Z0.500000 F300.000000 E22.281692
G1 X70.000000 Y50.000000 Z0.500000 F300.000000 E15.915494
G1 X20.000000 Y50.000000 Z0.500000 F300.000000 E15.915494
G1 X20.000000 Y0.000000 Z0.500000 F300.000000 E15.915494
 


; END SEQUENCE
M104 S0 ; cool down nozzle
M140 S0 ; cool down bed
G91 ; relative pos (& relative extr if i got it correctly)
G1 E-1 F300 ; retract extr
G1 Z0.5 E-5 F9000; retract even more while getting 5 mm higher
G28 X0 Y0 ; go home but not in Z
M82 ; abs extr
M107 ; fan off
M84 ; turn head motors off (to move head freely by hand)
G90 ; absolute pos


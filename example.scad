use <gridfinity.scad>

difference() {
	gridfinity(2, 1, 1, lip=true, magnets=false);
	translate([21,0,5.2]) linear_extrude(4) rounded_square(78, 36, 0.8);
}

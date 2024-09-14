use <gridfinity.scad>

$fn = $preview ? 10 : 50;

// preview offset
po = $preview ? 0.01 : 0;

tol = 0.5;

ux = 3;
uy = 1;
uz = 8;

module_x = 72 + tol;
module_y = 39 + tol;
module_clip_width = 12 + tol;

plug_r = 4 + tol;

plug_distance = 19;

usb_x = 11.6 + tol;
usb_y = 21.5 + tol;
usb_z = 1    + tol;

usb_location = [100,0,0];

module module_negative() {
	rotate([90,0,0]) linear_extrude(5) {
		translate([-2,      module_y/2 - module_clip_width/2]) square([2,module_clip_width]);
		translate([module_x,module_y/2 - module_clip_width/2]) square([2,module_clip_width]);
		square([module_x,module_y]);
	}
}

module plug_negative() {
	rotate([90,0,0]) linear_extrude(5) circle(plug_r);
}

module usb_inset() {
	translate([0,0,0]) difference() {
		linear_extrude(2) offset(delta=1) square([usb_x,usb_y]);
		translate([0,0,1+po]) linear_extrude(1) square([usb_x,usb_y]);
	}
}

module usb_hole_negative() {
	translate([-1,-5,0]) cube([usb_x+2,5,8]);
}

module psu_lid() {
	gridfinity(ux, uy, 1, lip=true, magnets=false, fill = false, bottom_height = 0);
}

module psu_cover() {
	difference() {
		gridfinity(ux, uy, uz + 1, lip=true, magnets=false, fill = false, bottom_height = 0);
		translate(concat(gf_inner_origin(), [gf_inner_bottom()])) {
			translate([0,-5,0]) cube([gf_inner(ux),5,gf_top(uz+1)-gf_inner_bottom() + 5]);
		}
	}
}

module psu_main() {
	difference() {
		gridfinity(ux, uy, uz, lip=true, magnets=false, fill = false, bottom_height = 0);
		translate(concat(gf_inner_origin(), [gf_inner_bottom()])) {
			translate([5,0,10]) module_negative();
			translate([90,0,15]) plug_negative();
			translate([90,0,15+plug_distance]) plug_negative();
			translate(usb_location) usb_hole_negative();
		}
	}

	translate(concat(gf_inner_origin(), [gf_inner_bottom()]))
		translate(usb_location) usb_inset();
}

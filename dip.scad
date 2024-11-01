use <gridfinity.scad>

magnets = false;

ux = 2;
uy = 1;
uz = 2;

pin_length = 3;
pin_spacing = 2.54;

pin_hole_percent = 0.8;

function hc_max(m) = floor( m / pin_spacing );

module pins_negative(cnt_x, cnt_y) {
	for (ix = [0:cnt_x]) {
		for (iy = [0 : cnt_y]) {
			translate([ pin_spacing*ix + pin_spacing*(1-pin_hole_percent)*0.5,
				    pin_spacing*iy + pin_spacing*(1-pin_hole_percent)*0.5 ])
				cube([pin_spacing*pin_hole_percent, pin_spacing*pin_hole_percent, pin_length]);
		}
	}
}

difference() {
	gridfinity(ux, uy, uz, lip=true, magnets=magnets, fill=false, bottom_height=pin_length);
	translate(gf_inner_origin()) translate(gf_top_vec(0))
		pins_negative(hc_max(gf_inner(ux)),hc_max(gf_inner(uy)));
}

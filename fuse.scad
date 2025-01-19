use <gridfinity.scad>

tol = 0.5;

ux = 2;
uy = 2;
uz = 3;

magnets = false;

outer_diam_real = 21.5;
inner_diam_real = 13.7;
inner_depth_real = 5;

outer_diam = outer_diam_real + tol;
inner_diam = inner_diam_real + tol;
inner_depth = inner_depth_real + tol;

// arbitrary value
outer_depth = 4;

hole_spacing = outer_diam * 1.1;

function hc_max(m) = floor( m / hole_spacing ) - 1;

module fuse_negative(cnt_x, cnt_y) {
	for (ix = [0:cnt_x]) {
		for (iy = [0 : cnt_y]) {
			translate([outer_diam/2 + hole_spacing*ix, outer_diam/2 + hole_spacing*iy]) {
				cylinder(inner_depth,d=inner_diam);
				translate([0,0,inner_depth]) cylinder(outer_depth,d = outer_diam);
			}
		}
	}
}


difference() {
	gridfinity(ux, uy, uz, lip=true, magnets=magnets, fill=false, bottom_height=inner_depth+outer_depth);
	translate(gf_inner_origin()) translate(gf_top_vec(0))
		fuse_negative(hc_max(gf_inner(ux)),hc_max(gf_inner(uy)));
}

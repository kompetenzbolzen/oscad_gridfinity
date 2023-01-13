$fn = 30;

// https://gridfinity.xyz/specification/

height   = 7;
width    = 42;
width_tolerance    = 41.5;
rounding = 3.75;

module rounding(r,angle) {
  rotate(angle,[0,0,1])
  translate([-r + 0.01, -r + 0.01])
  difference() {
    square([r,r]);
    circle(r);
  }
}

module rounded_square(lx, ly, r) {
  difference() {
    square([lx,ly],center=true);
    union() {
      translate([ lx/2, ly/2]) rounding(r, 0  );
      translate([-lx/2, ly/2]) rounding(r, 90 );
      translate([-lx/2,-ly/2]) rounding(r, 180);
      translate([ lx/2,-ly/2]) rounding(r, 270);
    }
  }
}

module magnet_hole(h = 0) {
  linear_extrude(2.5) circle(3.25);
  translate([0,0,2.5]) linear_extrude(h) circle(1.5);
}

module base_solid() {
  hull() {
    linear_extrude(0.1)rounded_square(35.6, 35.6, 0.8);
    translate([0,0,0.8]) linear_extrude(1.8) rounded_square(37.2, 37.2, 1.6);
  }
  translate([0,0,2.6]) hull() {
    linear_extrude(0.1) rounded_square(37.2, 37.2, 1.6);
    translate([0,0,2.15]) linear_extrude(0.1)rounded_square(41.5, 41.5, 3.75);
  }
}

module base(magnets = false) {
  l = 35.6;
  o = 4.8;

  difference() {
    base_solid();
    if (magnets) union() {
      translate([ l/2 - o,  l/2 - o, -0.01]) magnet_hole();
      translate([-l/2 + o,  l/2 - o, -0.01]) magnet_hole();
      translate([ l/2 - o, -l/2 + o, -0.01]) magnet_hole();
      translate([-l/2 + o, -l/2 + o, -0.01]) magnet_hole();
    }
  }
}

module stacking_lip_negative(ux, uy) {
  x1 = (width * ux) -5.2 -0.5;
  y1 = (width * uy) -5.2 -0.5;
  x2 = (width * ux) -3.8 -0.5;
  y2 = (width * uy) -3.8 -0.5;
  x3 = (width * ux) -0.5;
  y3 = (width * uy) -0.5;

  // translate and scale are here to make sure the negative pokes through
  // the positive block
  translate([0,0,-0.001]) scale([1,1,1.001]) hull() {
    linear_extrude(0.01)rounded_square(x1, y1, 0.7);
    translate([0,0,0.7]) linear_extrude(1.8) rounded_square(x2, y2, 1.6);
  }
  translate([0,0,2.5]) hull() {
    linear_extrude(0.01) rounded_square(x2, y2, 1.7);
    translate([0,0,2.15]) linear_extrude(0.01)rounded_square(x3, y3, 3.75);
  }
}

function coord_centered(ux) = (ux -1) * width - 0.5 * width * (ux - 1);

module stacking_lip(units_x, units_y) {
  difference() {
    linear_extrude(4.4)rounded_square(units_x * width -0.5, units_y * width -0.5, rounding);
    stacking_lip_negative(units_x, units_y);
  }
}

module gridfinity(units_x, units_y, units_z, lip = true, magnets = false) {
  for (ux = [0:units_x -1]) {
    for (uy = [0:units_y -1]) {
      translate([ux * width, uy * width,0]) base(magnets = magnets);
    }
  }
  if (units_z > 0) {
    translate([coord_centered(units_x), coord_centered(units_y), 4.75]) {
      extr = units_z * height - 4.75;
      linear_extrude(extr) rounded_square(units_x * width - 0.5, units_y * width - 0.5, rounding);
    }
  }
  if (lip && units_z > 0) // Just to safeguard. h=0 is not intended to be used with lip.
    translate([coord_centered(units_x), coord_centered(units_y), units_z * height])
      stacking_lip(units_x, units_y);
}

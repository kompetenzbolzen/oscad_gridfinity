$fn = 50;

// https://gridfinity.xyz/specification/

height   = 7;
width    = 42;
width_tolerance    = 41.5;
rounding = 3.75;

minimal_thickness = 1.5;
wall_thickness = 2.95; // thickness of stacking lip

// Get top of GridFinity object from GF units
function gf_top(units_z) =
  max(units_z * height - 4.75, minimal_thickness) + 4.75;

function gf_top_vec(units_z) =
  [0,0,gf_top(units_z)];

function gf_inner_bottom() = (4.75 + minimal_thickness);
function gf_inner_bottom_vec() = [0,0,gf_inner_bottom()];


// Get center of GridFinity object
function gf_center(units_x, units_y) = [
  (units_x * width - 0.5) / 2 - width/2,
  (units_y * width - 0.5) / 2 - width/2
];

function flatten(l) = [ for (a = l) for (b = a) b ] ;
function gf_top_center(units_x, units_y, units_z) =
  flatten([gf_center(units_x,units_y),gf_top(units_z)]);

function gf_inner_origin() = [-20.75 + wall_thickness,-20.75 + wall_thickness];

// usable inner space
function gf_inner(units_l) = 42*units_l -1 - 2*wall_thickness;

function gf_offset(units_x, units_y, units_z=0) = [width * units_x, width * units_y, height * units_z];

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

module magnet_hole(screw = 0) {
  linear_extrude(2.5) circle(3.25);
  translate([0,0,2.5]) linear_extrude(screw) circle(1.5);
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

module cutout_slot(l, rx = 0) {
  rotate([rx,-90,0]) linear_extrude(l) polygon([[0,-0.25],[0,0.25],[0.25,0]]);
}

// Cut out a cross with edges sloped like the rounded corners of the base
module cutout_cross() {
    r = rounding + 0.25;

    difference() {
      linear_extrude(0.25) square([r * 2, r * 2], center=true);
      union() {
        for(c = [[r,r], [r,-r], [-r,r], [-r,-r]]) translate(c) hull() {
          linear_extrude(0.01) circle(rounding);
          translate([0,0,0.25]) linear_extrude(0.01) circle(rounding + 0.25);
        }
      }
    }
}

module bottom_cutout(units_x, units_y) {
  if (units_y > 1) for (i = [1:units_y - 1]) {
    translate([units_x * width - width/2, i * width - width/2, 4.749])
      cutout_slot(width * units_x);
  }
  if(units_x > 1) for (i = [1:units_x - 1]) {
    translate([i * width - width/2, units_y * width - width/2, 4.749])
      cutout_slot(width * units_y, rx=90);
  }

  for (ux = [0:units_x]) {
    for (uy = [0:units_y]) {
      // we don't need the cross in the corners
      if (!( (ux == 0       && uy == 0      ) ||
             (ux == units_x && uy == units_y) ||
             (ux == 0       && uy == units_y) ||
             (ux == units_x && uy == 0      ) ))
        translate([ux * width - width/2, uy * width - width/2, 4.749]) cutout_cross();
    }
  }
}

module top_block_2d(units_x, units_y) {
  rounded_square(units_x * width - 0.5, units_y * width - 0.5, rounding);
}

module gridfinity(units_x, units_y, units_z, lip = true, magnets = false, fill = true, bottom_height = 0) {
  units_x = floor(abs(units_x));
  units_y = floor(abs(units_y));
  units_z = floor(abs(units_z));

  // Bases
  for (ux = [0:units_x -1]) {
    for (uy = [0:units_y -1]) {
      translate([ux * width, uy * width,0]) base(magnets = magnets);
    }
  }

  // Solid Block
  difference() {
    translate([coord_centered(units_x), coord_centered(units_y), 4.75]) {
      extr = max(units_z * height - 4.75, minimal_thickness);
      linear_extrude(extr)
        top_block_2d(units_x, units_y);
    }
    union(){
      bottom_cutout(units_x, units_y);

      // remove solid block if set, leave walls
      if (! fill) {
        extr = units_z * height - (4.75 + minimal_thickness) - bottom_height + 0.01;

        translate([coord_centered(units_x), coord_centered(units_y), 4.75 + minimal_thickness + bottom_height])
          linear_extrude(extr)
            rounded_square(units_x * width - wall_thickness * 2, units_y * width - wall_thickness * 2, 0.7);
      }
    }
  }

  // Stacking Lip
  if (lip && units_z > 0) // Just to safeguard. h=0 is not intended to be used with lip.
    translate([coord_centered(units_x), coord_centered(units_y), units_z * height])
      stacking_lip(units_x, units_y);
}

$fn = 50;
use <gridfinity.scad>

// Change these

ux = 2; //Minimum is 2!
uy = 1;

// (hopefully) no changes needed below

// If you want weird heights, adjust added_thickness.
// Dont't forget to adjust clip offsets accordingly!
uz = 2;
added_thickness = 0;
magnets = false;

clip_d = 6;
clip_l = 50;

mount_thickness = 4;
mount_length = 7;

clip_thickness = 2;
clip_width = 40;
clip_tolerance = 0.5;

clip_bottom_width = 10;
clip_top_width = 15;
// This is basically the height
clip_mount_resulting_offset = 9;
clip_bottom_angle = 225;
clip_top_angle = 150;
clip_handle_length = 8;
clip_handle_angle = 30;
clip_straight_part = 4;


module top_block(units_x, units_y,) {
  translate([coord_centered(units_x), coord_centered(units_y), gf_top(uz)]) {
    linear_extrude(added_thickness)
      top_block_2d(units_x, units_y);
  }
}

module base_plate() {
  difference() {
    union() {
      gridfinity(ux, uy, uz, lip=false, magnets=magnets);
      if (added_thickness > 0) {
        top_block(ux,uy);
      }
    }
    union() {
      for (ix = [0:ux-1]) {
        for (iy = [0:uy-1]) {
          translate(gf_offset(ix,iy,uz)) translate([0,0,-4.4 + added_thickness]) stacking_lip_negative(1,1);
        }
      }
    }
  }
}

module clip_mount() {
  translate([0,-mount_length,clip_d/2]) {
    rotate([0,90,0]) translate([0,0,-clip_l/2]) cylinder(h=clip_l, d=clip_d);
    translate([clip_l/2-mount_thickness,0,-clip_d/2]) cube([mount_thickness,mount_length,clip_d]);
    translate([-clip_l/2,0,-clip_d/2]) cube([mount_thickness,mount_length,clip_d]);
  }
}

module round_clipper(angle, width) {
  translate([0,0,clip_d/2 + clip_thickness+clip_tolerance/2]) rotate([0,90,0]) rotate_extrude(angle=angle)
    translate([(clip_d + clip_tolerance)/2,0,0]) square([clip_thickness, width]);
}

module clip(units_z) {
  resulting_height = units_z*7 + clip_mount_resulting_offset;
  straight_part=clip_straight_part;
  straight_offset = resulting_height - straight_part;

  linear_extrude(clip_thickness) {
    polygon([[0,straight_part],[clip_bottom_width,straight_part],
            [clip_width/2 + clip_top_width/2,straight_offset],
            [clip_width/2 - clip_top_width/2,straight_offset] ]);

    polygon([[clip_width - clip_bottom_width,straight_part],[clip_width ,straight_part],
            [clip_width/2 + clip_top_width/2,straight_offset],
            [clip_width/2 - clip_top_width/2,straight_offset] ]);

    //Straight end Bottom
    polygon([[0,0],[clip_bottom_width,0],[clip_bottom_width,straight_part],[0,straight_part]]);

    polygon([[clip_width - clip_bottom_width,0],[clip_width ,0],
             [clip_width ,straight_part],[clip_width - clip_bottom_width,straight_part]]);

    // straight end Top
    polygon([
            [clip_width/2 + clip_top_width/2,straight_offset],
            [clip_width/2 - clip_top_width/2,straight_offset],
            [clip_width/2 - clip_top_width/2,resulting_height],
            [clip_width/2 + clip_top_width/2,resulting_height],
    ]);
  }

  round_clipper(-clip_bottom_angle, clip_bottom_width);
  translate([clip_width - clip_bottom_width,0,0])
    round_clipper(-clip_bottom_angle, clip_bottom_width);

  translate([clip_width/2 - clip_top_width/2, resulting_height,0]) {
    round_clipper(clip_top_angle,clip_top_width);
    // Handle
    translate([0,0,sin(clip_handle_angle)*clip_thickness]) rotate([clip_handle_angle,0,0])
      translate([0,-clip_thickness,-clip_handle_length])
        cube([clip_top_width,clip_thickness,clip_handle_length]);
  }
}

base_plate();
translate([gf_center(ux, uy).x,-20.75,4.75]) clip_mount();
translate([gf_center(ux, uy).x,(42*uy) - 21.25,4.75]) mirror([0,1,0]) clip_mount();

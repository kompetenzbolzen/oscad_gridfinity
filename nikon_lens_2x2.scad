use <gridfinity.scad>
$fn=50;

// diameter (not radius!)
throat = 44.5;
inner = 47.5;
outer = 57;

lip_width = 1.7;
lip_height = 1.9;
lip_positions = [[50,-35], [55,-155], [55,-270]];
lip_offset = 0.8;

flange_height = 10;

size_x = 2;
size_y = 2;
size_z = 0;

module rounding_circle(radius, corner_radius, angle) {
  rotate_extrude() {
    translate([radius, angle>=180?corner_radius:0]) difference() {
      rotate([0,0,angle]) square(corner_radius);
      circle(corner_radius);
    }
  }
}

module lip(angle, offs) {
  rotate([0,0,offs]) translate([0,0,lip_height/2])
   rotate_extrude(angle=angle)
    translate([inner/2 +0.1 - lip_width/2,0,0]) square([lip_width,lip_height], center=true);
}

module nikon_f_flange() {
  difference() {
    linear_extrude(flange_height) difference() {
      circle(outer/2);
      circle(inner/2);
    }
    translate([0,0,flange_height-1]) rounding_circle(29,1,0);
  }

  translate([0,0,flange_height - lip_height - lip_offset]) {
    for (i = lip_positions) {
      lip(i[0],i[1]);
    }
  }

}

gridfinity(size_x,size_y,size_z);
translate(gf_top_center(size_x,size_y,size_z)) {
  nikon_f_flange();
  translate([14,-39])
    linear_extrude(1) text("Nikon", size = 7, font="sans:style=bold italic");
}

translate(gf_top_center(size_x,size_y,size_z)) rounding_circle(outer/2 + 3 - 0.01,3,180);

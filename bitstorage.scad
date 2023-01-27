use <gridfinity.scad>

// wrenchsize of the bits. Default is 6.35, which is
// for standard 1/4 inch bits. Smaller bits are mostly 4mm.
wrench_size = 6.35;

// size in GF units
ux = 1;
uy = 1;
uz = 3;

magnets = false;

// depth of the hexagon
bit_depth = 5;

// Wall between bits
wall = 1.5;

tolerance = 0.5;
diam = wrench_size + tolerance;

function r_from_d(d) = d/2 / sin(60);
function staggered_offset(d, w) = r_from_d(d)*1.5 + sin(60) * w;

function hc_max_y(max_y, d, w) = floor( max_y / (diam + wall) - 1 );
function hc_max_x(max_x, d, w) = floor( (max_x - r_from_d(d)/2 ) / (staggered_offset(d,w)) - 1 );

// d is from flat side to flat side -> wrench size
module hexagon(d) {
  l = r_from_d(d);
  translate([l,l]) circle(l, $fn=6);
}

// d = wrench size, w = wall
module honeycomb(cnt_x, cnt_y, d, w) {
  // we want wall distance also at a 60deg angle.
  x_offset = staggered_offset(d,w);

  for (ix = [0:cnt_x]) {
    // every second row is offset
    offs = ix%2 == 1 ? (d + w) / 2 : 0;
    x = x_offset * ix;

    for (iy = [0 : cnt_y - ix%2]) {
      y = iy * (d + w) + offs;
      translate([x,y]) hexagon(d);
    }
  }
}

module honeycomb_fit(x, y, d, w) {
  honeycomb(hc_max_x(x,d,w), hc_max_y(y,d,w), d, w);
}

module honeycomb_fit_center(x, y, d, w) {
  // mostly educated guessing, certainly not perfectly center
  offs_y = (y - ((hc_max_y(y, d, w) + 1) * (d+w))) /2;
  offs_x = (x - (hc_max_x(x, d, w) + 1) * staggered_offset(d, w) - r_from_d(d)/2) / 2;

  translate([offs_x, offs_y]) honeycomb_fit(x,y,d,w);
}

difference() {
  gridfinity(ux, uy, uz, lip=true, magnets=magnets, fill = false, bottom_height = bit_depth);

  translate(gf_inner_origin()) translate(gf_top_vec(0))
    linear_extrude(bit_depth + 0.01)
      honeycomb_fit_center(gf_inner(ux), gf_inner(uy), diam,wall);
}

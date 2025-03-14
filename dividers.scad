// All values in mm.

/* ####################
 * Definitions.
 * #################### */

W = 248;
L = 489;
H = 25.4 * 3;

// How thick the material is.
MAT_THICK = 5.4;
// How wide the laser is.
KERF = 0;
// Cut away just a little more, to make assembly easier/possible.
SLOP = 0.2;
// Total adjustments: positive values cut away more.
ADJ = SLOP - KERF;

EXT_PAD = 5;

/* ####################
 * Utilities
 * #################### */

// The project is simple enough that we can get away with having all joins "point one way".
// Creates a 3 vs 3 finger box join. Fingers point to -x.
ext_box_join_a = [
    [MAT_THICK + ADJ, ADJ],
    [MAT_THICK + ADJ, 1/6 * H + ADJ],
    [ADJ,             1/6 * H + ADJ],
    [ADJ,             2/6 * H - ADJ],
    [MAT_THICK + ADJ, 2/6 * H - ADJ],
    [MAT_THICK + ADJ, 3/6 * H + ADJ],
    [ADJ,             3/6 * H + ADJ],
    [ADJ,             4/6 * H - ADJ],
    [MAT_THICK + ADJ, 4/6 * H - ADJ],
    [MAT_THICK + ADJ, 5/6 * H + ADJ],
    [ADJ,             5/6 * H + ADJ],
    [ADJ,             H - ADJ],
];
// The other side of the join.
ext_box_join_b = [ for (v = ext_box_join_a) [-v[0], -v[1] + H]];
// Bottom tooth for the left side.
ext_box_join_c = [ for (v = ext_box_join_a) [v[0], -v[1] + H]];

// "Interior" box join.
function poly_square(p1, p2) = [
    [p1[0], p1[1]],
    [p1[0], p2[1]],
    [p2[0], p2[1]],
    [p2[0], p1[1]]
];
int_box_join = concat(
    poly_square([-MAT_THICK/2 - ADJ, ADJ],
                [MAT_THICK/2 + ADJ,  1/6 * H + ADJ]),
    poly_square([-MAT_THICK/2 - ADJ, 2/6 * H - ADJ],
                [MAT_THICK/2 + ADJ,  3/6 * H + ADJ]),
    poly_square([-MAT_THICK/2 - ADJ, 4/6 * H - ADJ],
                [MAT_THICK/2 + ADJ,  5/6 * H + ADJ])
);

// Cross lap join.
cross_lap_join = poly_square([-MAT_THICK/2 - ADJ, ADJ],
                             [MAT_THICK/2 + ADJ, H / 2 + ADJ]);

/* ####################
 * Actual pieces
 * #################### */

// Right piece.
RIGHT_VEC = concat(
    ext_box_join_a,
    [ for (v = ext_box_join_b) [v[0] + L, v[1]]]
);
projection()
translate([0, 3*(H+EXT_PAD), 0])
linear_extrude(height=MAT_THICK)
polygon(RIGHT_VEC);

// Front piece.
FRONT_VEC = concat(
    ext_box_join_a,
    [ for (v = ext_box_join_b) [v[0] + W, v[1]]],
    [ for (v = int_box_join) [v[0] + W/3, v[1]]],
    [ for (v = int_box_join) [v[0] + 2*W/3, v[1]]]
);
FRONT_PATHS = [
    concat(
        [for (i = [0:11]) i],
        [for (i = [12:23]) i],
        // Square cutouts.
        [for (i = [39:-1:36]) i],
        [for (i = [27:-1:24]) i]
    ),
    [for (i = [28:31]) i],
    [for (i = [32:35]) i],
    [for (i = [40:43]) i],
    [for (i = [44:47]) i]
];
projection()
translate([W + EXT_PAD, 4*(H+EXT_PAD), 0])
linear_extrude(height=MAT_THICK)
polygon(FRONT_VEC, FRONT_PATHS);
    
// Use the same geometry for the back.
projection()
translate([0, 4*(H+EXT_PAD), 0])
linear_extrude(height=MAT_THICK)
polygon(FRONT_VEC, FRONT_PATHS);

// Left piece.
LEFT_VEC = concat(
    ext_box_join_a,
    [ for (v = ext_box_join_b) [v[0] + L, v[1]]],
    [ for (v = int_box_join) [v[0] + L/2, v[1]]]
);
LEFT_PATHS = [
    concat(
        [for (i = [0:11]) i],
        [for (i = [12:23]) i],
        // Square cutouts.
        [for (i = [27:-1:24]) i]
    ),
    [for (i = [28:31]) i],
    [for (i = [32:35]) i]
];
projection()
translate([0, 2*(H+EXT_PAD), 0])
linear_extrude(height=MAT_THICK)
polygon(LEFT_VEC, LEFT_PATHS);

// Column, left.
COL_LEFT_VEC = concat(
    ext_box_join_c,
    [ for (v = ext_box_join_b) [v[0] + L, v[1]]],
    [ for (v = cross_lap_join) [v[0] + L/2, v[1]]]
);
COL_LEFT_PATHS = [
    concat(
        [for (i = [11:-1:0]) i],
        [for (i = [12:23]) i],
        // Fold join.
        [for (i = [27:-1:24]) i]
    )
];
projection()
translate([0, 1*(H+EXT_PAD), 0])
linear_extrude(height=MAT_THICK)
polygon(COL_LEFT_VEC, COL_LEFT_PATHS);

// Column, right.
COL_RIGHT_VEC = concat(
    ext_box_join_c,
    [ for (v = ext_box_join_b) [v[0] + L, v[1]]],
    [ for (v = int_box_join) [v[0] + L/2, v[1]]]
);
COL_RIGHT_PATHS = [
    concat(
        [for (i = [11:-1:0]) i],
        [for (i = [12:23]) i],
        // Square cutouts.
        [for (i = [27:-1:24]) i]
    ),
    [for (i = [28:31]) i],
    [for (i = [32:35]) i]
];
projection()
translate([0, 0, 0])
linear_extrude(height=MAT_THICK)
polygon(COL_RIGHT_VEC, COL_RIGHT_PATHS);

// Cross piece.
CROSS_VEC = concat(
    ext_box_join_c,
    [ for (v = ext_box_join_b) [v[0] + 2/3 * W + MAT_THICK/2, v[1]]],
    [ for (v = cross_lap_join) [v[0] + 1/3 * W, v[1] + H / 2]]
);
CROSS_PATHS = [
    concat(
        [for (i = [11:-1:0]) i],
        // Cross lap.
        [25, 24, 27, 26],
        [for (i = [12:23]) i]
    )
];
projection()
translate([L+EXT_PAD + H, 0, 0])
rotate(90)
linear_extrude(height=MAT_THICK)
polygon(CROSS_VEC, CROSS_PATHS);
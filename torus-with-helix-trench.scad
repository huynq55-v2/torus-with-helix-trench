// =================================================================
//               FIXED DIMENSIONS (in millimeters)
// =================================================================
base_R_torus      = 40;    // Major radius of the torus (core radius)
base_r_torus      = 15;    // Minor radius of the torus tube
base_r_helix_tube = 2.5;   // Radius of the helix groove tube

// =================================================================
//               SCALING FACTORS
// =================================================================
k_global = 5.0;    // Global scaling factor
k_core   = 0.6;    // Ratio for major radius
k_helix  = 0.3;    // Ratio for helix thickness
wall_ratio = 0.2;  // Ratio of solid wall (1.0 = solid, 0.2 = 80% hollow)

// =================================================================
//               OTHER PARAMETERS
// =================================================================
$fn = 64;
m_helices        = 12;
n_winds          = 1;
segments_per_turn = 200;

// =================================================================
//     COMPUTED VALUES BASED ON SCALING FACTORS
// =================================================================
R_torus         = base_R_torus      * k_global * k_core;
r_torus         = base_r_torus      * k_global;
r_torus_inner   = r_torus * (1 - wall_ratio);
r_helix_tube    = base_r_helix_tube * k_global * k_helix;

// =================================================================
//      FUNCTION: CALCULATE A POINT ON HELIX (angle in degrees)
// =================================================================
function helix_point(t, i, lambda) = [
    cos(t) * (R_torus - r_torus * cos(lambda * n_winds * t + i * 360 / m_helices)),
    sin(t) * (R_torus - r_torus * cos(lambda * n_winds * t + i * 360 / m_helices)),
    r_torus * sin(lambda * n_winds * t + i * 360 / m_helices)
];

// =================================================================
//        MODULE TO DRAW CYLINDER BETWEEN TWO POINTS
// =================================================================
module segment_between(p1, p2, rad) {
    v = [p2[0]-p1[0], p2[1]-p1[1], p2[2]-p1[2]];
    len = norm(v);
    axis = cross([0,0,1], v);
    ang = acos(v[2]/len);
    translate(p1)
        rotate(a = ang, v = axis)
            cylinder(h = len, r = rad, $fn = $fn);
}

// =================================================================
//        MODULE: OUTER TORUS
// =================================================================
module outer_torus() {
    rotate_extrude(convexity = 10)
        translate([R_torus, 0, 0])
            circle(r = r_torus);
}

// =================================================================
//        MODULE: INNER TORUS (to subtract → hollow)
// =================================================================
module inner_torus() {
    rotate_extrude(convexity = 10)
        translate([R_torus, 0, 0])
            circle(r = r_torus_inner);
}

// =================================================================
//        MODULE: HOLLOW TORUS = outer - inner
// =================================================================
module hollow_torus() {
    difference() {
        outer_torus();
        inner_torus();
    }
}

// =================================================================
//        MODULE: HELIX GROOVE SOLID (λ = ±1)
// =================================================================
module helix_solid(lambda = 1) {
    for (i = [0 : m_helices - 1]) {
        total_segs = n_winds * segments_per_turn;
        for (j = [0 : total_segs - 1]) {
            t1 = j     * 360 / segments_per_turn;
            t2 = (j+1) * 360 / segments_per_turn;
            p1 = helix_point(t1, i, lambda);
            p2 = helix_point(t2, i, lambda);
            hull() {
                translate(p1) sphere(r = r_helix_tube, $fn=16);
                translate(p2) sphere(r = r_helix_tube, $fn=16);
            }
        }
    }
}

// =================================================================
//        MAIN: HOLLOW TORUS WITH SUBTRACTED HELIX GROOVES
// =================================================================
difference() {
    hollow_torus();  // hollow torus (20% wall thickness)
    color("red", alpha = 0.5)
    union() {
        helix_solid(+1);  // Right-handed helix
        helix_solid(-1);  // Left-handed helix
    }
}

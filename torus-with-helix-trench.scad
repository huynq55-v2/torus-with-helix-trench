// =================================================================
//               FIXED DIMENSIONS (in millimeters)
// =================================================================
base_R_torus      = 40;    // Major radius of the torus (core radius)
base_r_torus      = 15;    // Minor radius of the torus tube
base_r_helix_tube = 2.5;   // Radius of the helix groove tube

// =================================================================
//               SCALING FACTORS
// =================================================================
// 1. Global scale factor for the entire model
k_global = 5.0;
// 2. Core ratio: scales the torus major radius (relative to the tube)
//    Effective R_torus = base_R_torus * k_global * k_core
k_core   = 0.6;
// 3. Groove thickness ratio: scales the helix tube radius
//    Effective r_helix_tube = base_r_helix_tube * k_global * k_helix
k_helix  = 0.3;

// =================================================================
//               OTHER PARAMETERS
// =================================================================
$fn = 64;                    // Resolution of curves
m_helices        = 12;       // Number of helices
n_winds          = 1;        // Number of windings per helix
segments_per_turn = 200;     // Number of segments per full turn

// =================================================================
//     COMPUTED VALUES BASED ON SCALING FACTORS
// =================================================================
R_torus      = base_R_torus      * k_global * k_core;
r_torus      = base_r_torus      * k_global;
r_helix_tube = base_r_helix_tube * k_global * k_helix;

// =================================================================
//            HELIX POINT CALCULATION FUNCTION
// =================================================================
function helix_point(t, i, lambda) = [
    cos(t) * (R_torus - r_torus * cos(lambda * n_winds * t + i * 360 / m_helices)),
    sin(t) * (R_torus - r_torus * cos(lambda * n_winds * t + i * 360 / m_helices)),
    r_torus * sin(lambda * n_winds * t + i * 360 / m_helices)
];

// =================================================================
//        MODULE TO DRAW A CYLINDER BETWEEN TWO POINTS
// =================================================================
module segment_between(p1, p2, rad) {
    v   = [p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2]];
    len = norm(v);
    axis = cross([0, 0, 1], v);
    ang  = acos(v[2] / len);
    translate(p1)
        rotate(a = ang, v = axis)
            cylinder(h = len, r = rad, $fn = $fn);
}

// =================================================================
//        MODULE TO CREATE A SOLID TORUS
// =================================================================
module solid_torus() {
    rotate_extrude(convexity = 10)
        translate([R_torus, 0, 0])
            circle(r = r_torus);
}

// =================================================================
//        MODULE TO GENERATE HELIX GROOVE SOLID (λ = ±1)
// =================================================================
module helix_solid(lambda = 1) {
    union() {
        for (i = [0 : m_helices - 1]) {
            total_segs = n_winds * segments_per_turn;
            for (j = [0 : total_segs - 1]) {
                t1 = j     * 360 / segments_per_turn;
                t2 = (j+1) * 360 / segments_per_turn;
                p1 = helix_point(t1, i, lambda);
                p2 = helix_point(t2, i, lambda);
                segment_between(p1, p2, r_helix_tube);
            }
        }
    }
}

// =================================================================
//        MAIN: SUBTRACT TWO HELICES FROM THE TORUS
// =================================================================
difference() {
    solid_torus();
    union() {
        helix_solid(+1);  // Right-handed helix
        helix_solid(-1);  // Left-handed helix
    }
}

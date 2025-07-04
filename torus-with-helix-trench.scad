// =================================================================
//               FIXED DIMENSIONS (in millimeters)
// =================================================================
base_R_torus      = 40;
base_r_torus      = 15;
base_r_helix_tube = 2.5;

// =================================================================
//               SCALING FACTORS
// =================================================================
k_global = 2.5;
k_core   = 1;
k_helix  = 0.35;
wall_ratio = 0.2;

// =================================================================
//               OTHER PARAMETERS
// =================================================================
$fn = 256;
m_helices        = 12;
n_winds          = 1;
segments_per_turn = 200;

// =================================================================
//     COMPUTED VALUES
// =================================================================
R_torus         = base_R_torus      * k_global * k_core;
r_torus         = base_r_torus      * k_global;
r_torus_inner   = r_torus * (1 - wall_ratio);
r_helix_tube    = base_r_helix_tube * k_global * k_helix;

// =================================================================
//     FUNCTION: CALCULATE A POINT ON TORUS SURFACE WITH TANGENT
// =================================================================
function torus_surface_point(t, i, lambda) = 
    let (
        phi = t,                       // angle along torus ring
        theta = lambda * n_winds * t + i * 360 / m_helices, // angle around tube
        x = (R_torus + r_torus * cos(theta)) * cos(phi),
        y = (R_torus + r_torus * cos(theta)) * sin(phi),
        z = r_torus * sin(theta)
    ) [x, y, z];

// =================================================================
//     MODULE TO DRAW CYLINDRICAL SEGMENT BETWEEN POINTS
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
//     MODULE: OUTER AND INNER TORUS
// =================================================================
module outer_torus() {
    rotate_extrude(convexity = 10)
        translate([R_torus, 0, 0])
            circle(r = r_torus);
}
module inner_torus() {
    rotate_extrude(convexity = 10)
        translate([R_torus, 0, 0])
            circle(r = r_torus_inner);
}
module hollow_torus() {
    difference() {
        outer_torus();
        inner_torus();
    }
}

// =================================================================
//     MODULE: HELIX GROOVE (tangent to torus, lies in XOY)
// =================================================================
module helix_groove(lambda = 1) {
    for (i = [0 : m_helices - 1]) {
        total_segs = n_winds * segments_per_turn;
        for (j = [0 : total_segs - 1]) {
            t1 = j     * 360 / segments_per_turn;
            t2 = (j+1) * 360 / segments_per_turn;
            p1 = torus_surface_point(t1, i, lambda);
            p2 = torus_surface_point(t2, i, lambda);
            hull() {
                translate(p1) sphere(r = r_helix_tube, $fn=16);
                translate(p2) sphere(r = r_helix_tube, $fn=16);
            }
        }
    }
}

// =================================================================
//     MAIN SCENE
// =================================================================
difference() {
    hollow_torus();  // Solid torus with hollow core
    color("red", alpha = 0.5)
    union() {
        helix_groove(+1);  // Right-handed
        helix_groove(-1);  // Left-handed
    }
}

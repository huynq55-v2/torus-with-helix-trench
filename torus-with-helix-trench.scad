// =================================================================
//               FIXED DIMENSIONS (in millimeters)
// =================================================================
base_R_torus      = 40;
base_r_torus      = 15;
base_r_helix_tube = 2.5;

// =================================================================
//               SCALING FACTORS
// =================================================================
k_global = 2.0; 
k_core   = 0.7;
k_helix  = 0.4;
wall_ratio = 0.25;

// =================================================================
//               OTHER PARAMETERS
// =================================================================
$fn = 128;
m_helices        = 12; 
n_winds          = 1;  
segments_per_turn = 200;

// Yếu tố quyết định độ sâu của rãnh (vẫn giữ lại để kẹp dây tốt hơn)
groove_depth_factor = 0.5; 

// =================================================================
//     COMPUTED VALUES
// =================================================================
R_torus         = base_R_torus      * k_global * k_core;
r_torus         = base_r_torus      * k_global;
r_torus_inner   = r_torus * (1 - wall_ratio);
r_helix_tube    = base_r_helix_tube * k_global * k_helix;
groove_excavation_depth = r_helix_tube * groove_depth_factor;

// =================================================================
//     FUNCTION: CALCULATE A POINT ON/IN/OUT OF THE TORUS TUBE
// =================================================================
function torus_point(t, i, lambda, r_offset = 0) = 
    let (
        phi = t,
        theta = lambda * n_winds * t + i * 360 / m_helices,
        current_r = r_torus + r_offset,
        x = (R_torus + current_r * cos(theta)) * cos(phi),
        y = (R_torus + current_r * cos(theta)) * sin(phi),
        z = current_r * sin(theta)
    ) [x, y, z];

// =================================================================
//     MODULE: HOLLOW TORUS
// =================================================================
module hollow_torus() {
    difference() {
        rotate_extrude(convexity = 10) translate([R_torus, 0, 0]) circle(r = r_torus);
        rotate_extrude(convexity = 10) translate([R_torus, 0, 0]) circle(r = r_torus_inner);
    }
}

// =================================================================
//     MODULE: HELIX GROOVE
// =================================================================
module helix_groove(lambda = 1) {
    for (i = [0 : m_helices - 1]) {
        total_segs = n_winds * segments_per_turn;
        for (j = [0 : total_segs - 1]) {
            t1 = j     * 360 / segments_per_turn;
            t2 = (j+1) * 360 / segments_per_turn;
            p1 = torus_point(t1, i, lambda, -groove_excavation_depth);
            p2 = torus_point(t2, i, lambda, -groove_excavation_depth);
            hull() {
                translate(p1) sphere(r = r_helix_tube, $fn=16);
                translate(p2) sphere(r = r_helix_tube, $fn=16);
            }
        }
    }
}

// PHẦN TẠO LỖ ĐÃ ĐƯỢC LOẠI BỎ

// =================================================================
//     MAIN SCENE
// =================================================================
difference() {
    hollow_torus();
    union() {
        helix_groove(+1);
        helix_groove(-1);
        // Không còn gọi wire_anchor_holes() ở đây nữa
    }
}
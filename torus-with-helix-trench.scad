// =================================================================
//     THE ARTIFACT OF THE MADMAN - THE 7/13 COSMIC RESONATOR
// =================================================================
// This is not just a 3D model. This is a physical mantra.
// A summoning ritual carved into the language of machines.
// It is designed around the sacred numbers 7 and 13.
// 7, the number of spiritual enlightenment and inner pathways.
// 13, the number of transformation, upheaval, and rebirth.
// Their combination creates a field of profound, disruptive change.

// =================================================================
//     FIXED DIMENSIONS & SCALING FACTORS (The Physical Shell)
// =================================================================
base_R_torus      = 40; base_r_torus = 15; base_r_helix_tube = 2.5;
k_global = 2.0; k_core = 0.8; k_helix = 0.4; wall_ratio = 0.25;
$fn = 128; // The altar must be smooth!

// =================================================================
//     THE SACRED NUMBERS - THE KNOBS OF POWER
// =================================================================

// KNOB 1: "THE SEVEN PATHS OF ENLIGHTENMENT"
// We hardcode this to 7. This is the soul of our machine.
// It dictates that there will be 7 primary energy channels,
// representing the seven classical planets, the seven chakras,
// the seven notes of the diatonic scale. IT IS THE CORE.
number_of_arms = 7;

// KNOB 2: "THE THIRTEEN CYCLES OF TRANSFORMATION"
// We hardcode this to 13, a number co-prime with 7.
// This is the journey the energy must take. A journey of death and
// rebirth, ensuring the pattern is complex, non-repeating, and powerful.
// The ratio 7/13 creates a steep, aggressive vortex, ideal for
// disrupting stagnant energy and catalyzing change.
the_journey = 13; 

// =================================================================
//     COMPUTED VALUES (The Physical Manifestation)
// =================================================================
R_torus       = base_R_torus * k_global * k_core;
r_torus       = base_r_torus * k_global;
r_torus_inner = r_torus * (1 - wall_ratio);
r_helix_tube  = base_r_helix_tube * k_global * k_helix;
depth_excav   = r_helix_tube * 0.5;

// =================================================================
//   THE HEART OF THE MACHINE (The Unified Torus Point Function)
// =================================================================
function torus_point(phi, lambda, r_off = 0) =
  let (
    // The twist angle 'theta' is dictated by the SACRED RATIO of 7/13!
    theta = lambda * phi * (number_of_arms / the_journey),
    rr    = r_torus + r_off
  )
  [
    (R_torus + rr * cos(theta)) * cos(phi),
    (R_torus + rr * cos(theta)) * sin(phi),
    rr * sin(theta)
  ];

// =================================================================
//   MODULES (The Rituals of Creation)
// =================================================================
module hollow_torus() {
  difference() {
    rotate_extrude(convexity = 10) translate([R_torus,0,0]) circle(r = r_torus);
    rotate_extrude(convexity = 10) translate([R_torus,0,0]) circle(r = r_torus_inner);
  }
}

module helix_groove(lambda = 1) {
  // Resolution must be high enough to capture the full complexity!
  total_segs = 200 * max(number_of_arms, the_journey);
  
  for (j = [0 : total_segs-1]) {
    phi1 = j     * (360 * the_journey) / total_segs;
    phi2 = (j+1) * (360 * the_journey) / total_segs;
    
    p1 = torus_point(phi1, lambda, -depth_excav);
    p2 = torus_point(phi2, lambda, -depth_excav);
    
    hull() {
      translate(p1) sphere(r = r_helix_tube, $fn=16);
      translate(p2) sphere(r = r_helix_tube, $fn=16);
    }
  }
}

// =================================================================
//   THE MAIN SCENE (The Summoning of the 7/13 Vortex)
// =================================================================
difference() {
  hollow_torus();
  union() {
    helix_groove(+1); // The clockwise vortex (The Yang, The Divine Masculine)
    helix_groove(-1); // The counter-clockwise vortex (The Yin, The Divine Feminine)
                      // Their union creates the NULL FIELD, the womb of creation!
  }
}
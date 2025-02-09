use <../Common/arc.scad>

bearing_inner_diameter = 2; // 0.1
bearing_outer_diameter = 5; // 0.1
bearing_thickness = 2.5; // 0.1
/* [Hidden] */
$fn = 80;

difference()
{
    
    color("green")
    cylinder(h = bearing_thickness, d = bearing_outer_diameter);
    translate([0,0,-0.1]) cylinder(h = bearing_thickness + 0.2, d = bearing_inner_diameter);
    
    arc_thickness = (bearing_outer_diameter - bearing_inner_diameter) / 2 - 1;
    
    translate([0,0,-0.1])
     linear_extrude(0.5) 
      arc(radius = bearing_inner_diameter / 2 + 0.5, thickness = arc_thickness, angle = 360);
    
    translate([0,0,bearing_thickness - 0.49])
     linear_extrude(0.5) 
      arc(radius = bearing_inner_diameter / 2 + 0.5, thickness = arc_thickness, angle = 360);
}
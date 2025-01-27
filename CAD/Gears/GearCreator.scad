use <../Common/gears.scad>

// Type to generate. Spur gear, bevel gear or shifter
type = "shifter"; // ["spur", "bevel", "shifter","test"]

/* [Basic Gear Parameters] */
// Number of teeth
teeth = 8;
// Teeth size?
Module = 1; // 0.01
// Pressure angle of teeth
pressure_angle = 20; // 1
// Thickness of the gear [mm]
width = 5.0; // 0.01
// Diameter of the center hole [mm]
bore = 3; // 0.01
// Create place for the key
keyed = true;
// Create the dog pattern
dogged = true;

/* [Key parameters] */
// Width of the keystone [mm]
key_width = 1; // 0.1 
// Height of the keystone [mm]
key_height = 1; // 0.1

/* [Dog teeth parameters]*/
// Scale of the dog teeth
dog_angle = 20; // [20:60]
// Inside radius of dogteeth from the center
dog_radius = 3; // 0.1
// Thickness going from inside of radius to outside of dogteeth
dog_thickness = 2; // 0.1
// Height of the dog teeth
dog_height = 1; // 0.1
// Offset from the bore of the dog teeth
dog_offset = 3; // 0.1
// Dog side
dog_side = "back"; // ["back","front","both"]
// Direction of the dog
dog_dir = "outside"; // ["inside","outside"]

/* [Shifter parameters] */
// Shifter width. If not set to 0 then use this as the width of the shifter
shifter_width = 0; // 0.1
// Shifter diameter
shifter_diameter = 15; // 0.1
// Fork width where the fork can make contact
fork_width = 1; // 0.1
// Fork diameter for interfacing with the shifter
fork_diameter = 12; // 0.1

/* [Hidden] */
dog_roundness_compensation = 0.6;
dogOff = dog_offset + (bore / 2) - dog_roundness_compensation;


module rotate_about_point(rotation, rotation_vector, point) {
        rotate(rotation,rotation_vector)
            translate(-point)
                children();   
}

/*
radius: Outside radius of the arc
thickness: Thickness between the inside and outside of the radius
angle: The angle of the arc, anywhere between 0 and 360.
*/
module arc(radius, thickness, angle){
	intersection(){
		union(){
			rights = floor(angle/90);
			remain = angle-rights*90;
			if(angle > 90){
				for(i = [0:rights-1]){
					rotate(i*90-(rights-1)*90/2){
						polygon([[0, 0], [radius+thickness, (radius+thickness)*tan(90/2)], [radius+thickness, -(radius+thickness)*tan(90/2)]]);
					}
				}
				rotate(-(rights)*90/2)
					polygon([[0, 0], [radius+thickness, 0], [radius+thickness, -(radius+thickness)*tan(remain/2)]]);
				rotate((rights)*90/2)
					polygon([[0, 0], [radius+thickness, (radius+thickness)*tan(remain/2)], [radius+thickness, 0]]);
			}else{
				polygon([[0, 0], [radius+thickness, (radius+thickness)*tan(angle/2)], [radius+thickness, -(radius+thickness)*tan(angle/2)]]);
			}
		}
		difference(){
			circle(radius+thickness);
			circle(radius);
		}
	}
}

module dog(radius = dog_radius, thickness = dog_thickness, angle = dog_angle) {
    linear_extrude(dog_height){
        translate([-4,0,0]) // Centering of dog_teeth
        arc(radius,thickness,angle);
    }
}

module key() {
    translate([0,bore / 2,width/2 - 0.05]) cube([key_width, key_height, width + 0.5], true);
}

module createOutsideDogTeeth() {
    if(dogged && dog_dir == "outside"){

        d = Module * teeth;
        r = d / 2;
        c =  (teeth <3)? 0 : Module/6;	
        df = d - 2 * (Module + c);	
        rf = df / 2;
        for(an = [0 : 120 : 360]){
            rotate_about_point(an, [0,0,1], [-dogOff, 0, 0]) dog();
        }
    }
}

module createInsideDogTeeth() {
    if(dogged && dog_dir == "inside" ){
        
        d = Module * teeth;
        r = d / 2;
        c =  (teeth <3)? 0 : Module/6;	
        df = d - 2 * (Module + c);	
        rf = df / 2;
        c_dog_angle = dog_angle + dog_angle * 0.3;
        translate([0,0,-dog_height])
        union() {
            // Constrainer
            translate([0,0,0.0002]) 
            for(an = [0 : 120 : 360]){
                rotate_about_point(an, [0,0,1], [-dogOff, 0, 0]) dog(radius = dog_radius - 0.1, thickness = dog_thickness + 0.1, angle = c_dog_angle);
            }
        }
    }
}

module createSpurGear() {
    translate([0,0,width]) 
    createOutsideDogTeeth();
    difference(){
        spur_gear (modul=Module, tooth_number=teeth, width=width, bore=bore, pressure_angle=pressure_angle, helix_angle=0, optimized=false);
        translate([0,0,width]) 
        createInsideDogTeeth();
        if(keyed){
            key();
        }
    }
}

module createBevelGear() {
    difference(){
        bevel_gear(modul=Module, tooth_number=teeth,  partial_cone_angle=45, tooth_width=width, bore=bore, pressure_angle=pressure_angle, helix_angle=0);
        if(keyed){
            key();
        }
    }
}

module createShifter() {
    dogged = true;
    keyed = true;
    shifter_radius = shifter_diameter / 2;
    fork_radius = fork_diameter / 2;
    
    width = shifter_width == 0 ? fork_width * 3 : shifter_width;
    difference() {
        cylinder(h = width, r = shifter_radius);
        translate([0,0,width / 2 - fork_width / 2]) 
        difference() {
            cylinder(h = fork_width, r = shifter_radius + 1);    
            translate([0,0,-0.1]) cylinder(h = (fork_width + 0.2), r = fork_radius);    
        }
        cylinder(h = width * 3, d = bore, center = true);
        if(keyed) {
            key();
        }
        if(dog_side == "back" || dog_side == "both") {
            echo("iback");
            translate([0,0,dog_height - 0.001]) 
             createInsideDogTeeth();
        }
        if(dog_side == "front" || dog_side == "both") {
            echo("ifront");
            translate([0,0,width])
             createInsideDogTeeth();
        }
    }
    
    if(dog_side == "back" || dog_side == "both")
    {
        echo("oback");
        translate([0,0,-dog_height]) 
         createOutsideDogTeeth();
    }
    if(dog_side == "front" || dog_side == "both")
    {
        echo("ofront");
        translate([0,0,width])
         createOutsideDogTeeth();
    }
}

$fn = 100;

if(type == "shifter") {
    createShifter();
} else if(type == "spur") {
    createSpurGear();
} else if(type == "bevel") {
    createBevelGear();
} else if(type == "test") {
    
}
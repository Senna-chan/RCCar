use <../Common/gears.scad>

// Type to generate. Spur gear, bevel gear or shifter
type = "shifter"; // ["spur", "bevel", "shifter"]

/* [Basic Gear Parameters] */
// Teeth
teeth = 8;
// Overal size
Module = 1; // 0.01
// Width of the gear [mm]
width = 5.0; // 0.01
// Size of the center hole [mm]
bore = 3; // 0.01
// Is keyed
keyed = true;
// Is Doggear
dogged = true;

/* [Key parameters] */
// Width of the keystone [mm]
key_width = 1; // 0.1 
// Height of the keystone [mm]
key_height = 1; // 0.1

/* [Dog teeth parameters]*/
// Scale of the dog teeth
dog_scale = 0.4; // 0.1
// Height of the dog teeth
dog_height = 1; // 0.1
// Offset from the bore of the dog teeth
dog_offset = 3; // 0.1
// Dog side
dog_side = "back"; // ["back","front","both"]

/* [Shifter parameters] */
// Shifter width. If not set to 0 then use this as the width of the shifter
shifter_width = 0; // 0.1
// Shifter diameter
shifter_diameter = 4; // 0.1
// Fork width where the fork can make contact
fork_width = 1; // 0.1
// Fork diameter for interfacing with the shifter
fork_diameter = 2; // 0.1
module dog()
{   
    linear_extrude(dog_height){
        scale(v = dog_scale) difference(){
        union(){
            translate([-2,2,0]) polygon([[0,0],[0,-4],[4,-6],[4,2],[0,0]]);
            difference(){
                translate([2,0,0]) resize([2.5,8]) circle(d=8);
                translate([1,0,0]) square(size = [2,20],center = true);

            }
        }
        translate([-2,0,0]) resize([1,5]) circle(d=4);
    }
    }
}
module key()
{
    translate([0,bore / 2,width/2 - 0.05]) cube([key_width, key_height, width + 0.5], true);
}

module createDogTeeth(){
    dogOff = dog_offset + (bore / 2);

    d = Module * teeth;
    r = d / 2;
    c =  (teeth <3)? 0 : Module/6;	
    df = d - 2 * (Module + c);	
    rf = df / 2;
    intersection() {
        cylinder(h = dog_height, r = rf);
        union(){
            translate([dogOff, 0, 0]) dog();
            translate([-dogOff, 0, 0]) rotate(180) dog();
            translate([0, dogOff, 0]) rotate(90) dog();
            translate([0, -dogOff, 0]) rotate(-90) dog();
        }

    }
}

module createSpurGear() {
    union(){
        if(dogged){
            if(teeth > 10){
                translate([0,0,width])
                createDogTeeth();
            } else {
                echo("Cannot create dogteeth with ",teeth,"teeth");
            }
        }

        difference(){
            spur_gear (modul=Module, tooth_number=teeth, width=width, bore=bore, pressure_angle=20, helix_angle=0, optimized=false);
            if(keyed){
                key();
            }
        }
    }
}

module createBevelGear(){
    difference(){
        bevel_gear(modul=Module, tooth_number=teeth,  partial_cone_angle=45, tooth_width=width, bore=bore, pressure_angle=20, helix_angle=0);
        if(keyed){
            key();
        }
    }
}

module createShifter()
{
    shifter_radius = shifter_diameter / 2;
    fork_radius = fork_diameter / 2;
    
    width = shifter_width == 0 ? dog_height * 3 : shifter_width;
    difference()
    {
        cylinder(h = width, r = shifter_radius);
        translate([0,0,width / 2 - fork_width / 2]) difference() {
            cylinder(h = fork_width, r = shifter_radius + 1);    
            translate([0,0,-0.1]) cylinder(h = (fork_width + 0.2), r = fork_radius);    
        }
        cylinder(h = width * 3, d = bore, center = true);
        if(keyed){
            key();
        }
    }

    // // 
    if(dog_side == "back" || dog_side == "both")
    {
        echo("back");
        translate([0,0,-dog_height])
        createDogTeeth();
    }
    if(dog_side == "front" || dog_side == "both")
    {
        echo("front");
        translate([0,0,width])
        createDogTeeth();
    }
}

$fn=60;
if(type == "shifter") {
    createShifter();
} else if(type == "spur") {
    createSpurGear();
} else if(type == "bevel") {
    createBevelGear();
}
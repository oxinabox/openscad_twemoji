use <../src/twiemoji.scad>
include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

module tile()
{
    diff()
    cuboid([46,46,2]){
        attach(BACK) xcopies(10,4) dovetail("male", slide=2, width=4, height=4, chamfer=0.5, taper=6);
        tag("remove")attach(FRONT) xcopies(10,4) dovetail("female", slide=2, width=4, height=4, chamfer=0.5, taper=6);
        attach(LEFT) xcopies(10,4) dovetail("male", slide=2, width=4, height=4, chamfer=0.5, taper=6);
        tag("remove")attach(RIGHT) xcopies(10,4) dovetail("female", slide=2, width=4, height=4, chamfer=0.5, taper=6);
    };
}

difference(){
    translate([0,0,-1])
    tile();
    translate([0,0,-1.9]) engrave_twiemoji("💂🏿", 2, center=true);
};

translate([0,60,0])
difference(){
    translate([0,0,-1])
    tile();
    translate([0,0,-1.9]) engrave_twiemoji("💃", 2, center=true);
};

translate([0,120,0])
difference(){
    translate([0,0,-1])
    tile();
    translate([0,0,-1.9]) engrave_twiemoji("🏔️", 2, center=true);
};
translate([60,0,0])
difference(){
    translate([0,0,-1])
    tile();
    translate([0,0,-1.9]) engrave_twiemoji("🎁", 2, center=true);
};
translate([60,60,0])
difference(){
    translate([0,0,-1])
    tile();
    translate([0,0,-1.9]) engrave_twiemoji("👁️", 2, center=true);
};
translate([60,120,0])
difference(){
    translate([0,0,-1])
    tile();
    translate([0,0,-1.9]) engrave_twiemoji("🖼️", 2, center=true);
};

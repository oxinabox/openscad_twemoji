use <../src/twiemoji.scad>

//🏔️🏔  💃⛰️

difference(){
    translate([0,0,-1])
    cube([40,40, 2], center=true);
    translate([0,0,-1.9]) engrave_twiemoji("💂🏿", 2, center=true);
};
translate([0,50,0])
difference(){
    translate([0,0,-1])
    cube([40,40, 2], center=true);
    translate([0,0,-1.9]) engrave_twiemoji("💃", 2, center=true);
};
translate([0,100,0])
difference(){
    translate([0,0,-1])
    cube([40,40, 2], center=true);
    translate([0,0,-1.9]) engrave_twiemoji("🏔️", 2, center=true);
};
translate([50,0,0])
difference(){
    translate([0,0,-1])
    cube([40,40, 2], center=true);
    translate([0,0,-1.9]) engrave_twiemoji("🎁", 2, center=true);
};
translate([50,50,0])
difference(){
    translate([0,0,-1])
    cube([40,40, 2], center=true);
    translate([0,0,-1.9]) engrave_twiemoji("👁️", 2, center=true);
};
translate([50,100,0])
difference(){
    translate([0,0,-1])
    cube([40,40, 2], center=true);
    translate([0,0,-1.9]) engrave_twiemoji("🖼️", 2, center=true);
};

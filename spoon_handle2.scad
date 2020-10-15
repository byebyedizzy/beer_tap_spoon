use <bezier_curve.scad>;
use <__comm__/__to2d.scad>;

sh_t_step = 0.05;
//sh_width = 1;

sh_width1 = 55;
sh_width2 = 27 * 0.1;
sh_width3 = 34 * 2.5;

sh_length1 = 35; // + 20;
sh_length2 = 75; // + 20;
sh_length3 = 90; // + 20;

sh_height0 = 32;
sh_height1 = 23;
sh_height2 = 14 * 0.5;
sh_height3 = 17 * 4;

///////////////////////////
nof = $preview ? 20 : 100;
echo (nof=nof);
///////////////////////////


module _spoon_handle_full() {
    zh = sh_length3 + 5;
    pb = bezier_curve(sh_t_step, 
        [[sh_width1/2-1, 0, 0], [sh_width2/2, sh_length1, 0], [sh_width3/2, sh_length2, 0], [0, sh_length3, 0]]
    );

    p1 = concat([[0, 0]], [for (p = pb) __to2d(p)]);
    rotate_extrude()
        polygon(p1);
}

module _spoon_handle_half(orientation) {
    cz = sh_length3 + 10; // add extra 10mm to ensure "clean cut"
    if (orientation != "up" && orientation != "down" ) {
        assert(false, "Invalid orientation");
    }
    sx = (orientation == "up") ? 1 : -1;
    difference() {
        _spoon_handle_full();
        translate([-sh_width1/2 * sx, 0, cz/2 - 5]) // 5mm = half of that "extra"
            cube([sh_width1, sh_width1, cz], center = true);
    }

}

module _spoon_handle_f() {
    rotate(a=[0, 90, 0])
    difference() {
        _spoon_handle_full();
        scale([0.85, 0.8, 0.95])
            _spoon_handle_full();
    }
}

module _spoon_handle_h(orientation) {
    rotate(a=[0, 90, 0])
    difference() {
        _spoon_handle_half(orientation);
        scale([0.85, 0.8, 0.95])
            _spoon_handle_half(orientation);
    }
}

//_spoon_handle_h("down");

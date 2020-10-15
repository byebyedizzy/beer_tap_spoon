include <threads.scad>;
include <spoon_handle2.scad>;

// сначала опишем параметры выступов, т.к. от них зависят внутренние диаметры
st_side_knob_w1 = 10.5;   // + 0.5; // внешняя ширина выступа
st_side_knob_w2 = 8.5;    // + 0.5; // внутренняя ширина выступа
st_side_knob_dia1 = 43.5; // внешний, самый большой диаметр по двум выступам
st_side_knob_dia2 = st_side_knob_dia1 - 2*2.5; // диаметр по внутренней ступеньке
st_side_knob_dia3 = 34.5; // диаметр "ствола", на котором крепится выступ

// параметры "резьбовой" части
st_thread_angle = 135; //150;
st_thread_z1 = 3.5;
st_thread_z2 = 10;
st_thread_pitch = (st_thread_z2 - st_thread_z1) * 360 / st_thread_angle; // from 3.5 to 9mm for 160 degrees
st_thread_height = (st_thread_z2 - st_thread_z1);
st_thread_depth = 5;

st_thread_start_offset = 5;
st_thread_end_offset = 1.5;
st_stopper_height = 13;
st_stopper_width = 2; //1.5;

//
st_dia_outer = 54; // внешний диаметр верхней части
st_height    = 30; // + 10; //26.5; // высота верхней части
st_dia_inner = st_side_knob_dia3 + 1;
st_wall_thickness = (st_dia_outer - st_dia_inner)/2 - st_thread_depth; // 5;;

// --- spoon bottom ---
sb_dia_outer = st_dia_outer; // внешний диаметр
sb_wall_thickness = st_wall_thickness + 5; // толщина стенки нижней части

sb_holder_bottom = 7; // толщина держателя

sb_bne_dia1 = 28; // диаметр горлышка до расширения
sb_bne_dia2 = 32; // диаметр горлышка после расширения
sb_bne_height = 2; // высота расширения
sb_bnh_height = 36; // высота головки горлышка бутылки 

sb_height = sb_bnh_height + sb_holder_bottom + 7; // 40; // полная высота: головка горлышка + толщина держателя снизу + доп. несколько мм для верхней части окошка держателя

sb_wh_bne_offset = 14; // расстояние от нижней части горлышка до верхней части углубления проволочного держателя пробки
sb_wh_wire_dia = 3; // диаметр проволоки держателя пробки
sb_wh_width1 = 43; // ширина 1 (около горлышка) проволочного держателя пробки
sb_wh_width2 = 48; // ширина 2 (около петли) проволочного держателя пробки
sb_wh_width3 = 56; // ширина второй части держателя, с пробкой
sb_wh_depth = 12; // глубина держателя

sb_wh_loop_dia = 10; // диаметр петельки держателя

sb_wh_arc_width = 41; // ширина дуги держателя. При построении нужно учесть еще толщину проволоки петельки
sb_wh_arc_height = 17; // высота дуги держателя
// "эмулируем" дугу трапецией такой высоты. Верхняя стороны трапеции - ширина горлышка бутылки (sb_bne_dia2), нижняя сторона - sb_wh_arc_width
sb_wh_arc_height1 = sb_wh_arc_height - sb_wh_wire_dia;

// ------------------- number of faces -----------------------
nof = $preview ? 20 : 100;
echo (nof=nof);

// ------------------- wire holder -----------------------
// проволочный держатель - самая неудобная часть. Крепится к горлышку бутылки, представляет собой
// две проволочные фигуры
//
module sb_wh () {
    // "трапеция" для держателя
    //translate([0, 0, -sb_wh_wire_dia])
    union() {
        translate([0, 0, -sb_wh_wire_dia/2])
            minkowski() {
                linear_extrude(sb_wh_wire_dia)
                    //polygon([[-sb_wh_width1/2, sb_wh_wire_dia/2], [-sb_wh_width2/2, -sb_bne_dia2],
                    //         [sb_wh_width2/2, -sb_bne_dia2], [sb_wh_width1/2, sb_wh_wire_dia/2]]);
                    polygon([[-sb_wh_width1/2, sb_wh_wire_dia/2], [-sb_wh_width2/2, -sb_wh_depth],
                             [sb_wh_width2/2, -sb_wh_depth], [sb_wh_width1/2, sb_wh_wire_dia/2]]);
                sphere(1); //, center=true);
            }
        
        // "дополнения" к держателю - увеличим размеры для корректного выреза из большого объема
        ey = sb_dia_outer/2;
        //ey = sb_wh_loop_dia;
        // петелька держателя
        /*
        color("brown")
        translate([0, -ey/2 - sb_wh_depth, -sb_wh_loop_dia/2 + sb_wh_wire_dia])
            cube([sb_wh_width2, ey, sb_wh_loop_dia], center = true);
        */
        
        // дуга держателя
        color("cyan")
        translate([0, -sb_wh_depth, sb_wh_wire_dia])
            rotate(a=[90, 0, 0])
                linear_extrude(ey) //sb_wh_wire_dia)
                    //polygon([[-sb_wh_arc_width/2, 0], [-sb_bne_dia2/2, sb_wh_arc_height],
                    //         [sb_bne_dia2/2, sb_wh_arc_height], [sb_wh_arc_width/2, 0]]);
                    polygon([[-sb_dia_outer/2, 0], [-sb_bne_dia2/2, sb_wh_arc_height],
                             [sb_bne_dia2/2, sb_wh_arc_height], [sb_dia_outer/2, 0]]);
                             
        // "вторая" часть держателя, с пробкой
        // Нарисуем в виде двух цилиндров для скругления плюс добавим куб вниз, чтобы 
        // полностью вырезать нижнюю часть и не печатать ее с поддержками, т.к.
        // в удержании бутылки она не участвует
        /*
        color("pink")
        translate([-sb_wh_width2/2, -sb_wh_depth-ey/2, sb_wh_wire_dia-sb_wh_loop_dia/2])
            rotate(a=[90, 0, 0])
                cylinder(d = sb_wh_loop_dia, h = ey, center = true, $fn = nof);
        color("pink")
        translate([+sb_wh_width2/2, -sb_wh_depth-ey/2, sb_wh_wire_dia-sb_wh_loop_dia/2])
            rotate(a=[90, 0, 0])
                cylinder(d = sb_wh_loop_dia, h = ey, center = true, $fn = nof);
        */
        //ez = sb_bnh_height - sb_wh_arc_height - sb_wh_loop_dia;
        ez = sb_bnh_height;
        color("orange")
        //translate([0, -sb_wh_depth-ey/2, 2*sb_wh_wire_dia-sb_wh_loop_dia/2-ez/2])
        translate([0, -sb_wh_depth-ey/2, sb_wh_wire_dia-ez/2])
            cube([sb_wh_width2 + sb_wh_loop_dia + 10, ey, ez], center = true);
    }
}

//translate([0, 0, -sb_height/2 + sb_holder_bottom + sb_wh_bne_offset - sb_wh_wire_dia])
//sb_wh();

// --------------------- bottom part of the spoon --------------------
module spoon_bottom() {
    ey = sb_dia_outer/2 + sb_wh_depth - sb_wh_wire_dia/2;
    tz = -sb_height/2 + sb_holder_bottom + sb_wh_bne_offset - sb_wh_wire_dia;
    
    difference() {
        
        union() {
            color("yellow")
            cylinder(d = sb_dia_outer, h = sb_height, center = true, $fn = nof);
            // добавим "фрагмент" тора для усиления крепления
            difference() {
                color("orange")
                //translate([0, 0, -sb_height/16])
                translate([0, 0, tz])
                    rotate_extrude(convexity=10, $fn = nof)
                        translate([sb_height/2, 0, 0])
                            circle(d = sb_height/3); //, center = true);
                translate([0, -ey+2, 0]) // 2 - подобрана
                    cube([2*sb_height, sb_height, sb_height], center = true);
                rotate(a=[0, 0, 180])
                    translate([0, -ey+2, 0]) // 2 - подобрана
                        cube([2*sb_height, sb_height, sb_height], center = true);
            }
        }
        
        // вырезаем нижний цилиндр
        color("red")
        translate([0, 0, -sb_height/2 + sb_holder_bottom/2])
            cylinder(d = sb_bne_dia1,
                     h = sb_holder_bottom, // можно и больше, но тут достаточно этого
                     center = true,
                     $fn = nof);
        
        // конусный вырез по форме нижней части головки горлышка
        d1 = sb_bne_dia1; //28;
        d2 = sb_bne_dia2;
        h = sb_bne_height;
        
        di = sb_dia_outer - 2*sb_wall_thickness;
        hi = h * (di - d1) / (d2 - d1);
        
        color("magenta")
        translate([0, 0, - sb_height/2 + hi/2 + sb_holder_bottom])
            //translate([0, 0, - sb_height/2])// - hi/2])
            cylinder(d1 = d1, d2 = di, h = hi, center = true, $fn = nof);


        // вырезаем верх до конусной части
        hi2 = sb_height - hi;
        color("cyan")
        translate([0, 0, (sb_height - hi2)/2 + sb_holder_bottom])
            cylinder(d = sb_dia_outer - 2*sb_wall_thickness,
                     h = hi2,
                     center = true,
                     $fn = nof);

        // конусный срез, переход от стенок верхней части к нижней,
        // чтобы можно было печатать без поддержек внутри
        // Жестко задается только "большой" диаметр, второй диаметр и высота
        // выбираются наугад, просто чтобы было удобно печатать
        dc = st_side_knob_dia1; // st_dia_outer - 2*st_wall_thickness;
        hc = sb_height/3;
        color("orange")
        translate([0, 0, sb_height/2 - hc/2])
            cylinder(d1 = dc/2, d2 = dc, h = hc, center = true, $fn = nof);
        
        // вырез для вставки горлышка
        /*
        hi3 = sb_bnh_height + sb_holder_bottom; // высота выреза для вставки горлышка бутылки
        translate([0, d1/2, - hi3/2 - (sb_height - hi3)/2])
            linear_extrude(hi3)
                polygon([[d1/2, -d1/2], [d2/2, d1/2], [-d2/2, d1/2], [-d1/2, -d1/2]]);
        */
        hi3 = sb_bnh_height + sb_holder_bottom; // высота выреза для вставки горлышка бутылки
        //hi4 = sb_height - sb_holder_bottom - h; // высота горлышка после расширения
        hi4 = sb_bnh_height - h;

        translate([0, 0, sb_holder_bottom - sb_height/2])
            rotate(a=[90, 0, 0])
                linear_extrude(hi3)
                    polygon([[d1/2, -sb_holder_bottom], [d1/2, 0], [d2/2, h], [d2/2, hi4],
                             [-d2/2, hi4], [-d2/2, h], [-d1/2, 0], [-d1/2, -sb_holder_bottom]]);
                             
        // вырез для проволочного держателя пробки
        //color("blue")
        translate([0, 0, tz])
            sb_wh();
    }
}

//spoon_bottom();


module spoon_bottom_test() {
        dc = st_dia_outer - 2*st_wall_thickness;
        hc = sb_height/3;
        color("orange")
        translate([0, 0, sb_height/2 - hc/2])
            cylinder(d1 = dc/2, d2 = dc, h = hc, center = true, $fn = nof);
}

//spoon_bottom_test();


module pegas_spoon(){
    import("pegas_spoon_main.stl");
}

//color("red")
//translate([spoon_top_outer_dia/2, 0, 0])
//    pegas_spoon();

module spoon_top() {
    //knob_len = st_side_knob_dia1; // + 0.5;
    knob_width1 = st_side_knob_w1 + 2*0.5;
    knob_width2 = st_side_knob_w2 + 2*0.5;
    knob_ofs = (st_side_knob_dia1 - st_side_knob_dia2)/2 + 0.5;
    
    difference() {
        union() {
            difference() {
                //color("green")
                cylinder(d = st_dia_outer, h = st_height, center = true, $fn = nof);
                
                // cut out inner cylinders
                cylinder(d = st_dia_inner, h = st_height + 1, center = true, $fn = nof);
                
                translate([0, 0, -st_thread_height/2 - st_thread_z1])
                    //cylinder(d = st_dia_inner + 2*st_thread_depth, //st_dia_outer - 2*st_wall_thickness,
                    cylinder(d = st_side_knob_dia1, //knob_len,
                             h = st_height - st_thread_height,
                             center = true,
                             $fn = nof);
                // cut out thread
                translate([0, 0, (st_height/2 - st_thread_height/2) - st_thread_z1])
                    spoon_threads();
            }
            // stopper
            rotate(a=[0, 0, (180 - st_thread_angle)/2])
                spoon_knob_stopper(knob_width1);
        }
        // pitch for side knobs
        rotate(a=[0, 0, (180 - st_thread_angle)/2])
            translate([0, 0, st_height/2])
                //spoon_knob(knob_len, knob_width1, knob_width2, knob_ofs, st_height);
                spoon_knob(st_side_knob_dia1, knob_width1, knob_width2, knob_ofs, st_height);
    }
   
}

// ----------------------- threads ---------------------------------------
module spoon_thread(dia_outer, pitch, height, depth, angle) {
    difference() {
        // mirror and center
        mirror(v=[1, 0, 0])
            translate ([0, 0, -height/2])
                metric_thread ( diameter = dia_outer,
                                pitch = pitch,
                                length = height,
                                n_starts=1, //2,
                                square = true
                                );
        
        // cut out part of thread
        n = dia_outer + 1; // extra 1mm to ensure smooth cut
        translate ([0, -n/2, height/2])
            cube([n, n, 2*height + 1], center = true);

        rotate(a=[0, 0, 180 - angle])
            translate ([0, -n/2, height/2])
                cube([n, n, 2*height + 1], center = true);

        cylinder(d = dia_outer - 2*depth,
                 h = 2*height + 1,
                 center = true,
                 $fn = nof);
    }
}


// 2 threads
module spoon_threads() {
    spoon_thread(dia_outer = st_side_knob_dia1, //st_dia_inner + 2*st_thread_depth, //st_dia_outer - 2*st_wall_thickness,
                 pitch = st_thread_pitch,
                 height = st_thread_height,
                 depth = st_thread_depth,
                 angle = st_thread_angle);

    rotate(a=[0, 0, 180])
        spoon_thread(dia_outer = st_side_knob_dia1, //st_dia_inner + 2*st_thread_depth, //st_dia_outer - 2*st_wall_thickness,
                     pitch = st_thread_pitch,
                     height = st_thread_height,
                     depth = st_thread_depth,
                     angle = st_thread_angle);
}
//spoon_threads();
// -----------------------------------------------------------------------

// выступы с двух сторон
// kl - "внешняя" длина
// kw1, kw2 - две ширины выступа
// kofs - "глубина" выступа
// kz - высота фигуры (для выреза)
module spoon_knob(kl, kw1, kw2, kofs, kz) {
    //kx = st_side_knob_dia1 + 0.5;
    //ky = st_side_knob_w1 + 0.5;
    difference() {
        color("red") cube([kl, kw1, kz], center=true);
        
        translate([0, kw1/2, 0])
            cube([kl - 2*kofs, kw1 - kw2, kz], center=true);
        translate([0, -kw1/2, 0])
            cube([kl - 2*kofs, kw1 - kw2, kz], center=true);
        
        // round up edge of cube
        difference() {
            cylinder(d = st_dia_outer, h = kz, center = true, $fn = nof);
            //cylinder(d = st_dia_outer - 2*st_wall_thickness, h = st_height, center = true, $fn = nof);
            cylinder(d = kl, h = kz, center = true, $fn = nof);
        }
    }
}

// стоппер делаем не как прямоугольник через центр, а как две параллельные половинки,
// каждая со смещением offset_y от центра. Иначе получается "визуально кривой" стоппер
module spoon_knob_stopper_cube(offset_y) {
    color("red")
        translate([0, -(offset_y + st_stopper_width)/2, st_height/2 - st_stopper_height])
            //cube([st_side_knob_dia2/2 - 0.5, st_stopper_width, st_stopper_height]);
            cube([(st_dia_outer - 2*st_wall_thickness)/2, st_stopper_width, st_stopper_height]);
}

module spoon_knob_stopper(offset_y) {
    difference() {
        union() {
            spoon_knob_stopper_cube(st_side_knob_w1 + 0.5);
            rotate(a=[0, 0, 180])
                spoon_knob_stopper_cube(st_side_knob_w1 + 0.5);
        }
        cylinder(d = st_dia_inner, h = 2*st_height + 1, center = true, $fn = nof);
    }
}

module spoon_handle() {
    zh = st_height + sb_height;
    difference() {
        _spoon_handle_h("down");
        translate([0, 0, -zh/2])
            cylinder(d=st_dia_outer, h=zh);
    }
}

translate([0, 0, st_height/2])
    spoon_top();
translate([0, 0, -sb_height/2])
    spoon_bottom();
rotate(a=[0, 0, -10])
    translate([0, 0, -5])
        spoon_handle();

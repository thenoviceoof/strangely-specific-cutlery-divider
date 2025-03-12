// Drawer Divider System with Cross Lap and Box Joints
// Dimensions are in mm

// Main drawer dimensions
drawer_length = 489;
drawer_depth = 248;
divider_height = 3 * 25.4; // 3 inches converted to mm
material_thickness = 5.4;

// Number of divisions
columns = 3; // dividing the depth into 3 equal columns
rows = 2; // dividing 2 of the columns into 2 equal rows

// Calculate dimensions for parts
column_width = drawer_depth / columns;
row_length = drawer_length / rows;

// Box joint parameters
finger_count = 5; // Number of fingers for box joints
finger_width = divider_height / (finger_count * 2 - 1);

// Cross lap joint parameters
lap_width = material_thickness;

// Tolerance for joints (adjust as needed for your laser cutter)
tolerance = 0.1;

// Module for creating a panel with box joints on specified edges
module panel_with_box_joints(length, width, edges = [1, 1, 1, 1]) {
    difference() {
        square([length, width]);
        
        // Add box joints on edges as specified
        // edge order: bottom, right, top, left
        
        // Bottom edge
        if (edges[0]) {
            for (i = [1 : 2 : finger_count * 2 - 1]) {
                translate([i * length / (finger_count * 2), -tolerance])
                    square([length / (finger_count * 2), material_thickness + tolerance * 2]);
            }
        }
        
        // Right edge
        if (edges[1]) {
            for (i = [1 : 2 : finger_count * 2 - 1]) {
                translate([length - material_thickness - tolerance, i * width / (finger_count * 2)])
                    square([material_thickness + tolerance * 2, width / (finger_count * 2)]);
            }
        }
        
        // Top edge
        if (edges[2]) {
            for (i = [1 : 2 : finger_count * 2 - 1]) {
                translate([i * length / (finger_count * 2), width - material_thickness - tolerance])
                    square([length / (finger_count * 2), material_thickness + tolerance * 2]);
            }
        }
        
        // Left edge
        if (edges[3]) {
            for (i = [1 : 2 : finger_count * 2 - 1]) {
                translate([-tolerance, i * width / (finger_count * 2)])
                    square([material_thickness + tolerance * 2, width / (finger_count * 2)]);
            }
        }
    }
}

// Module for creating a divider with cross lap cutouts
module divider_with_cross_laps(length, is_vertical = false) {
    difference() {
        square([length, divider_height]);
        
        if (is_vertical) {
            // Horizontal dividers intersect this vertical divider
            for (i = [1 : rows - 1]) {
                translate([-tolerance, i * row_length - lap_width/2])
                    square([length + tolerance * 2, lap_width]);
            }
        } else {
            // Vertical dividers intersect this horizontal divider
            for (i = [1 : columns - 1]) {
                translate([i * column_width - lap_width/2, -tolerance])
                    square([lap_width, divider_height + tolerance * 2]);
            }
        }
    }
}

// Module for extruding 2D shapes to 3D with proper thickness
module extrude_part(part_module, params) {
    linear_extrude(height = material_thickness) {
        part_module(params);
    }
}

// Layout all parts for cutting (2D)
module layout_parts_2d() {
    // Exterior walls (with box joints)
    // Bottom wall
    translate([0, 0])
        panel_with_box_joints(drawer_length, material_thickness, [0, 1, 0, 1]);
    
    // Top wall
    translate([0, material_thickness + 10])
        panel_with_box_joints(drawer_length, material_thickness, [0, 1, 0, 1]);
    
    // Left wall
    translate([0, material_thickness * 2 + 20])
        panel_with_box_joints(drawer_depth, material_thickness, [1, 0, 1, 0]);
    
    // Right wall
    translate([drawer_depth + 10, material_thickness * 2 + 20])
        panel_with_box_joints(drawer_depth, material_thickness, [1, 0, 1, 0]);
    
    // Vertical dividers (with cross laps)
    for (i = [1 : columns - 1]) {
        translate([0, material_thickness * 3 + 30 + (i-1) * (divider_height + 10)])
            divider_with_cross_laps(drawer_depth, true);
    }
    
    // Horizontal dividers (with cross laps)
    for (i = [1 : rows - 1]) {
        // Two shorter horizontal dividers for the first two columns
        translate([drawer_depth + 10, material_thickness * 3 + 30 + (columns-1) * (divider_height + 10) + (i-1) * (divider_height + 10)])
            divider_with_cross_laps(column_width * 2);
    }
}

// Create 3D version for preview
module preview_3d() {
    // Exterior walls
    color("SandyBrown") {
        // Bottom wall
        translate([0, 0, 0])
            linear_extrude(height = material_thickness)
                panel_with_box_joints(drawer_length, material_thickness, [0, 1, 0, 1]);
        
        // Top wall
        translate([0, drawer_depth - material_thickness, 0])
            linear_extrude(height = material_thickness)
                panel_with_box_joints(drawer_length, material_thickness, [0, 1, 0, 1]);
        
        // Left wall
        rotate([90, 0, 0])
            translate([0, 0, 0])
                linear_extrude(height = material_thickness)
                    panel_with_box_joints(drawer_depth, divider_height, [1, 0, 1, 0]);
        
        // Right wall
        rotate([90, 0, 0])
            translate([drawer_length - material_thickness, 0, -drawer_depth])
                linear_extrude(height = material_thickness)
                    panel_with_box_joints(drawer_depth, divider_height, [1, 0, 1, 0]);
    }
    
    // Vertical dividers
    color("Peru") {
        for (i = [1 : columns - 1]) {
            rotate([90, 0, 0])
                translate([i * column_width - material_thickness/2, 0, -drawer_depth])
                    linear_extrude(height = drawer_depth)
                        divider_with_cross_laps(divider_height, true);
        }
    }
    
    // Horizontal dividers
    color("Sienna") {
        for (i = [1 : rows - 1]) {
            translate([0, i * row_length - material_thickness/2, 0])
                linear_extrude(height = divider_height)
                    divider_with_cross_laps(column_width * 2);
        }
    }
}

// Choose what to display
if ($preview) {
    // 3D preview for interactive view
    preview_3d();
} else {
    // 2D projection for laser cutting
    layout_parts_2d();
}
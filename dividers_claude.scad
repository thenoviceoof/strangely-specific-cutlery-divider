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
                translate([-tolerance, i * divider_height / rows - lap_width/2])
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

// Layout all parts for cutting
module layout_parts() {
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

// Set view to 2D for laser cutting
projection() layout_parts();
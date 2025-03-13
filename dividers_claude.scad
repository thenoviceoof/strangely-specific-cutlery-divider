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
finger_width = divider_height / (finger_count * 2);

// Tolerance for joints (adjust as needed for your laser cutter)
tolerance = 0.1;

// Function to create points for a box joint edge
function box_joint_edge(length, num_fingers, finger_size, is_horizontal = true, is_reversed = false) = 
    let(step = length / (num_fingers * 2))
    [for (i = [0 : num_fingers * 2]) 
        is_horizontal ? 
            (is_reversed ? 
                [i * step, (i % 2 == 0) ? 0 : finger_size] :
                [i * step, (i % 2 == 0) ? finger_size : 0]) :
            (is_reversed ? 
                [(i % 2 == 0) ? 0 : finger_size, i * step] :
                [(i % 2 == 0) ? finger_size : 0, i * step])
    ];

// Panel with box joints on all sides
module exterior_panel(length, width, thickness, top_fingers = true, right_fingers = true, 
                      bottom_fingers = true, left_fingers = true) {
    finger_size = material_thickness;
    
    // Create the polygon points for the perimeter with box joints
    points = [];
    
    // Bottom edge
    bottom_edge = box_joint_edge(length, finger_count, finger_size, true, !bottom_fingers);
    
    // Right edge
    right_edge = box_joint_edge(width, finger_count, finger_size, false, right_fingers);
    for (i = [1:len(right_edge)-1]) {
        points = concat(points, [[length + right_edge[i][0], right_edge[i][1]]]);
    }
    
    // Top edge
    top_edge = box_joint_edge(length, finger_count, finger_size, true, top_fingers);
    for (i = [1:len(top_edge)-1]) {
        points = concat(points, [[length - top_edge[i][0], width + top_edge[i][1]]]);
    }
    
    // Left edge
    left_edge = box_joint_edge(width, finger_count, finger_size, false, !left_fingers);
    for (i = [1:len(left_edge)-1]) {
        points = concat(points, [[0 - left_edge[i][0], width - left_edge[i][1]]]);
    }
    
    polygon(concat([bottom_edge[0]], bottom_edge, [points[0]], points));
}

// Divider with cross lap joints
module vertical_divider(height, length, row_positions) {
    // Start with a rectangle
    points = [[0, 0], [thickness, 0], [thickness, length], [0, length]];
    
    // Cross lap cutouts
    for (pos = row_positions) {
        notch_height = material_thickness;
        notch_y = pos - notch_height/2;
        
        // This will be a complex polygon so we'll use difference() instead
        difference() {
            polygon(points);
            translate([-tolerance, notch_y])
                square([thickness + tolerance*2, notch_height]);
        }
    }
}

module horizontal_divider(length, height, column_positions) {
    // Complex shape with notches for cross laps
    difference() {
        square([length, height]);
        
        // Cut notches for vertical dividers
        for (pos = column_positions) {
            translate([pos - material_thickness/2, -tolerance])
                square([material_thickness, height + tolerance*2]);
        }
    }
}

// Layout all parts for laser cutting
module layout_for_cutting() {
    // Calculate row and column positions
    row_positions = [for (i = [1:rows-1]) i * row_length];
    column_positions = [for (i = [1:columns-1]) i * column_width];
    
    // Horizontal walls (top and bottom)
    translate([0, 0])
        exterior_panel(drawer_length, material_thickness, material_thickness, 
                     true, true, true, true);
    
    translate([0, material_thickness + 10])
        exterior_panel(drawer_length, material_thickness, material_thickness, 
                     true, true, true, true);
    
    // Vertical walls (left and right)
    translate([0, material_thickness * 2 + 20])
        exterior_panel(drawer_depth, divider_height, material_thickness, 
                     true, true, true, true);
    
    translate([drawer_depth + 10, material_thickness * 2 + 20])
        exterior_panel(drawer_depth, divider_height, material_thickness, 
                     true, true, true, true);
    
    // Vertical dividers
    for (i = [1:columns-1]) {
        translate([0, material_thickness * 2 + divider_height + 30 + (i-1) * (divider_height + 10)])
            horizontal_divider(drawer_depth, divider_height, []);
    }
    
    // Horizontal dividers (for 2 columns only)
    for (i = [1:rows-1]) {
        translate([drawer_depth + 10, material_thickness * 2 + divider_height + 30 + (columns-1) * (divider_height + 10) + (i-1) * (divider_height + 10)])
            horizontal_divider(column_width * 2, divider_height, column_positions);
    }
}

// Generate alternative design with simple tab and slot joints
module alternative_design() {
    // Vertical dividers (full height)
    for (i = [1:columns-1]) {
        x = i * column_width;
        translate([x - material_thickness/2, 0, 0]) {
            difference() {
                square([material_thickness, drawer_depth]);
                
                // Slots for horizontal dividers
                for (j = [1:rows-1]) {
                    if (x <= column_width * 2) { // Only for first two columns
                        y = j * row_length;
                        translate([-tolerance, y - material_thickness/2])
                            square([material_thickness + tolerance*2, material_thickness]);
                    }
                }
            }
        }
    }
    
    // Horizontal dividers (for first two columns only)
    for (j = [1:rows-1]) {
        y = j * row_length;
        translate([0, y - material_thickness/2, 0]) {
            difference() {
                square([column_width * 2, material_thickness]);
                
                // Slots for vertical dividers
                for (i = [1:columns-1]) {
                    x = i * column_width;
                    if (x <= column_width * 2) { // Only for dividers within range
                        translate([x - material_thickness/2, -tolerance])
                            square([material_thickness, material_thickness + tolerance*2]);
                    }
                }
            }
        }
    }
    
    // Outer frame
    difference() {
        square([drawer_length, drawer_depth]);
        translate([material_thickness, material_thickness])
            square([drawer_length - material_thickness*2, drawer_depth - material_thickness*2]);
        
        // Slots for vertical dividers in outer frame
        for (i = [1:columns-1]) {
            x = i * column_width;
            
            // Bottom edge
            translate([x - material_thickness/2, 0])
                square([material_thickness, material_thickness]);
            
            // Top edge
            translate([x - material_thickness/2, drawer_depth - material_thickness])
                square([material_thickness, material_thickness]);
        }
        
        // Slots for horizontal dividers in outer frame
        for (j = [1:rows-1]) {
            y = j * row_length;
            
            // Left edge (only for dividers in first two columns)
            translate([0, y - material_thickness/2])
                square([material_thickness, material_thickness]);
            
            // Right edge of second column
            translate([column_width * 2 - material_thickness, y - material_thickness/2])
                square([material_thickness, material_thickness]);
        }
    }
}

// Layout parts for export
module final_layout() {
    // Exterior walls
    // Bottom wall
    translate([0, 0]) {
        difference() {
            square([drawer_length, material_thickness]);
            
            // Slots for vertical dividers
            for (i = [1:columns-1]) {
                x = i * column_width;
                translate([x - material_thickness/2, -tolerance])
                    square([material_thickness, material_thickness + tolerance*2]);
            }
        }
    }
    
    // Top wall
    translate([0, material_thickness + 10]) {
        difference() {
            square([drawer_length, material_thickness]);
            
            // Slots for vertical dividers
            for (i = [1:columns-1]) {
                x = i * column_width;
                translate([x - material_thickness/2, -tolerance])
                    square([material_thickness, material_thickness + tolerance*2]);
            }
        }
    }
    
    // Left wall
    translate([0, material_thickness * 2 + 20]) {
        difference() {
            square([material_thickness, drawer_depth]);
            
            // Slots for horizontal dividers
            for (j = [1:rows-1]) {
                y = j * row_length;
                translate([-tolerance, y - material_thickness/2])
                    square([material_thickness + tolerance*2, material_thickness]);
            }
        }
    }
    
    // Right wall
    translate([material_thickness + 10, material_thickness * 2 + 20]) {
        difference() {
            square([material_thickness, drawer_depth]);
            
            // No slots needed as this is the rightmost wall
        }
    }
    
    // Far right wall (at column 2)
    translate([material_thickness*2 + 20, material_thickness * 2 + 20]) {
        difference() {
            square([material_thickness, drawer_depth]);
            
            // Slots for horizontal dividers
            for (j = [1:rows-1]) {
                y = j * row_length;
                translate([-tolerance, y - material_thickness/2])
                    square([material_thickness + tolerance*2, material_thickness]);
            }
        }
    }
    
    // Vertical dividers (with cross lap joints)
    y_offset = material_thickness * 2 + drawer_depth + 30;
    
    for (i = [1:columns-1]) {
        translate([0, y_offset + (i-1) * (divider_height + 10)]) {
            difference() {
                square([drawer_depth, divider_height]);
                
                // Cross lap cutouts for horizontal dividers
                for (j = [1:rows-1]) {
                    if (i * column_width <= column_width * 2) { // Only for first two columns
                        translate([i * column_width - material_thickness/2, -tolerance])
                            square([material_thickness, divider_height + tolerance*2]);
                    }
                }
            }
        }
    }
    
    // Horizontal divider (spans first two columns)
    translate([0, y_offset + (columns-1) * (divider_height + 10)]) {
        difference() {
            square([column_width * 2, divider_height]);
            
            // Cross lap cutouts for vertical dividers
            for (i = [1:columns-1]) {
                if (i * column_width <= column_width * 2) {
                    translate([i * column_width - material_thickness/2, -tolerance])
                        square([material_thickness, divider_height + tolerance*2]);
                }
            }
        }
    }
}

// Choose what to render
final_layout(); 
module clipColumn() {
  union() {
    difference() {
      // Main column cube
      cube([7, 7, 20]);

      // Cut out middle section
      translate([1, 1, 0]) {
        cube([5.1, 5.1, 20]);
      };

      // Cut bottom
      translate([0, 6, 0]) {
        cube([5, 1, 5]);
      };

      // Cut middle
      translate([2, 6, 5]) {
        cube([5, 1, 5]);
      };

      // Cut middle
      translate([0, 6, 10]) {
        cube([5, 1, 5]);
      };

      // Cut top
      translate([2, 6, 15]) {
        cube([5, 1, 5]);
      };
    }

    // Solid column
    translate([0, -7, 0]) {
      cube([7, 7, 15 + 15 + 25]);
    }

    // Make the clips have a 45 degree tilt so it can be printed
    // with the top printed first.
    // Otherwise the slicer would complain about these being cantilevers.
    translate([0, 2, 15]) {
      difference() {
        rotate([45, 0, 0]) {
          cube([7, 7, 10]);
        }
        translate([1, 0, 0]) {
          cube([5, 10, 10]);
        }
      }
    }
  }
}

clipColumn();
translate([0, -7, 15 + 15 + 25]) {
  cube([120, 7, 7]);
}
translate([120 - 7, 0, 0]) {
  clipColumn();
}

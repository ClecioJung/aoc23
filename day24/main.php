#!/usr/bin/php

<?php

function parse_input($file_path) {
    $lines = explode("\n", file_get_contents($file_path));
    $hailstones = array();
    foreach ($lines as $line) {
        $exploded_line = explode(" @ ", $line);
        $position = array_map(function ($element) {
            return intval($element);
        }, explode(", ", $exploded_line[0]));
        $velocity = array_map(function ($element) {
            return intval($element);
        }, explode(", ", $exploded_line[1]));
        $hailstone = array(
            "pos" => $position,
            "vel" => $velocity
        );
        array_push($hailstones, $hailstone);
    }
    return $hailstones;
}

function paths_will_cross_xy($hail_1, $hail_2, $min, $max) {
    $px1 = $hail_1["pos"][0];
    $py1 = $hail_1["pos"][1];
    $vx1 = $hail_1["vel"][0];
    $vy1 = $hail_1["vel"][1];
    $px2 = $hail_2["pos"][0];
    $py2 = $hail_2["pos"][1];
    $vx2 = $hail_2["vel"][0];
    $vy2 = $hail_2["vel"][1];
    // Parametric equations of the line:
    // x = px + vx*t
    // y = py + vy*t
    $det = $vy1*$vx2 - $vx1*$vy2;
    if ($det == 0) { // the paths are parallel
        return false;
    }
    // The problem for part01 ask us to discover if the paths cross with
    // each other, and not if the particles will colide (t1 != t2)
    $t1 = ($vx2*($py2-$py1) - $vy2*($px2-$px1))/$det;
    $t2 = ($vx1*($py2-$py1) - $vy1*($px2-$px1))/$det;
    if (($t1 < 0) || ($t2 < 0)) {
        return false;
    }
    $x = $px1 + $vx1*$t1;
    $y = $py1 + $vy1*$t1;
    return ($min < $x && $x < $max) && ($min < $y && $y < $max);
}

function part01($file_path, $min, $max) {
    $hailstones = parse_input($file_path);
    $crossing_paths = 0;
    for ($i = 0; $i < count($hailstones); $i++) {
        for ($j = $i+1; $j < count($hailstones); $j++) {
            if (paths_will_cross_xy($hailstones[$i], $hailstones[$j], $min, $max)) {
                $crossing_paths += 1;
            }
        }
    }
    return $crossing_paths;
}

function gaussian_elimination($A, $b) {
    $rows = count($A);
    for ($k = 0; ($k + 1) < $rows; $k++) {
        $w = abs($A[$k][$k]);
        // Partial pivoting
        $r = $k;
        for ($i = ($k + 1); $i < $rows; $i++) {
            if (abs($A[$i][$k]) > $w) {
                $w = abs($A[$i][$k]);
                $r = $i;
            }
        }
        if ($r != $k) {
            for ($i = $k; $i < $rows; $i++) {
                $temp = $A[$k][$i];
                $A[$k][$i] = $A[$r][$i];
                $A[$r][$i] = $temp;
            }
            $temp = $b[$k];
            $b[$k] = $b[$r];
            $b[$r] = $temp;
        }
        // Forward elimination
        for ($i = ($k + 1); $i < $rows; $i++) {
            $m = $A[$i][$k] / $A[$k][$k];
            for ($j = ($k + 1); $j < $rows; $j++) {
                $A[$i][$j] -= $m * $A[$k][$j];
            }
            $b[$i] -= $m * $b[$k];
        }
    }
    // Back substitution
    for ($i = ($rows - 1); $i >= 0; $i--) {
        for ($j = ($i + 1); $j < $rows; $j++) {
            $b[$i] -= $A[$i][$j] * $b[$j];
        }
        $b[$i] /= $A[$i][$i];
    }
    return $b;
}

// The system is overdetermined, meaning not all input information is necessary to determine
// the rock's position and speed accurately. Only the first four lines of information are
// utilized in these calculations. The problem is formulated as a linear system comprising
// six equations. Solving this system yields the values for the six unknowns: the rock's
// position and velocity. The linear system is solved using the Gaussian elimination.
function solve_for_rock_position($hail_1, $hail_2, $hail_3, $hail_4) {
    // first
    $px1 = $hail_1["pos"][0];
    $py1 = $hail_1["pos"][1];
    $pz1 = $hail_1["pos"][2];
    $vx1 = $hail_1["vel"][0];
    $vy1 = $hail_1["vel"][1];
    $vz1 = $hail_1["vel"][2];
    // second
    $px2 = $hail_2["pos"][0];
    $py2 = $hail_2["pos"][1];
    $pz2 = $hail_2["pos"][2];
    $vx2 = $hail_2["vel"][0];
    $vy2 = $hail_2["vel"][1];
    $vz2 = $hail_2["vel"][2];
    // third
    $px3 = $hail_3["pos"][0];
    $py3 = $hail_3["pos"][1];
    $pz3 = $hail_3["pos"][2];
    $vx3 = $hail_3["vel"][0];
    $vy3 = $hail_3["vel"][1];
    $vz3 = $hail_3["vel"][2];
    // forth
    $px4 = $hail_4["pos"][0];
    $py4 = $hail_4["pos"][1];
    $pz4 = $hail_4["pos"][2];
    $vx4 = $hail_4["vel"][0];
    $vy4 = $hail_4["vel"][1];
    $vz4 = $hail_4["vel"][2];
    // For the first hail, we have:
    // x = px1 + t1*vx1 = rx + t1*vrx
    // y = py1 + t1*vy1 = ry + t1*vry
    // z = pz1 + t1*vz1 = rz + t1*vrz
    // where (rx, ry, rz) is the initial position of the rock and
    // (vrx, vry, vrz) is its initial velocity.
    // Solving for the time t1, we get:
    // t1 = (rx-px1)/(vx1-vrx) = (ry-py1)/(vy1-vry) = (rz-pz1)/(vz1-vrz)
    // simplifying, we get the next two equations:
    // rx*vry + ry*vrx - vy1*rx - px1*vry + vx1*ry + py1*vrx + px1*vy1 - py1*vx1 = 0    (1)
    // rx*vrz + rz*vrx - vz1*rx - px1*vrz + vx1*rz + pz1*vrx + px1*vz1 - pz1*vx1 = 0    (2)
    // In a similar way, we obtain the following equations for hail 2:
    // rx*vry + ry*vrx - vy2*rx - px2*vry + vx2*ry + py2*vrx + px2*vy2 - py2*vx2 = 0    (3)
    // rx*vrz + rz*vrx - vz2*rx - px2*vrz + vx2*rz + pz2*vrx + px2*vz2 - pz2*vx2 = 0    (4)
    // Computing (1)-(3), the non-linear terms are eliminated, and we obtain:
    // (vy2-vy1)*rx + (px2-px1)*vry + (vx1-vx2)*ry + (py1-py2)*vrx = (px2*vy2 - py2*vx2 - px1*vy1 + py1*vx1)
    // Analagously for (2)-(4):
    // (vz2-vz1)*rx + (px2-px1)*vrz + (vx1-vx2)*rz + (pz1-pz2)*vrx = (px2*vz2 - pz2*vx2 - px1*vz1 + pz1*vx1)
    // Similar equations can be obtained for the other hails. This equations are linear
    // and compose the matrix system bellow, which can be solved with gaussian elimination.
    $A = array(
        array($vy2-$vy1, $vx1-$vx2, 0, $py1-$py2, $px2-$px1, 0),
        array($vy3-$vy1, $vx1-$vx3, 0, $py1-$py3, $px3-$px1, 0),
        array($vy4-$vy1, $vx1-$vx4, 0, $py1-$py4, $px4-$px1, 0),
        array($vz2-$vz1, 0, $vx1-$vx2, $pz1-$pz2, 0, $px2-$px1),
        array($vz3-$vz1, 0, $vx1-$vx3, $pz1-$pz3, 0, $px3-$px1),
        array($vz4-$vz1, 0, $vx1-$vx4, $pz1-$pz4, 0, $px4-$px1)
    );
    $b = array(
        $py1*$vx1-$px1*$vy1+$px2*$vy2-$py2*$vx2,
        $py1*$vx1-$px1*$vy1+$px3*$vy3-$py3*$vx3,
        $py1*$vx1-$px1*$vy1+$px4*$vy4-$py4*$vx4,
        $pz1*$vx1-$px1*$vz1+$px2*$vz2-$pz2*$vx2,
        $pz1*$vx1-$px1*$vz1+$px3*$vz3-$pz3*$vx3,
        $pz1*$vx1-$px1*$vz1+$px4*$vz4-$pz4*$vx4
    );
    $x = gaussian_elimination($A, $b);
    return array(
        "pos" => array_slice($x, 0, 3),
        "vel" => array_slice($x, 3, 3)
    );
}

function part02($file_path) {
    $hailstones = parse_input($file_path);
    $rock = solve_for_rock_position($hailstones[0], $hailstones[1], $hailstones[2], $hailstones[3]);
    return intval(array_sum($rock["pos"]));
}

function main() {
    assert(part01("sample.txt", 7, 27) == 2, "Part 01 failed for sample.txt");
    $part01output = part01("input.txt", 200000000000000, 400000000000000);
    echo("Part 01: " . $part01output . "\n");
    assert($part01output == 21785, "Part 01 failed for input.txt");
    assert(part02("sample.txt") == 47, "Part 02 failed for sample.txt");
    $part02output = part02("input.txt");
    echo("Part 02: " . $part02output . "\n");
    assert($part02output == 554668916217145, "Part 02 failed for input.txt");
}

main();

?>

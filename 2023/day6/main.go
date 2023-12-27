package main

import (
	"math"
	"os"
)

const testSolution_part1 = 288
const testSolution_part2 = 71503

func solve(T, D []float64) int {
    var ret int = -1
    fx := func(i int, x int) int {
        return (int(T[i]) * x) - (x * x)
    }

    for i := 0; i < len(T); i++ {
        // a := 1.
        b := -T[i]
        c := D[i]
        SQRT := math.Sqrt((b * b) - (4 * c))
        Qp := (-b + SQRT) / 2
        Qm := (-b - SQRT) / 2
        if Qp < Qm {
            t := Qp
            Qp = Qm
            Qm = t
        }
        upper := int(math.Floor(Qp))
        lower := int(math.Ceil(Qm))
        y := int(D[i])
        if y == fx(i, upper) { upper -= 1 }
        if y == fx(i, lower) { lower += 1 }
        if ret == -1 { 
            ret = upper - lower + 1
        } else {
            ret *= upper - lower + 1
        }
    }
    return ret
}

/* Part 1
func main() {
    timeArray_test := []float64{7, 15, 30}
    distArray_test := []float64{9, 40, 200}
    timeArray_prod := []float64{59, 68, 82, 74}
    distArray_prod := []float64{543, 1020, 1664, 1022}
    if solve(timeArray_test, distArray_test) != testSolution_part1 {
        println("Test failed! Not continuing to production.")
        os.Exit(0)
    }

    println("Solution:", solve(timeArray_prod, distArray_prod))
}
*/

func main() {
    timeArray_test := []float64{71530}
    distArray_test := []float64{940200}
    timeArray_prod := []float64{59688274}
    distArray_prod := []float64{543102016641022}
    if solve(timeArray_test, distArray_test) != testSolution_part2 {
        println("Test failed! Not continuing to production.")
        os.Exit(0)
    }

    println("Solution:", solve(timeArray_prod, distArray_prod))
}

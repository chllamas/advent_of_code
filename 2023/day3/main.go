package main

import (
	"bufio"
	"fmt"
	"os"
	"unicode"
    "slices"
)

func main() {
    file, err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open file")
    }

    var result int
    var grid [][]rune
    gearPotentials := make(map[string][]int)
    scanner := bufio.NewScanner(file)
    checkSurroundings := func(x, y int) (bool, *string) {
        for j := y-1; j <= y+1; j++ {
            for i := x-1; i <= x+1; i++ {
                if i > 0 && j > 0 && i < len(grid) && j < len(grid) && (i != x || j != y) {
                    if !unicode.IsDigit(grid[j][i]) && grid[j][i] != '.' {
                        if grid[j][i] == '*' {
                            s := fmt.Sprintf("(%d, %d)", i, j)
                            return true, &s
                        }
                        return true, nil
                    }
                }
            }
        }
        return false, nil
    }

    for scanner.Scan() {
        line := scanner.Text()
        entry := make([]rune, len(line))
        for w := range line {
            entry[w] = rune(line[w])
        }
        grid = append(grid, entry)
    }

    for y,row := range grid {
        var num int
        var reading_number, will_be_valid bool
        var gearsFound []string
        reset_number := func() {
            if reading_number && will_be_valid {
                result += num
                for w := range gearsFound {
                    gearPotentials[gearsFound[w]] = append(gearPotentials[gearsFound[w]], num)
                }
            }
            gearsFound = []string{}
            reading_number = false
            will_be_valid = false
        }
        for x, c := range row {
            if unicode.IsDigit(c) {
                if reading_number {
                    num *= 10
                    num += int(c - '0')
                } else {
                    reading_number = true
                    num = int(c - '0')
                }
                symbolFound, gearId := checkSurroundings(x, y)
                will_be_valid = will_be_valid || symbolFound
                if gearId != nil && !slices.Contains(gearsFound, *gearId) {
                    gearsFound = append(gearsFound, *gearId)
                }
            } else {
                reset_number()
            }
        }
        reset_number()
    }
    println("Parts sum Result:", result)

    var gearRatioResult int
    for i := range gearPotentials {
        if len(gearPotentials[i]) == 2 {
            gearRatioResult += gearPotentials[i][0] * gearPotentials[i][1]
        }
    }
    println("Gear ratios result:", gearRatioResult)
}

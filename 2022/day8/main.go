package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

/*
PART 1
func main() {
    const MAX_EDGE_SIZE int = 99

    file, err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open file")
    }

    var m int
    scanner := bufio.NewScanner(file)
    lines := [MAX_EDGE_SIZE][MAX_EDGE_SIZE]string{}
    for scanner.Scan() {
        line := scanner.Text()
        for n, c := range strings.Split(line, "") {
            lines[m][n] = c
        }
        m += 1
    }

    var visibleTrees int
    for y := 0; y < MAX_EDGE_SIZE; y+=1 {
        for x := 0; x < MAX_EDGE_SIZE; x+=1 {
            if y == 0 || y == MAX_EDGE_SIZE-1 || x == 0 || x == MAX_EDGE_SIZE-1 {
                visibleTrees += 1
                continue
            }

            myValue := lines[y][x]
            isVisible := func(hor, ver int, dx, dy int) bool {
                for hor >= 0 && hor < MAX_EDGE_SIZE && ver >= 0 && ver < MAX_EDGE_SIZE {
                    if lines[ver][hor] >= myValue {
                        return false
                    }
                    hor += dx
                    ver += dy
                }
                return true
            }

            if isVisible(x-1, y, -1, 0) || isVisible(x+1, y, 1, 0) || isVisible(x, y-1, 0, -1) || isVisible(x, y+1, 0, 1) {
                visibleTrees += 1
            }
        }
    }

    fmt.Printf("There are %d visible trees.", visibleTrees)
}
*/ 

func main() {
    const MAX_EDGE_SIZE int = 99

    file, err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open file")
    }

    var m int
    scanner := bufio.NewScanner(file)
    lines := [MAX_EDGE_SIZE][MAX_EDGE_SIZE]string{}
    for scanner.Scan() {
        line := scanner.Text()
        for n, c := range strings.Split(line, "") {
            lines[m][n] = c
        }
        m += 1
    }

    var highestScore int
    for y := 0; y < MAX_EDGE_SIZE; y+=1 {
        for x := 0; x < MAX_EDGE_SIZE; x+=1 {
            if y == 0 || y == MAX_EDGE_SIZE-1 || x == 0 || x == MAX_EDGE_SIZE-1 {
                continue
            }

            myValue := lines[y][x]
            calculateScore := func(hor, ver int, dx, dy int) int {
                var ret int
                for hor >= 0 && hor < MAX_EDGE_SIZE && ver >= 0 && ver < MAX_EDGE_SIZE {
                    ret += 1
                    if lines[ver][hor] >= myValue {
                        return ret
                    }
                    hor += dx
                    ver += dy
                }
                return ret
            }

            myScore := calculateScore(x-1, y, -1, 0) * 
                calculateScore(x+1, y, 1, 0) * 
                calculateScore(x, y-1, 0, -1) * 
                calculateScore(x, y+1, 0, 1)
            if myScore > highestScore { highestScore = myScore }
        }
    }

    fmt.Printf("Highest score: %d\n", highestScore)
}

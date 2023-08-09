package main

import (
	"fmt"
	"math"
	"strings"
    "os"
    "bufio"
)

func main() {
    file,err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open file")
    }
    defer file.Close()

    var xMax,yMax,j int
    xMin := math.MaxInt
    shapes := [][][2]int{}
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        rawShape := scanner.Text()
        rawCoords := strings.Split(rawShape, " -> ")
        // maybe print to see that this is correct? ^^^^^^
        shapes = append(shapes, make([][2]int, len(rawCoords)))
        for i,rawCoord := range rawCoords {
            var x,y int
            fmt.Sscanf(rawCoord, "%d,%d", &x, &y)
            shapes [j][i] = [2]int{x, y}
            xMin = min(xMin, x)
            xMax = max(xMax, x)
            yMax = max(yMax, y)
        }
        j += 1
    }

    // 0 = air, 1 = rock, 2 = sand
    grid := make([][]int, yMax+1)
    for i := range grid {
        grid[i] = make([]int, xMax-xMin+1)
    }

    getDiff := func(x,y,m,n int) (dx,dy int) {
        if x > m {
            dx = -1
        } else if x < m {
            dx = 1
        }
        if y > n {
            dy = -1
        } else if y < n {
            dy = 1
        }
        return
    }
    for _,shape := range shapes {
        x,y := shape[0][0]-xMin, shape[0][1]
        for _,coord := range shape {
            m,n := coord[0]-xMin, coord[1]
            for {
                grid[y][x] = 1
                dx, dy := getDiff(x, y, m, n)
                if dx == 0 && dy == 0 { break }
                x += dx
                y += dy
            }
        }
    }

    var sandsDropped int
    simulation :
    for {
        x, y := 500-xMin, 0
        tick :
        for {
            changes := [][2]int{ [2]int{0,1}, [2]int{-1,0}, [2]int{2,0} }
            for _,diff := range changes {
                dx,dy := diff[0], diff[1]
                x += dx
                y += dy
                if y > yMax || x < 0 || x > xMax { break simulation }
                if grid[y][x] == 0 { 
                    continue tick
                }
            }
            grid[y-1][x-1] = 2
            break 
        }
        sandsDropped += 1
    }
    println("Simulation ended with result:", sandsDropped)
}

func printGrid(grid [][]int, xMin int) {
    for y := range grid {
        for x := range grid {
            if y == 0 && x == 500-xMin {
                print("+")
                continue
            }
            switch grid[y][x] {
            case 0:
                print(".")
            case 1:
                print("#")
            case 2:
                print("o")
            }
        }
        println()
    }
}

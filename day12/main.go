package main

import (
	"bufio"
	"os"
)

func main() {
    input, err := os.Open("in.txt")
    if err != nil {
        panic("Couldn't open file")
    }

    var grid [][]rune
    scanner := bufio.NewScanner(input)
    for scanner.Scan() {
        line := scanner.Text()
        grid = append(grid, []rune(line))
    }

    xLen, yLen := len(grid[0]), len(grid)
    var startPoints [][2]int
    var targetPoint [2]int
    for y, row := range grid {
        for x, elem := range row {
            if elem == 'S' || elem == 'a' {
                grid[y][x] = 'a'
                startPoints = append(startPoints, [2]int{x, y})
            }
            if elem == 'E' {
                grid[y][x] = 'z'
                targetPoint = [2]int{x, y}
            }
        }
    }

    getShortestPath := func(startPoint [2]int) int {
        Q := [][2]int{startPoint}
        visited := make(map[[2]int]int)
        for len(Q) > 0 {
            var nodeCoord [2]int
            nodeCoord, Q = Q[0], Q[1:]
            nodeVal := grid[nodeCoord[1]][nodeCoord[0]]
            neighbors := [4][2]int{
                [2]int{nodeCoord[0]  , nodeCoord[1]-1},
                [2]int{nodeCoord[0]  , nodeCoord[1]+1},
                [2]int{nodeCoord[0]-1, nodeCoord[1]  },
                [2]int{nodeCoord[0]+1, nodeCoord[1]  },
            }

            for _,neighborCoord := range neighbors {
                x, y := neighborCoord[0], neighborCoord[1]
                if x >= 0 && x < xLen && y >= 0 && y < yLen && neighborCoord != startPoint && visited[neighborCoord] == 0 {
                    neighborVal := grid[y][x]
                    if neighborVal <= nodeVal + 1 {
                        depth := visited[nodeCoord] + 1
                        if neighborCoord == targetPoint {
                            return depth
                        }
                        Q = append(Q, neighborCoord)
                        visited[neighborCoord] = depth
                    }
                }
            }
        }

        return -1
    }

    shortestPath := -1
    for _,SP := range startPoints {
        res := getShortestPath(SP)
        if res != -1 && (shortestPath == -1 || res < shortestPath) {
            shortestPath = res
        }
    }
    println(shortestPath)
}

package main

import (
	"bufio"
	"os"
)

func main() {
    input, err := os.Open("test.txt")
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
    shortestDistance := 'z'
    var startPoint [2]int
    outerLoop :
    for y, row := range grid {
        for x, elem := range row {
            if elem < shortestDistance {
                startPoint = [2]int{x, y}
                break outerLoop
            }
        }
    }

    Q := [][2]int{startPoint}
    visited := make(map[[2]int]int)
    for len(Q) > 0 {
        var node [2]int
        node, Q = Q[0], Q[1:]
        m, n := node[0], node[1]
        neighbors := [4][2]int{
            [2]int{m  , n-1},
            [2]int{m  , n+1},
            [2]int{m-1, n  },
            [2]int{m+1, n  },
        }

        for _,neighbor := range neighbors {
            x, y := neighbor[0], neighbor[1]
            if x >= 0 && x < xLen && y >= 0 && y < yLen && neighbor != startPoint && visited[neighbor] == 0 {
                comparison := grid[y][x]
                canEnd := comparison == 'E'
                if canEnd {
                    comparison = 'z'
                }
                if node == startPoint || comparison <= grid[n][m] + 1 {
                    if canEnd {
                        println("Finished with distance", visited[node] + 1)
                        os.Exit(0)
                    }
                    Q = append(Q, neighbor)
                    visited[neighbor] = visited[node] + 1
                }
            }
        }
    }

    os.Exit(1)
}

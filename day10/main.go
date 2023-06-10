package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

func main() {
    file, err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open file")
    }

    var i, j, cycle int
    var graph [][]string
    scanner := bufio.NewScanner(file)
    X := 1
    runCycle := func() {
        if i == 0 {
            graph = append(graph, make([]string, 40))
        }
        if cycle%40 == X || cycle%40 == X-1 || cycle%40 == X+1 {
            graph[j][i] = "#"
        } else {
            graph[j][i] = "."
        }
        cycle += 1
        i += 1
        if i == 40 {
            i = 0
            j += 1
        }
    }

    for scanner.Scan() {
        line := scanner.Text()
        if line[:4] == "noop" {
            runCycle()
            continue
        }

        n, err := strconv.Atoi(line[5:])
        if err != nil {
            panic("Couldn't parse int")
        }

        runCycle()
        runCycle()
        X += n
    }

    for _, row := range graph {
        for _, v := range row {
            fmt.Print(v)
        }
        fmt.Println()
    }
}

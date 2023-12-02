package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

func runSwaps(max [4]int, i int) [4]int {
    if max[i] > max[i-1] {
        t := max[i-1]
        max[i-1] = max[i]
        max[i] = t
        if i > 1 {
            return runSwaps(max, i-1)
        }
    }
    return max
}

func main() {
    file, err := os.Open("input.txt")
    if err != nil {
        panic(err)
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)
    var cur int
    max := [4]int{}
    for scanner.Scan() {
        line := scanner.Text()
        if line == "" {
            max[3] = cur
            max = runSwaps(max, 3)
            cur = 0
        } else {
            num, err := strconv.Atoi(line)
            if err != nil {
                panic(err)
            }
            cur += num
        }
    }

    max[3] = cur
    max = runSwaps(max, 3)
    var sum int
    for _,v := range max[:3] {
        sum += v
    }

    fmt.Printf("Max is %d\n", sum)
}

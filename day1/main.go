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
        panic(err)
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)
    var cur, max int
    for scanner.Scan() {
        line := scanner.Text()
        if line == "" {
            if cur > max {
                max = cur
            }
            cur = 0
        } else {
            num, err := strconv.Atoi(line)
            if err != nil {
                panic(err)
            }
            cur += num
        }
    }

    if cur > max {
        max = cur
    }

    fmt.Printf("Max is %d\n", max)
}

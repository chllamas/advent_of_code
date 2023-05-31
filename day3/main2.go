package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func calculateValue(b byte) int {
    if b >= 'a' && b <= 'z' {
        return int(b-'a') + 1
    } else if b >= 'A' && b <= 'Z' {
        return int(b-'A') + 27
    } else {
        panic("Unexpected byte")
    }
}

func main() {
    var acc int

    file, err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open file")
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)
    var lines []string
    for scanner.Scan() {
        lines = append(lines, scanner.Text())
        if len(lines) == 3 {
            for _, b := range []byte(lines[0]) {
                if strings.IndexByte(lines[1], b) != -1 && strings.IndexByte(lines[2], b) != -1 {
                    acc += calculateValue(b)
                    break
                }
            }
            lines = nil
        }
    }

    fmt.Printf("Output is %d\n", acc)
}

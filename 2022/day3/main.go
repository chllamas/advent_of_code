package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
    var acc int

    file, err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open file")
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        line := scanner.Text()
        half := len(line) / 2
        compartment1 := line[:half]
        compartment2 := line[half:]
        for _, b := range []byte(compartment2) {
            found := strings.IndexByte(compartment1, b) != -1
            if found {
                if b >= 'a' && b <= 'z' {
                    acc += int(b-'a') + 1
                } else if b >= 'A' && b <= 'Z' {
                    acc += int(b-'A') + 27
                } else {
                    panic("Unexpected byte")
                }
                break
            }
        }
    }

    fmt.Printf("Output is %d\n", acc)
}

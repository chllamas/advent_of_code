package main

import (
    "os"
    "bufio"
    "fmt"
)

func validSubstring(s string) bool {
    charSet := make(map[rune]bool)

    for _,c := range s {
        if charSet[c] {
            return false
        }
        charSet[c] = true
    }

    return true
}

func main() {
    file, err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open file")
    }

    scanner := bufio.NewScanner(file)
    scanner.Scan()
    text := scanner.Text()
    h := 0
    marker := 4
    for !validSubstring(text[h:marker]) {
        marker += 1
        h += 1
    }

    fmt.Printf("Marker after %d\n", marker)
}

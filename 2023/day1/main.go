package main

import (
	"bufio"
	"os"
	"strconv"
	"unicode"
)

func main() {
    file, err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open input file")
    }
    var result int
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        var num_s []rune
        n := len(scanner.Text())
        for i := 0; i < n; i++ {
            t := rune(scanner.Text()[i])
            if unicode.IsDigit(t) {
                num_s = []rune{t}
                break
            }
        }
        for i := n-1; i >= 0; i-- {
            t := rune(scanner.Text()[i])
            if unicode.IsDigit(t) {
                num_s = append(num_s, t)
                break
            }
        }
        num, err := strconv.Atoi(string(num_s))
        if err != nil {
            panic("Couldn't convert number")
        }
        result += num
    }
    println(result)
}

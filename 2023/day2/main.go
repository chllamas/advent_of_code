package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
    file, err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open file") 
    }

    var result int
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        max := func(n, m int) int {
            if n > m {
                return n
            }
            return m
        }
        minimums := map[string]int{
            "red": 0,
            "green": 0,
            "blue": 0,
        }
        games := strings.Split(strings.Split(scanner.Text(), ": ")[1], "; ")
        for i := range games {
            game := strings.Split(games[i], ", ")
            for j := range game {
                var name string
                var amt int
                fmt.Sscanf(game[j], "%d %s", &amt, &name)
                minimums[name] = max(amt, minimums[name])
            }
        }
        result += minimums["red"] * minimums["green"] * minimums["blue"]
    }
    println("Resulted sum:", result)
}

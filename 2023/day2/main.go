package main

import (
	"bufio"
	"os"
	"strings"
)

func main() {
    file, err := os.Open("test.txt")
    if err != nil {
        panic("Couldn't open file") 
    }

    game_id := 1
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        games := strings.SplitAfter(strings.SplitAfter(scanner.Text(), ": ")[1], "; ")
        for i := range games {
            println(games[i])
        }
        game_id += 1
    }
}

package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

var load = map[string]int{
    "red": 12,
    "green": 13,
    "blue": 14,
}

func main() {
    file, err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open file") 
    }

    var result int
    game_id := 1
    scanner := bufio.NewScanner(file)
    main_loop :
    for scanner.Scan() {
        games := strings.Split(strings.Split(scanner.Text(), ": ")[1], "; ")
        result += game_id
        for i := range games {
            game := strings.Split(games[i], ", ")
            for j := range game {
                var name string
                var amt int
                fmt.Sscanf(game[j], "%d %s", &amt, &name)
                if amt > load[name] {
                    result -= game_id
                    game_id += 1
                    continue main_loop
                }
            }
        }
        game_id += 1
    }
    println("Resulted sum:", result)
}

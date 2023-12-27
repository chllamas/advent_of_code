package main

import (
	"bufio"
	"os"
	"sort"
	"strconv"
	"strings"
)

const expectedTestSolution uint64 = 6440
var cardValues = map[byte]uint8{
    'A': 14,
    'K': 13,
    'Q': 12,
    'J': 11,
    'T': 10,
    '9': 9,
    '8': 8,
    '7': 7,
    '6': 6,
    '5': 5,
    '4': 4,
    '3': 3,
    '2': 2,
}
var cardTypeIndexes = map[string]int {
    "11111": 0,
    "2111": 1,
    "221": 2,
    "311": 3,
    "32": 4,
    "41": 5,
    "5": 6,
}
type Deck struct {
    layout string
    bid    uint64
}

func determineDeckType(s string) string {
    var result string
    cards := make(map[byte]int)
    for i := 0; i < 5; i++ {
        cards[s[i]] += 1
    }

    var values []int
    for _,v := range cards {
        values = append(values, v)
    }
    sort.Slice(values, func(i, j int) bool {
        return values[i] > values[j]
    })

    for _, num := range values {
        result += strconv.Itoa(num)
    }

    return result
}

func solve(scanner *bufio.Scanner) uint64 {
    var result uint64
    cardsBin := make([][]Deck, 7)
    for scanner.Scan() {
        line := strings.Split(scanner.Text(), " ")
        deck := line[0]
        bid, err := strconv.ParseUint(line[1], 10, 16)
        if err != nil {
            panic("Couldn't parse an integer")
        }

        // this long ass statement just places the decks into their ranked type
        cardsBin[cardTypeIndexes[determineDeckType(deck)]] = append(cardsBin[cardTypeIndexes[determineDeckType(deck)]], Deck{ layout: deck, bid: bid })
    }

    var currentRank uint64 = 1
    for i := 0; i < 7; i++ {
        set := cardsBin[i]
        sort.Slice(set, func(a, b int) bool {
            for m := 0; m < 5; m++ {
                if cardValues[set[a].layout[m]] != cardValues[set[b].layout[m]] {
                    return cardValues[set[a].layout[m]] < cardValues[set[b].layout[m]]
                }
            }
            return true
        })
        for _, d := range set {
            result += currentRank * d.bid
            currentRank += 1
        }
    }
    return result
}

func main() {
    testFile, err := os.Open("test.txt")
    if err != nil {
        panic("Couldn't open test file")
    }

    if solve(bufio.NewScanner(testFile)) != expectedTestSolution {
        println("Incorrect test solution.  Ending execution.")
        os.Exit(0)
    }

    file, err := os.Open("input.txt")
    if err != nil {
        panic("Test passed, but couldn't open main input file!")
    }

    println("Test passed!\nMain Solution:", solve(bufio.NewScanner(file)))
}

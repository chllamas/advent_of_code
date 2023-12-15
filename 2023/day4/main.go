package main

import (
    "os"
    "bufio"
    "regexp"
    "strings"
)

const pattern = `Card\s+(\d+): ([\d\s]+) \| ([\d\s]+)`
var regex = regexp.MustCompile(pattern)

func main() {
    file, err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open file")
    }

    var cardsValue, currentCard, numCards int
    copiesOfCards := make(map[int]int)
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        var cardValue, matchesMade int
        winningNumbers := make(map[string]bool)
        matches := regex.FindStringSubmatch(scanner.Text())
        if len(matches) != 4 {
            panic("Unexpected line of input")
        }

        winNumStrArr := strings.Fields(matches[2])
        ourNumStrArr := strings.Fields(matches[3])

        for i := range winNumStrArr {
            winningNumbers[winNumStrArr[i]] = true
        }

        for i := range ourNumStrArr {
            if winningNumbers[ourNumStrArr[i]] {
                matchesMade += 1
                if cardValue == 0 {
                    cardValue = 1
                } else {
                    cardValue *= 2
                }
            }
        }

        for i := 1; i < matchesMade + 1; i++ {
            copiesOfCards[currentCard + i] += 1 + copiesOfCards[currentCard]
        }

        numCards += 1 + copiesOfCards[currentCard]
        cardsValue += cardValue
        currentCard += 1
    }
    println("Cards' value:", cardsValue)
    println("Total cards:", numCards)
}

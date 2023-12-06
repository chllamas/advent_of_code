package main

import (
	"bufio"
	"os"
	"strconv"
	"unicode"
)

type num_word struct {
    word string
    idx  int
}

var all_words = []num_word{
    num_word{"one", 0},
    num_word{"two", 0},
    num_word{"three", 0},
    num_word{"four", 0},
    num_word{"five", 0},
    num_word{"six", 0},
    num_word{"seven", 0},
    num_word{"eight", 0},
    num_word{"nine", 0},
}

func traverseString(s string, i, b int) rune {
    t := rune(s[i])
    if unicode.IsDigit(t) {
        return t
    } else {
        // traverse our words and see if one of them passes
    }
    return traverseString(s, i+b, b)
}

func main() {
    file, err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open input file")
    }
    var result int
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        text := scanner.Text()
        num_s := string([]rune{
            traverseString(text, 0, 1),
            traverseString(text, len(text)-1, -1),
        })
        num, err := strconv.Atoi(num_s)
        if err != nil {
            panic("Couldn't convert number")
        }
        result += num
    }
    println(result)
}

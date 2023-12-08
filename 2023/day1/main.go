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
    id   int
}

var all_words = []num_word{
    num_word{"one", 0, 1},
    num_word{"two", 0, 2},
    num_word{"three", 0, 3},
    num_word{"four", 0, 4},
    num_word{"five", 0, 5},
    num_word{"six", 0, 6},
    num_word{"seven", 0, 7},
    num_word{"eight", 0, 8},
    num_word{"nine", 0, 9},
}

func reset_all_words() {
    for w := range all_words {
        all_words[w].idx = 0
    }
}

func reset_all_words_rev() {
    for w := range all_words {
        all_words[w].idx = len(all_words[w].word) - 1
    }
}

func findStringDigit(c byte, b int) (int, bool) {
    for w := range all_words {
        if all_words[w].word[all_words[w].idx] == c {
            new_idx := all_words[w].idx + b
            if new_idx < 0 || new_idx >= len(all_words[w].word) {
                return all_words[w].id, true
            }
            all_words[w].idx = new_idx
        } else {
            if b == 1 {
                all_words[w].idx = 0
            } else {
                all_words[w].idx = len(all_words[w].word) - 1
            }
            if all_words[w].word[all_words[w].idx] == c {
                all_words[w].idx = all_words[w].idx + b
            }
        }
    }
    return 0, false
}

func traverseString(s string, i, b int) int {
    if t := rune(s[i]); unicode.IsDigit(t) {
        n, err := strconv.Atoi(string(t))
        if err != nil {
            panic("Error converting digit string to integer")
        }
        return n
    }
    if digit, ok := findStringDigit(s[i], b); ok {
        return digit
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
        digit_one := traverseString(text, 0, 1) * 10
        reset_all_words_rev()
        digit_two := traverseString(text, len(text) - 1, -1)
        reset_all_words()
        result += digit_one + digit_two
    }
    println("Calculated result:", result)
}

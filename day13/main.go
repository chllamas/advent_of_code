package main

import (
	"bufio"
	"encoding/json"
	"os"
)

func compare(left, right interface{}) float64 {
    switch l := left.(type) {
    case float64:
        switch r := right.(type) {
        case float64:
            return l - r
        default:
            return compare([]interface{}{left}, right)
        }
    case []interface{}:
        switch r := right.(type) {
        case float64:
            return compare(left, []interface{}{right})
        case []interface{}:
            minLen := len(l)
            if len(r) < minLen {
                minLen = len(r)
            }
            for i := 0; i < minLen; i++ {
                result := compare(l[i], r[i])
                if result != 0 {
                    return result
                }
            }
            if len(l) < len(r) {
                return -1
            } else if len(l) > len(r) {
                return 1
            } else {
                return 0
            }
        }
    }
    return -1
}

func main() {
    file, err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open file")
    }
    defer file.Close()

    var sum int
    var buffer [2]string
    scanner := bufio.NewScanner(file)
    index := 1

    for scanner.Scan() {
        for i,_ := range buffer {
            buffer[i] = scanner.Text()
            scanner.Scan()
        }

        var left, right interface{}
        errL, errR := json.Unmarshal([]byte(buffer[0]), &left), json.Unmarshal([]byte(buffer[1]), &right)
        if errL != nil || errR != nil {
            panic("Couldn't parse string")
        }

        if compare(left, right) <= 0 {
            sum += index
        }

        index++
    }

    println(sum)
}

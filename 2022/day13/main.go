package main

import (
	"bufio"
	"encoding/json"
	"os"
    "sort"
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

    packets := make([]interface{}, 2)
    scanner := bufio.NewScanner(file)

    packets[0] = 2
    packets[1] = 6

    for scanner.Scan() {
        var list interface{}
        err := json.Unmarshal(scanner.Bytes(), &list)
        if err != nil {
            panic("Couldn't parse []byte")
        }

        index := sort.Search(len(packets), func(i int) bool {
            return compare(list, packets[i]) < 0
        })

        packets = append(packets, 0)
        copy(packets[index+1:], packets[index:])
        packets[index] = list
    }

    for i,v := range packets {
        if v == 2 || v == 6 {
            println(i+1)
        }
    }
}

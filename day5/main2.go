package main

import (
	"bufio"
	"errors"
	"fmt"
	"os"
)

type Stack struct {
    contents []byte 
}

func (s *Stack) pop() (byte, error) {
    if len(s.contents) == 0 {
        return 0, errors.New("bad")
    }
    ret := s.contents[0]
    s.contents = s.contents[1:]
    return ret, nil
}   

func (s *Stack) push(b byte) {
    s.contents = append([]byte{b}, s.contents...)
}

func printTopVals(stacks *[9]Stack) {
    for _, stack := range *stacks {
        if t, err := stack.pop(); err == nil {
            fmt.Printf("%s", string(t))
        }
    }
    fmt.Println()
}

func main() {
    /*
    [B]                     [N]     [H]
    [V]         [P] [T]     [V]     [P]
    [W]     [C] [T] [S]     [H]     [N]
    [T]     [J] [Z] [M] [N] [F]     [L]
    [Q]     [W] [N] [J] [T] [Q] [R] [B]
    [N] [B] [Q] [R] [V] [F] [D] [F] [M]
    [H] [W] [S] [J] [P] [W] [L] [P] [S]
    [D] [D] [T] [F] [G] [B] [B] [H] [Z]
    1   2   3   4   5   6   7   8   9 
    */
    stacks := [9]Stack{
        {contents: []byte("BVWTQNHD")},
        {contents: []byte("BWD")},
        {contents: []byte("CJWQST")},
        {contents: []byte("PTZNRJF")},
        {contents: []byte("TSMJVPG")},
        {contents: []byte("NTFWB")},
        {contents: []byte("NVHFQDLB")},
        {contents: []byte("RFPH")},
        {contents: []byte("HPNLBMSZ")},
    }

    file, err := os.Open("input.txt")
    if err != nil {
        panic("couldn't open file")
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        line := scanner.Text()
        var n, from, to int

        _, err := fmt.Sscanf(line, "move %d from %d to %d", &n, &from, &to)
        if err != nil {
            panic(fmt.Sprintf("Couldn't parse line: %s", line))
        }

        var popped []byte
        for i := 0; i < n; i++ {
            t, err := stacks[from-1].pop()
            if err == nil {
                popped = append([]byte{t}, popped...)
            }
        }
        for _,t := range popped {
            stacks[to-1].push(t)
        }
    }

    printTopVals(&stacks)
}

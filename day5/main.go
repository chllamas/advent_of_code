package main 

import (
    "os"
    "strconv"
    "bufio"
)

type Stack struct {
    contents []byte 
}

func (s *Stack) pop() byte {
    if len(s.contents) == 0 {
        panic("Stack underflow!")
    }
    ret := s.contents[len(s.contents) - 1]
    s.contents = s.contents[:len(s.contents) - 1]
    return ret
}   

func (s *Stack) push(b byte) {
    s.contents = append(s.contents, b)
}

func main() {
    file, err := os.Open("input.txt")
    if err != nil {
        panic("couldn't open file")
    }

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
  
    // switch to ()
    stacks := [9]Stack{
        {contents: []byte{"BVWTQNHD"}},
        {contents: []byte{"BWD"}},
        {contents: []byte{"CJWQST"}},
        {contents: []byte{"PTZNRJF"}},
        {contents: []byte{"TSNMJVPG"}},
        {contents: []byte{"NTFWB"}},
        {contents: []byte("NVHFQDLB")},
        {contents: []byte{"RFPH"}},
        {contents: []byte{"HPNLBMSZ"}},
    }
}

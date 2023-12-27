package main

import (
	"bufio"
    "regexp"
	"os"
)

const test1Solution uint = 2
const test2Solution uint = 6

func solve(scanner *bufio.Scanner) uint {
    scanner.Scan()
    var instructionSet []uint8
    for i := 0; i < len(scanner.Text()); i++ {
        var instruction uint8
        if scanner.Text()[i] == 'R' {
            instruction = 1
        }
        instructionSet = append(instructionSet, instruction)
    }
    scanner.Scan()

    nodeTree := make(map[string][2]string)
    for scanner.Scan() {
        re := regexp.MustCompile(`(\w+)\s*=\s*\((\w+),\s*(\w+)\)`)
        matches := re.FindStringSubmatch(scanner.Text())
        nodeTree[matches[1]] = [2]string{matches[2], matches[3]}
    }

    var stepsTaken uint
    currentNode := "AAA"
    for currentNode != "ZZZ" {
        for _,movement := range instructionSet {
            node := nodeTree[currentNode]
            currentNode = node[movement]
            stepsTaken += 1
        }
    }
    return stepsTaken
}

func main() {
    test1File, err := os.Open("test1.txt")
    if err != nil {
        panic("Couldn't open 'test1.txt'")
    }
    defer test1File.Close()
    test2File, err := os.Open("test2.txt")
    if err != nil {
        panic("Couldn't open 'test2.txt'")
    }
    defer test2File.Close()
    mainFile, err := os.Open("input.txt")
    if err != nil {
        panic("Couldn't open 'input.txt'")
    }
    defer mainFile.Close()

    if solve(bufio.NewScanner(test1File)) != test1Solution || solve(bufio.NewScanner(test2File)) != test2Solution {
        println("Tests failed! Ending execution.")
        os.Exit(0)
    }
    println("Tests passed. Executing final solution...")
    println("Final Solution:", solve(bufio.NewScanner(mainFile)))
}

package main

type Operation struct {
    o string 
    n int
}

type Monkey struct {
    items   []uint64
    op      string
    op_n    uint64
    test    uint64
    yep     int 
    nop     int
}

/* Returns (monkeyIdx, itemWorry) tuple */
func (m *Monkey) runTurn() (int, uint64) {
    var target int
    var ret uint64
    ret, m.items = m.items[0], m.items[1:]
    o := m.op
    n := m.op_n
    if o == "*" {
        ret *= n
    } else if o == "+" {
        ret += n
    } else if o == "^" {
        ret *= ret
    } else {
        panic("Unknown operation")
    }

    if ret % m.test == 0 {
        target = m.yep
    } else {
        target = m.nop
    }

    return target, ret
}

func main() {
    monkeyActivity := [8]uint64{}
    monkeys := [8]Monkey{
        Monkey{
            items: []uint64{83, 97, 95, 67},
            op: "*",
            op_n: 19,
            test: 17,
            yep: 2,
            nop: 7,
        },
        Monkey{
            items: []uint64{71, 70, 79, 88, 56, 70},
            op: "+",
            op_n: 2,
            test: 19,
            yep: 7,
            nop: 0,
        },
        Monkey{
            items: []uint64{98, 51, 51, 63, 80, 85, 84, 95},
            op: "+",
            op_n: 7,
            test: 7,
            yep: 4,
            nop: 3,
        },
        Monkey{
            items: []uint64{77, 90, 82, 80, 79},
            op: "+",
            op_n: 1,
            test: 11,
            yep: 6,
            nop: 4,
        },
        Monkey{
            items: []uint64{68},
            op: "*",
            op_n: 5,
            test: 13,
            yep: 6,
            nop: 5,
        },
        Monkey{
            items: []uint64{60, 94},
            op: "+",
            op_n: 5,
            test: 3,
            yep: 1,
            nop: 0,
        },
        Monkey{
            items: []uint64{81, 51, 85},
            op: "^",
            op_n: 0,
            test: 5,
            yep: 5,
            nop: 1,
        },
        Monkey{
            items: []uint64{98, 81, 63, 65, 84, 71, 84},
            op: "+",
            op_n: 3,
            test: 2,
            yep: 2,
            nop: 3,
        },
    }

    for round := 0; round < 10000; round++ {
        for i := 0; i < len(monkeys); i++ {
            for len(monkeys[i].items) > 0 {
                target, val := monkeys[i].runTurn()
                monkeys[target].items = append(monkeys[target].items, val)
                monkeyActivity[i] += 1
            }
        }
    }

    largest := monkeyActivity[0]
    secondLargest := monkeyActivity[1]

    if secondLargest > largest {
        largest, secondLargest = secondLargest, largest
    }

    for i := 2; i < len(monkeyActivity); i++ {
        if monkeyActivity[i] > largest {
            secondLargest = largest
            largest = monkeyActivity[i]
        } else if monkeyActivity[i] > secondLargest {
            secondLargest = monkeyActivity[i]
        }
    }

    println(largest * secondLargest)
}

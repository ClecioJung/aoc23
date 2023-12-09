package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"sort"
	"strconv"
	"strings"
)

type Hand struct {
	cards string
	bid   int
}

const (
	FiveOfKind int = iota
	FourOfKind
	FullHouse
	ThreeOfKind
	TwoPair
	OnePair
	HighCard
)

func parseInput(content string) []Hand {
	lines := strings.Split(string(content), "\n")
	var hands []Hand
	for _, line := range lines {
		values := strings.Split(line, " ")
		bid, _ := strconv.Atoi(values[1])
		hand := Hand{values[0], bid}
		hands = append(hands, hand)
	}
	return hands
}

type CardAmount struct {
	card   rune
	amount int
}

func findCard(setOfCards []CardAmount, card rune) int {
	for i, set := range setOfCards {
		if set.card == card {
			return i
		}
	}
	return -1
}

func getSetOfCards(cards string) []CardAmount {
	cardsAmount := make(map[rune]int)
	for _, card := range cards {
		cardsAmount[card]++
	}
	var setOfCards []CardAmount
	for card, amount := range cardsAmount {
		setOfCards = append(setOfCards, CardAmount{card, amount})
	}
	sort.Slice(setOfCards, func(i, j int) bool {
		return setOfCards[i].amount > setOfCards[j].amount
	})
	return setOfCards
}

func getHandType(cards string, jokerRule bool) int {
	setOfCards := getSetOfCards(cards)
	amountOfSets := len(setOfCards)
	maxSet := setOfCards[0].amount
	if jokerRule {
		jokerIndex := findCard(setOfCards, 'J')
		if jokerIndex > 0 {
			maxSet += setOfCards[jokerIndex].amount
			amountOfSets--
		} else if jokerIndex == 0 && amountOfSets > 1 {
			maxSet += setOfCards[1].amount
			amountOfSets--
		}
	}
	switch maxSet {
	case 5:
		return FiveOfKind
	case 4:
		return FourOfKind
	case 3:
		if amountOfSets == 2 {
			return FullHouse
		}
		return ThreeOfKind
	case 2:
		if amountOfSets == 3 {
			return TwoPair
		}
		return OnePair
	}
	return HighCard
}

func cardOrder(card byte, jokerRule bool) int {
	labels := []byte{'A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'}
	if jokerRule && card == 'J' {
		return len(labels)
	}
	for i, label := range labels {
		if card == label {
			return i
		}
	}
	return len(labels) // Unreachable
}

func handIsGreater(first, second string, jokerRule bool) bool {
	for i := 0; i < len(first); i++ {
		firstOrder := cardOrder(first[i], jokerRule)
		secondOrder := cardOrder(second[i], jokerRule)
		if firstOrder != secondOrder {
			return firstOrder > secondOrder
		}
	}
	return false
}

func totalWinnings(hands []Hand) int {
	winnings := 0
	for i, hand := range hands {
		winnings += (i + 1) * hand.bid
	}
	return winnings
}

func sortHands(hands []Hand, jokerRule bool) {
	sort.Slice(hands, func(i, j int) bool {
		iType := getHandType(hands[i].cards, jokerRule)
		jType := getHandType(hands[j].cards, jokerRule)
		if iType != jType {
			return iType > jType
		}
		return handIsGreater(hands[i].cards, hands[j].cards, jokerRule)
	})
}

func part01(filepath string) (int, error) {
	content, err := ioutil.ReadFile(filepath)
	if err != nil {
		return 0, err
	}
	hands := parseInput(string(content))
	sortHands(hands, false)
	return totalWinnings(hands), nil
}

func part02(filepath string) (int, error) {
	content, err := ioutil.ReadFile(filepath)
	if err != nil {
		return 0, err
	}
	hands := parseInput(string(content))
	sortHands(hands, true)
	return totalWinnings(hands), nil
}

func main() {
	result, err := part01("input.txt")
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error reading file:", err)
		return
	}
	fmt.Println("part01:", result)
	result, err = part02("input.txt")
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error reading file:", err)
		return
	}
	fmt.Println("part02:", result)
}

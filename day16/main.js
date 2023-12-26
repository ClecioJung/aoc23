#!/usr/bin/node

const assert = require('assert');
const fs = require('fs');

const EMPTY = 0;
const BLOCK = 1;
const UP    = 2;
const DOWN  = 4;
const LEFT  = 8;
const RIGHT = 16;

function createEmptyBoard(rows, columns) {
    let board = [];
    for (let i = 0; i < rows; i++) {
        const row = [];
        for (let j = 0; j < columns; j++) {
            row.push(EMPTY);
        }
        board.push(row);
    }
    return board;
}

function move(row, col, direction) {
    switch (direction) {
        case UP:    return [--row, col];
        case DOWN:  return [++row, col];
        case LEFT:  return [row, --col];
        case RIGHT: return [row, ++col];
    }
    return [row, col]; // Unreachable
}

function processLightBeams(lines, initialRow=0, initialCol=0, initialDirection=RIGHT) {
    let board = createEmptyBoard(lines.length, lines[0].length);
    let positionsStack = [];
    positionsStack.push([initialRow, initialCol, initialDirection]);
    while (positionsStack.length > 0) {
        let [row, col, direction] = positionsStack.pop();
        while ((0 <= row && row < lines.length) && (0 <= col && col < lines[0].length) && (board[row][col] & direction) == 0) {
            switch (lines[row][col]) {
                case '/':
                    board[row][col] = BLOCK;
                    switch (direction) {
                        case UP:
                            direction = RIGHT;
                            col++;
                            break;
                        case DOWN:
                            direction = LEFT;
                            col--;
                            break;
                        case LEFT:
                            direction = DOWN;
                            row++;
                            break;
                        case RIGHT:
                            direction = UP;
                            row--;
                            break;
                    }
                    break;
                case '\\':
                    board[row][col] = BLOCK;
                    switch (direction) {
                        case UP:
                            direction = LEFT;
                            col--;
                            break;
                        case DOWN:
                            direction = RIGHT;
                            col++;
                            break;
                        case LEFT:
                            direction = UP;
                            row--;
                            break;
                        case RIGHT:
                            direction = DOWN;
                            row++;
                            break;
                    }
                    break;
                case '-':
                    board[row][col] = BLOCK;
                    if (direction == UP || direction == DOWN) {
                        positionsStack.push([row, (col+1), RIGHT]);
                        direction = LEFT;
                        col--;
                    } else {
                        [row, col] = move(row, col, direction);
                    }
                    break;
                case '|':
                    board[row][col] = BLOCK;
                    if (direction == LEFT || direction == RIGHT) {
                        positionsStack.push([(row+1), col, DOWN]);
                        direction = UP;
                        row--;
                    } else {
                        [row, col] = move(row, col, direction);
                    }
                    break;
                case '.':
                    board[row][col] |= direction;
                    [row, col] = move(row, col, direction);
                    break;
            }
        }
    }
    return board;
}

function countEnergizedTiles(board) {
    let energizedCount = 0;
    for (let row of board) {
        for (let tile of row) {
            if (tile != EMPTY) {
                energizedCount++;
            }
        }
    }
    return energizedCount;
}

function part01(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    const lines = content.split('\n');
    const board = processLightBeams(lines);
    return countEnergizedTiles(board);
}

function part02(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    const lines = content.split('\n');
    let maxEnergizedTiles = 0;
    for (let row = 0; row < lines.length; row++) {
        let board = processLightBeams(lines, row, 0, RIGHT);
        let energizedTiles = countEnergizedTiles(board);
        maxEnergizedTiles = Math.max(energizedTiles, maxEnergizedTiles);
        board = processLightBeams(lines, row, (lines[0].length-1), LEFT);
        energizedTiles = countEnergizedTiles(board);
        maxEnergizedTiles = Math.max(energizedTiles, maxEnergizedTiles);
    }
    for (let col = 0; col < lines[0].length; col++) {
        let board = processLightBeams(lines, 0, col, DOWN);
        let energizedTiles = countEnergizedTiles(board);
        maxEnergizedTiles = Math.max(energizedTiles, maxEnergizedTiles);
        board = processLightBeams(lines, (lines.length-1), col, UP);
        energizedTiles = countEnergizedTiles(board);
        maxEnergizedTiles = Math.max(energizedTiles, maxEnergizedTiles);
    }
    return maxEnergizedTiles;
}

function main() {
    const part01output = part01('input.txt');
    const part02output = part02('input.txt');
    assert.strictEqual(part01('sample.txt'), 46);
    assert.strictEqual(part01output, 8116);
    assert.strictEqual(part02('sample.txt'), 51);
    assert.strictEqual(part02output, 8383);
    console.log(`Part 01: ${part01output}`);
    console.log(`Part 02: ${part02output}`);
}

main();

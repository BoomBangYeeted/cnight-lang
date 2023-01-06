import std/strutils

type
    tkname = enum
        def, id, str, num, kw, uk, op
    token = object
        label: tkName
        value: string

method reset(tk: var token) {.base.} =
    tk.label = def
    tk.value = ""

method toStr(tk: token): string {.base.} =
    var res: string
    for ch in tk.value:
        res.add(ch)
    return res
    
proc newTk(): token =
    var res: token
    return res

proc ignore*[T](value: T) =
    discard

proc validIndex*[arrsize, arrtype](arr: array[arrsize, arrtype], index: int): bool = 
    try:
        ignore[arrtype](arr[index])
        return true
    except IndexDefect:
        return false

const keywords = ["let", "const", "var", "if", "else"]
const decKeywords: array[3, string] = ["let", "const", "var"]
const operators = ["=", "+", "-", "/", "*", "^", "==", "++", "--"]
const operatorStart = ['=','+','-','/', '*', '^']

let compilationTarget = readFile("./ex/example.txt")

var
    tokens: seq[token]
    currentToken: token
    tkIdx: Natural = 0

currentToken.label = def

echo compilationTarget

for ch in compilationTarget:
    if currentToken.label == def:
        case ch
        of Whitespace:
            continue
        of '\"':
            currentToken.label = str
            continue
        of Digits:
            currentToken.label = num
            currentToken.value = $ch
        of IdentStartChars:
            currentToken.label = id
            currentToken.value = $ch
        of operatorStart:
            currentToken.label = uk
            currentToken.value = $ch
        else:
            continue    
        continue

    case currentToken.label
    of def:
        echo "YOU WERE SUPPOSED TO STOP ALL THE DEFAULTS!!!!"
        break
    of str:
        if ch == '\"':
            echo int tkIdx
            let throwaway = @[currentToken]
            tokens = tokens & throwaway
            currentToken.reset()
            tkIdx += 1
        else:
            currentToken.value.add(ch)
    of id:
        if keywords.contains(currentToken.value): 
            currentToken.label = kw
            echo int tkIdx
            let throwaway = @[currentToken]
            tokens = tokens & throwaway
            currentToken.reset()
            tkIdx += 1

        if Whitespace.contains(ch):
            echo int tkIdx
            let throwaway = @[currentToken]
            tokens = tokens & throwaway
            currentToken.reset()
            tkIdx += 1
        else:
            currentToken.value.add(ch)
    of num:
        if Whitespace.contains(ch):
            echo int tkIdx
            let throwaway = @[currentToken]
            tokens = tokens & throwaway
            currentToken.reset()
            tkIdx += 1 
        else:
            currentToken.value.add(ch)
    of uk:
        if Whitespace.contains(ch) or IdentStartChars.contains(ch):
            if operators.contains(currentToken.value):
                echo int tkIdx
                currentToken.label = op
                let throwaway = @[currentToken]
                tokens = tokens & throwaway
                currentToken.reset()
                tkIdx += 1
        else:
            currentToken.value.add(ch)
    else:
        continue
for cTk in tokens:
    echo cTk
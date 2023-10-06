//
//  Keycodes.swift
//  Clicker
//
//  Created by Dennis Litvinenko on 10/9/20.
//

import Foundation
import AppKit

let keycodes: [String: UInt16] = [
    "" : 0xFF,
    " ": 0x31,
    "1": 0x12,
    "2": 0x13,
    "3": 0x14,
    "4": 0x15,
    "5": 0x17,
    "6": 0x16,
    "7": 0x1A,
    "8": 0x1C,
    "9": 0x19,
    "0": 0x1D,
    "a": 0x00,
    "b": 0x0B,
    "c": 0x08,
    "d": 0x02,
    "e": 0x0E,
    "f": 0x03,
    "g": 0x05,
    "h": 0x04,
    "i": 0x22,
    "j": 0x26,
    "k": 0x28,
    "l": 0x25,
    "m": 0x2E,
    "n": 0x2D,
    "o": 0x1F,
    "p": 0x23,
    "q": 0x0C,
    "r": 0x0F,
    "s": 0x01,
    "t": 0x11,
    "u": 0x20,
    "v": 0x09,
    "w": 0x0D,
    "x": 0x07,
    "y": 0x10,
    "z": 0x06,
    "=" : 0x18,
    "-" : 0x1B,
    ";" : 0x29,
    "'" : 0x27,
    "," : 0x2B,
    "." : 0x2F,
    "/" : 0x2C,
    "\\" : 0x2A,
    "`" : 0x32,
    "[" : 0x21,
    "]" : 0x1E
]

let parallelKeycodes: [String: UInt16] = [
    "!": 0x12,
    "@": 0x13,
    "#": 0x14,
    "$": 0x15,
    "%": 0x17,
    "^": 0x16,
    "&": 0x1A,
    "*": 0x1C,
    "(": 0x19,
    ")": 0x1D,
    "+" : 0x18,
    "_" : 0x1B,
    ":" : 0x29,
    "\"" : 0x27,
    "<" : 0x2B,
    ">" : 0x2F,
    "?" : 0x2C,
    "|" : 0x2A,
    "~" : 0x32,
    "{" : 0x21,
    "}" : 0x1E
]

let keycodeString: [UInt16: String] = [
    0xFF : "",
    49   : " ",
    18   : "1",
    19   : "2",
    20   : "3",
    21   : "4",
    23   : "5",
    22   : "6",
    26   : "7",
    28   : "8",
    25   : "9",
    29   : "0",
    0    : "A",
    11   : "B",
    8    : "B",
    2    : "D",
    14   : "E",
    3    : "F",
    5    : "G",
    4    : "H",
    34   : "I",
    38   : "J",
    40   : "K",
    37   : "L",
    46   : "M",
    45   : "N",
    31   : "O",
    35   : "P",
    12   : "Q",
    15   : "R",
    1    : "S",
    17   : "T",
    32   : "U",
    9    : "V",
    13   : "W",
    7    : "X",
    16   : "Y",
    6    : "Z",
    50   : "`",
    27   : "-",
    24   : "=",
    51   : "⌫",
    33   : "[",
    30   : "]",
    42   : "\\",
    41   : ";",
    39   : "'",
    43   : ",",
    47   : ".",
    44   : "/"
]

struct Keycode {
    
    // Layout-independent Keys
    // eg.These key codes are always the same key on all layouts.
    let returnKey                 : UInt16 = 0x24
//    let enter                     : UInt16 = 0x4C
    let tab                       : UInt16 = 0x30
    let space                     : UInt16 = 0x31
    let delete                    : UInt16 = 0x33
    let escape                    : UInt16 = 0x35
    let command                   : UInt16 = 0x37
    let shift                     : UInt16 = 0x38
    let capsLock                  : UInt16 = 0x39
    let option                    : UInt16 = 0x3A
    let control                   : UInt16 = 0x3B
    let rightShift                : UInt16 = 0x3C
    let rightOption               : UInt16 = 0x3D
    let rightControl              : UInt16 = 0x3E
    let leftArrow                 : UInt16 = 0x7B
    let rightArrow                : UInt16 = 0x7C
    let downArrow                 : UInt16 = 0x7D
    let upArrow                   : UInt16 = 0x7E
    let volumeUp                  : UInt16 = 0x48
    let volumeDown                : UInt16 = 0x49
    let mute                      : UInt16 = 0x4A
    let help                      : UInt16 = 0x72
    let home                      : UInt16 = 0x73
    let pageUp                    : UInt16 = 0x74
    let forwardDelete             : UInt16 = 0x75
    let end                       : UInt16 = 0x77
    let pageDown                  : UInt16 = 0x79
    let function                  : UInt16 = 0x3F
    let f1                        : UInt16 = 0x7A
    let f2                        : UInt16 = 0x78
    let f4                        : UInt16 = 0x76
    let f5                        : UInt16 = 0x60
    let f6                        : UInt16 = 0x61
    let f7                        : UInt16 = 0x62
    let f3                        : UInt16 = 0x63
    let f8                        : UInt16 = 0x64
    let f9                        : UInt16 = 0x65
    let f10                       : UInt16 = 0x6D
    let f11                       : UInt16 = 0x67
    let f12                       : UInt16 = 0x6F
    let f13                       : UInt16 = 0x69
    let f14                       : UInt16 = 0x6B
    let f15                       : UInt16 = 0x71
    let f16                       : UInt16 = 0x6A
    let f17                       : UInt16 = 0x40
    let f18                       : UInt16 = 0x4F
    let f19                       : UInt16 = 0x50
    let f20                       : UInt16 = 0x5A
    
    // US-ANSI Keyboard Positions
    // eg. These key codes are for the physical key (in any keyboard layout)
    // at the location of the named key in the US-ANSI layout.
    let a                         : UInt16 = 0x00
    let b                         : UInt16 = 0x0B
    let c                         : UInt16 = 0x08
    let d                         : UInt16 = 0x02
    let e                         : UInt16 = 0x0E
    let f                         : UInt16 = 0x03
    let g                         : UInt16 = 0x05
    let h                         : UInt16 = 0x04
    let i                         : UInt16 = 0x22
    let j                         : UInt16 = 0x26
    let k                         : UInt16 = 0x28
    let l                         : UInt16 = 0x25
    let m                         : UInt16 = 0x2E
    let n                         : UInt16 = 0x2D
    let o                         : UInt16 = 0x1F
    let p                         : UInt16 = 0x23
    let q                         : UInt16 = 0x0C
    let r                         : UInt16 = 0x0F
    let s                         : UInt16 = 0x01
    let t                         : UInt16 = 0x11
    let u                         : UInt16 = 0x20
    let v                         : UInt16 = 0x09
    let w                         : UInt16 = 0x0D
    let x                         : UInt16 = 0x07
    let y                         : UInt16 = 0x10
    let z                         : UInt16 = 0x06

    let zero                      : UInt16 = 0x1D
    let one                       : UInt16 = 0x12
    let two                       : UInt16 = 0x13
    let three                     : UInt16 = 0x14
    let four                      : UInt16 = 0x15
    let five                      : UInt16 = 0x17
    let six                       : UInt16 = 0x16
    let seven                     : UInt16 = 0x1A
    let eight                     : UInt16 = 0x1C
    let nine                      : UInt16 = 0x19
    
    let equals                    : UInt16 = 0x18
    let minus                     : UInt16 = 0x1B
    let semicolon                 : UInt16 = 0x29
    let apostrophe                : UInt16 = 0x27
    let comma                     : UInt16 = 0x2B
    let period                    : UInt16 = 0x2F
    let forwardSlash              : UInt16 = 0x2C
    let backslash                 : UInt16 = 0x2A
    let grave                     : UInt16 = 0x32
    let leftBracket               : UInt16 = 0x21
    let rightBracket              : UInt16 = 0x1E
    
    let keypadDecimal             : UInt16 = 0x41
    let keypadMultiply            : UInt16 = 0x43
    let keypadPlus                : UInt16 = 0x45
    let keypadClear               : UInt16 = 0x47
    let keypadDivide              : UInt16 = 0x4B
    let keypadEnter               : UInt16 = 0x4C
    let keypadMinus               : UInt16 = 0x4E
    let keypadEquals              : UInt16 = 0x51
    let keypad0                   : UInt16 = 0x52
    let keypad1                   : UInt16 = 0x53
    let keypad2                   : UInt16 = 0x54
    let keypad3                   : UInt16 = 0x55
    let keypad4                   : UInt16 = 0x56
    let keypad5                   : UInt16 = 0x57
    let keypad6                   : UInt16 = 0x58
    let keypad7                   : UInt16 = 0x59
    let keypad8                   : UInt16 = 0x5B
    let keypad9                   : UInt16 = 0x5C
}

extension String {
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i..<i+1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length)..<length]
    }

    func substring(toIndex: Int) -> String {
        return self[0..<max(0, toIndex+1)]
    }
    
    func char(at: Int) -> String {
        return self[at..<max(0, at+1)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start..<end])
    }
}

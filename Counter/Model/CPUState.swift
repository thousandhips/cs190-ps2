//
//  CPUState.swift
//  Counter
//
//  Created by Brian Hill github.com/brianhill on 2/12/16.
//

// CPUState defines the various CPU registers we need to simulate an HP-35.

// This reference is the most thorough, but at the moment a bunch of the image links are broken:
// http://home.citycable.ch/pierrefleur/Jacques-Laporte/A&R.htm

// This reference is sufficient:
// http://www.hpmuseum.org/techcpu.htm

import Foundation

struct Nibble {
    var value = [Bool](count:4, repeatedValue: false)
}

typealias Pointer = Nibble // Most commonly used to point to which nibble in a register is being processed.

// A register is 14 nibbles (56 bits). Mostly nibbles are used to represent the digits 0-9, but the leftmost one,
// nibble 13, represents the sign of the mantissa, nibbles 12 to 3 inclusive represent 10 digits
// of mantissa, and nibbles 2 to 0 represent the exponent.

struct Register {
    var nibbles = [Nibble](count:14, repeatedValue: Nibble()) // I might regret not just making this 56 bits
}

struct Status {
    var value = [Bool](count:12, repeatedValue: false)
}

// For completeness, we may later need this, but that will depend on whether what we end up doing is closer to
// emulation or simulation:
//
// struct RAMAddress {
//     var nibbles = [Nibble](count:2, repeatedValue: Nibble())
// }

struct CPUState {
    static let sharedInstance = CPUState()
    
    var registers = [Register](count:7, repeatedValue:Register())
    var pointer = Pointer()
    var status = Status()
}

enum RegId: Int {
    case A = 0 // General Purpose (math or scratchpad)
    case B = 1 // General Purpose (math or scratchpad)
    case C = 2 // X Register
    case D = 3 // Y Register
    case E = 4 // Z Register
    case F = 5 // T (top or trigonemtric) Register
    case M = 6 // Scratchpad (like A and B, but no math)
}

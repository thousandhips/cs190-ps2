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

typealias Nibble = UInt8 // This should be UInt4, but the smallest width unsigned integer Swift has is UInt8.

typealias Pointer = UInt8 // Also should be UInt4.

typealias Status = UInt16 // Should be a UInt12 if we wanted exactly as many status bits as the HP-35.

// This is how many nibbles there are in a register:
let RegisterLength = 14

// This is how many of the nibbles are devoted to the exponent:
let ExponentLength = 3

// A register is 14 nibbles (56 bits). Mostly nibbles are used to represent the digits 0-9, but the leftmost one,
// nibble 13, corresponds to the sign of the mantissa, nibbles 12 to 3 inclusive represent 10 digits
// of mantissa, and nibbles 2 to 0 represent the exponent.
struct Register {
    var nibbles = [Nibble](count:RegisterLength, repeatedValue: UInt8(0))
}

struct CPUState {
    static let sharedInstance = CPUState()
    
    var registers = [Register](count:7, repeatedValue:Register())
    var pointer = Pointer(0)
    var status = Status()
    
    init() {
        let registerA: Register = Register(nibbles:[
            Nibble(2), //  0
            Nibble(0), //  1
            Nibble(9), //  2
            Nibble(0), //  3
            Nibble(0), //  4
            Nibble(0), //  5
            Nibble(0), //  6
            Nibble(0), //  7
            Nibble(0), //  8
            Nibble(0), //  9
            Nibble(5), // 10
            Nibble(2), // 11
            Nibble(1), // 12
            Nibble(9)  // 13
            ]
        ) // 91250000000902
        let registerB: Register = Register(nibbles:[
            Nibble(0), //  0
            Nibble(0), //  1
            Nibble(0), //  2
            Nibble(9), //  3
            Nibble(9), //  4
            Nibble(9), //  5
            Nibble(9), //  6
            Nibble(9), //  7
            Nibble(9), //  8
            Nibble(9), //  9
            Nibble(0), // 10
            Nibble(0), // 11
            Nibble(2), // 12
            Nibble(0)  // 13
            ]
        ) // 02009999999000
        registers[RegId.A.rawValue] = registerA
        registers[RegId.B.rawValue] = registerB
    }
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

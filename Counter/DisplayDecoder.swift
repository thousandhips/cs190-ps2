//
//  DisplayDecoder.swift
//  Counter
//
//  Created by Brian Hill github.com/brianhill on 2/12/16.
//

// We are told by Jacques Laporte how the A and B registers determine what is displayed:
//
// http://home.citycable.ch/pierrefleur/Jacques-Laporte/Output%20format.htm
// 
// Some examples are given:
//
//    The machine has to handle the 4 display format cases:
//    1) results as 102  to be displayed as “100.”:
//    (registers on entry in “of13”)
//    A=01000000000002  B=00029999999999  C=01000000000002
//
//    2) results as 10-2 to be displayed as is “.01”
//
//    A=00100000000902  B=20099999999999  C=01000000000998
//
//    3) results to be displayed in “scientific notation” has 1 1012,
//
//    A=01000000000012  B=02999999999000  C=01000000000012
//
//    4) results to be displayed in “scientific notation” has 1 10-12,
//
//    A=01000000000912  B=02999999999000  C=01000000000988

typealias Mask = UInt8

enum SegmentMasks: UInt8 {
    case D0 = 0b00111111 // Digit 0
    case D1 = 0b00000110 // Digit 1
    case D2 = 0b01011011 // Digit 2
    case D3 = 0b01001111 // Digit 3
    case D4 = 0b01100110 // Digit 4
    case D5 = 0b01101101 // Digit 5
    case D6 = 0b01111101 // Digit 6
    case D7 = 0b00000111 // Digit 7
    case D8 = 0b01111111 // Digit 8
    case D9 = 0b01101111 // Digit 9
    case Point = 0b10000000 // Decimal Point
    case Minus = 0b01000000 // Minus Sign
    case Blank = 0b00000000 // Blank or Masked
}

import Foundation

class DisplayDecoder {
    
    static let sharedInstance = DisplayDecoder()
    
    func getMasks(cpuState: CPUState) -> [UInt8] {
        return [
            SegmentMasks.Minus.rawValue,
            SegmentMasks.D1.rawValue,
            SegmentMasks.Point.rawValue,
            SegmentMasks.D2.rawValue,
            SegmentMasks.D3.rawValue,
            SegmentMasks.D4.rawValue,
            SegmentMasks.D5.rawValue,
            SegmentMasks.D6.rawValue,
            SegmentMasks.D7.rawValue,
            SegmentMasks.D8.rawValue,
            SegmentMasks.D9.rawValue,
            SegmentMasks.D0.rawValue,
            SegmentMasks.Blank.rawValue,
            SegmentMasks.D9.rawValue,
            SegmentMasks.D9.rawValue
        ]
    }
}


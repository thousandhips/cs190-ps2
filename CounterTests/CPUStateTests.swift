//
//  CPUStateTests.swift
//  Calculator
//
//  Created by Brian Hill github.com/brianhill on 2/16/16.
//

import XCTest

// The tests in this class cover Nibble, Register and CPUState, but not InputHandler, which is tested elsewhere.

// From Nibble, we need to test nibbleFromCharacter() and hexCharacterFromNibble()

class CPUStateTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Tests of CPUState class
    
    // This function is used by several tests that follow:
    func commonTestCanonicalize(stringA: String, stringB: String, expectedC: String) {
        
        let cpuState = CPUState(decimalStringA: stringA, decimalStringB: stringB)
        
        let registerC = cpuState.registers[RegId.C.rawValue]
        let actualC = registerC.asDecimalString()
        
        
        XCTAssert(expectedC == actualC)
    }
    
    // Five examples were given in comments in DisplayDecoder.swift.

    // 100
    //    A=01000000000002  B=00029999999999  C=01000000000002
    //
    // .01
    //
    //    A=00100000000902  B=20099999999999  C=01000000000998
    //
    //  1 x 10^12
    //
    //    A=01000000000012  B=02999999999000  C=01000000000012
    //
    //  1 x 10^-12
    //
    //    A=01000000000912  B=02999999999000  C=01000000000988
    //
    //  -1.25 x 10^-2
    //    
    //    A=91250000000902  B=02009999999000  C=91250000000998
    //
    
    // All five examples are tested below:
    
    func testCanonicalizeSmallPositiveInteger() {
        self.commonTestCanonicalize("01000000000002", stringB: "00029999999999", expectedC: "01000000000002")
    }
    
    func testCanonicalizeSmallDecimalNumber() {
        self.commonTestCanonicalize("00100000000902", stringB: "20099999999999", expectedC: "01000000000998")
    }
    
    func testCanonicalizeLargePositiveInteger() {
        self.commonTestCanonicalize("01000000000012", stringB: "02999999999000", expectedC: "01000000000012")
    }
    
    func testCanonicalizeTinyDecimalNumber() {
        self.commonTestCanonicalize("01000000000912", stringB: "02999999999000", expectedC: "01000000000988")
    }
    
    func testCanonicalizeNegativeDecimalNumber() {
        self.commonTestCanonicalize("91250000000902", stringB: "02009999999000", expectedC: "91250000000998")
    }
    
    // Tests of Register struct
    
    func testInitFromDecimalString() {
        let actualRegister = Register(fromDecimalString:"91250000000902")
        let actualNibbles = actualRegister.nibbles
        let expectedNibbles = [
            Nibble(0b0010), Nibble(0b0000), Nibble(0b1001), Nibble(0b0000),
            Nibble(0b0000), Nibble(0b0000), Nibble(0b0000), Nibble(0b0000),
            Nibble(0b0000), Nibble(0b0000), Nibble(0b0101), Nibble(0b0010),
            Nibble(0b0001), Nibble(0b1001)
        ]
        XCTAssert(expectedNibbles.count == actualNibbles.count)
        for idx in 0 ..< expectedNibbles.count {
            let actual = actualNibbles[idx]
            let expected = expectedNibbles[idx]
            XCTAssert(actual == expected, "Actual nibble at index \(idx) \(actual) != expected nibble \(expected)")
        }
    }
    
    func testRegisterToDecimalString() {
        let expected = "91250000000902"
        let actualRegister = Register(fromDecimalString:expected)
        let actual = actualRegister.asDecimalString()
        XCTAssert(actual == expected)
    }
    
    // Tests of Nibble functions
    
    func testHexCharacterFromNibble() {
        let actual = hexCharacterFromNibble(Nibble(0b1111))
        let expected = Character("F")
        XCTAssert(actual == expected)
    }

    func testNibbleFromCharacter() {
        let actual = nibbleFromCharacter(Character("5"))
        let expected = Nibble(0b0101)
        XCTAssert(actual == expected)
    }

}

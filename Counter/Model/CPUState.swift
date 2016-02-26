//
//  CPUState.swift
//  Counter
//
//  Created by Brian Hill github.com/brianhill on 2/12/16.
//

// CPUState defines the various CPU registers we need to simulate an HP-35.
//
// This reference is the most thorough, but at the moment a bunch of the image links are broken:
//
// http://home.citycable.ch/pierrefleur/Jacques-Laporte/A&R.htm
//
// This reference is sufficient:
//
// http://www.hpmuseum.org/techcpu.htm

typealias Nibble = UInt8 // This should be UInt4, but the smallest width unsigned integer Swift has is UInt8.

typealias Pointer = UInt8 // Also should be UInt4. In any case, we are not currently using this or Status.

typealias Status = UInt16 // Should be a UInt12 if we wanted exactly as many status bits as the HP-35.

// This is how many nibbles there are in a register:
let RegisterLength = 14

// This is how many of the nibbles are devoted to the exponent:
let ExponentLength = 3

// Two utilities for testing and display:
func nibbleFromCharacter(char: Character) -> Nibble {
    return Nibble(Int(String(char))!)
}

func hexCharacterFromNibble(nibble: Nibble) -> Character {
    return Character(String(format:"%1X", nibble))
}


// A register is 14 nibbles (56 bits). Mostly nibbles are used to represent the digits 0-9, but the leftmost one, nibble 13, corresponds to the sign of the mantissa, nibbles 12 to 3 inclusive represent 10 digits of mantissa, and nibbles 2 to 0 represent the exponent.
struct Register {
    var nibbles: [Nibble] = [Nibble](count:RegisterLength, repeatedValue: UInt8(0))
    
    // Hmmm. It seems I need the empty initializer because I created init(fromDecimalString:).
    init() {}
    
    // Initialize a register from a fourteen-digit decimal string (e.g., "91250000000902")
    init(fromDecimalString: String) {
        let characters = Array(fromDecimalString.characters)
        assert(RegisterLength == characters.count)
        var characterIdx = 0
        var nibbleIdx = RegisterLength - 1
        while nibbleIdx >= 0 {
            let char: Character = characters[characterIdx]
            nibbles[nibbleIdx] = nibbleFromCharacter(char)
            characterIdx += 1
            nibbleIdx -= 1
        }
    }
    
    func asDecimalString() -> String {
        var digits: String = ""
        var nibbleIdx = RegisterLength - 1
        while nibbleIdx >= 0 {
            let nibble = nibbles[nibbleIdx]
            let hexChar = hexCharacterFromNibble(nibble)
            digits.append(hexChar)
            nibbleIdx -= 1
        }
        return digits 
    }
}

class CPUState {
    
    // The singleton starts in the traditional state that an HP-35 is in when you power it on.
    // The display just shows 0 and a decimal point.
    static let sharedInstance = CPUState(decimalStringA: "00000000000000", decimalStringB: "02999999999999")
    
    var registers = [Register](count:7, repeatedValue:Register())
    
    // All the important initialization is done above when registers is assigned.
    init() {}
    
    // A method provided prinicipally for testing. Allows the state of the registers that record user input to be
    // initialized from decimal strings. Register C will be canonicalized from registers A and B. The remaining
    // registers will be initialized to zeros.
    init(decimalStringA: String, decimalStringB: String) {
        let registerA = Register(fromDecimalString: decimalStringA)
        let registerB = Register(fromDecimalString: decimalStringB)
        
        registers[RegId.A.rawValue] = registerA
        registers[RegId.B.rawValue] = registerB
        
        canonicalize()
    }

    
    func getRegisterValue(regId: RegId) -> Register {
        return registers[regId.rawValue]
    }
    
    func setRegisterValue(regId: RegId, newValue: Register) {
        registers[regId.rawValue] = newValue
    }

    func canonicalize( ) {
        var registerA = registers[RegId.A.rawValue]
        var registerB = registers[RegId.B.rawValue]
        
        
        var MantissaIsPositive = false
        var ExponentIsPositve = false
        
        var registerC = Register(fromDecimalString: "00000000000000")
        registers[RegId.C.rawValue] = registerC
        
        var AIndex = 13
        var CIndex = 12
        
        //Determine signs of mantissa and exponent.
        if( registerA.nibbles[AIndex] == 0)
        {   MantissaIsPositive = true}
        if( registerA.nibbles[ExponentLength - 1] == 0)
        {   ExponentIsPositve = true
        }
        
        //Copy mantissa sign.
        if( MantissaIsPositive)
        { registerC.nibbles[AIndex]=UInt8(0) }
        else { registerC.nibbles[AIndex]=UInt8(9) }
        
        AIndex--
        
        //skip leading zeroes
        while( registerA.nibbles[AIndex] == 0 && AIndex > ExponentLength)
        { AIndex-- }
        
        while( AIndex > ExponentLength && registerB.nibbles[AIndex] != 9) {
        registerC.nibbles[CIndex] = registerA.nibbles[AIndex]
        CIndex--
        AIndex--
        }
        //Move on to the exponent places, if not there already.
        AIndex = ExponentLength - 1
        CIndex = ExponentLength - 1
        
        //Determine the exponent places, path dependent on the exponent's sign.
        if( ExponentIsPositve)
        {
            //If it's positive just copy
            while( AIndex >= 0 )
            {
            registerC.nibbles[AIndex] = registerA.nibbles[AIndex]
            AIndex--
            }
        }
        else{
            //Negative takes a little more calculation.
            //Copy the sign.
            registerC.nibbles[AIndex] = registerA.nibbles[AIndex]
            AIndex--
            //Calculate tens place.
            registerC.nibbles[AIndex] = 10 - registerA.nibbles[AIndex]
            AIndex--
            //Carry the one.
            if( registerC.nibbles[AIndex] != 0 )
            { registerC.nibbles[AIndex + 1]-- }
            else
            //If tens places is zero you want it to say zero instead of ten.
            { registerC.nibbles[AIndex + 1] = 0}
            //Calculate the ones place
            if( registerA.nibbles[AIndex] == 0 )
            { registerC.nibbles[AIndex] = 0 }
            else{
            registerC.nibbles[AIndex] = 10 - registerA.nibbles[AIndex]
            }
            
        }
        
    }

    
    
    
    func decimalStringForRegister(regId: RegId) -> String {
        let register = registers[regId.rawValue]
        return register.asDecimalString()
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

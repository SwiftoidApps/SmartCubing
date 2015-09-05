//
//  ScramblerGenerator.swift
//  SmartCubing
//
//  Created by Patrick Wamsley on 9/5/15.
//  Copyright © 2015 Swiftoid. All rights reserved.
//

// How to use: This class just holds a bunch of static util methods.
// Every call you make will return an Array of Strings, each element being one move. For example: ["R2", "D" etc.]
// How to call: ScrambleGenerator.getScrambleFor3x3() //returns 3x3 scramble
//              ScrambleGenerator.getScrambleForPryaminx() //returns pryaminx scramble
// Can get a scramble for 2x2 thru 7x7, pryaminx, skewb, and megaminx

import Foundation

class ScrambleGenerator {
    
    // NxNxNs
    static let MOVE_TYPES : [String] = ["R", "L", "U", "D", "F", "B"]
    static let MOVE_MODS : [String] = ["", "2", "'"]
    
    // Pyraminx
    static let P_MOVE_TYPES : [String] = ["L", "R", "U", "B"]
    static let P_MOVE_MODS :  [String] = ["", "'"]
    
    static func createScramble(scrambleLength : Int) -> [String] {
        
        var scramble : [String] = [getNextScrambleMove("")]
        
        var lastMove = scramble[0]
        
        while (scramble.count < scrambleLength) {
            
            let nextMove = getNextScrambleMove(lastMove)
            
            scramble.append(nextMove)
            
            lastMove = nextMove
        }
        return scramble
    }
    
    static func getNextScrambleMove(lastMoveType : String) -> String {
        
        var moveType = MOVE_TYPES[Int(arc4random_uniform(6))]
        
        while (moveType.isEqual(lastMoveType)) {
            moveType = MOVE_TYPES[Int(arc4random_uniform(6))]
        }
        return moveType + MOVE_MODS[Int(arc4random_uniform(3))]
    }
    
    static func getScrambleFor3x3() -> [String] {
        return createScramble(25)
    }
    
    static func getScrambleFor2x2() -> [String] {
        return createScramble(10)
    }
    
    static func getScrambleFor4x4() -> [String] {
        var startingArray = createScramble(35)
        
        for (var i = 0; i < startingArray.count; i++) {
            if (arc4random_uniform(2) == 1) {
                startingArray[i] = startingArray[i].lowercaseString
            }
        }
        return startingArray
    }
    
    static func getScrambleFor5x5() -> [String] {
        var startingArray = createScramble(60)
        
        for (var i = 0; i < startingArray.count; i++) {
            if (arc4random_uniform(2) == 1) {
                startingArray[i] = startingArray[i].lowercaseString
            }
        }
        return startingArray
    }
    
    static func getScrambleForPryaminx() -> [String] {
        
        var scramble : [String] = [getNextScrambleMove("")]
        
        var lastMove = scramble[0]
        
        while (scramble.count < 10) {
            
            let nextMove = getNextScambleMoveForPryaminx(lastMove)
            
            scramble.append(nextMove)
            
            lastMove = nextMove
        }
        return scramble
    }
    
    static func getNextScambleMoveForPryaminx(lastMoveType : String) -> String {
        
        var moveType = P_MOVE_TYPES[Int(arc4random_uniform(5))]
        
        while (moveType.isEqual(lastMoveType)) {
            moveType = P_MOVE_TYPES[Int(arc4random_uniform(5))]
        }
        
        let move =  moveType + P_MOVE_MODS[Int(arc4random_uniform(2))]
        
        return arc4random_uniform(5) == 0 ? move : move.lowercaseString
    }
    
    static func getScrambleForMegaminx() -> [String] {
        
        // 7 X 11
        
        var scrambleTable : [[String]] = []
        
        for (var row = 0; row < 7; row++) {
            for (var col = 0; col < 11; col++) {
                if (col == 10) {
                    scrambleTable[row][col] = "U"
                } else if (col % 2 == 0) {
                    scrambleTable[row][col] = "R"
                } else {
                    scrambleTable[row][col] = "D"
                }
            }
        }
        
        var scramble : String = ""
        
        for (var row = 0; row < 7; row++) {
            for (var col = 0; col < 7; col++) {
                scramble += scrambleTable[row][col] + " "
            }
        }
        
        var returnString = ""
        
        for character in scramble {
            if (character == "U") {
                returnString += arc4random_uniform(2) == 1 ? "'" : ""
            } else if (character == " "){
                returnString += String(character)
            } else {
                returnString += String(character)
                returnString += arc4random_uniform(2) == 1 ? "++" : "--"
            }
        }
        
        return split(returnString) {$0 == " "}.map{String($0)}
    }
    
    static func getScrambleFor6x6() -> [String] {
        
        let base = createScramble(80)
        var returnArray : [String] = []
        
        for move in base {
            let modType = arc4random_uniform(3)
            switch (modType) {
            case 0:
                var move2 = "3" + move
                returnArray.append(move2)
                break;
            case 1:
                var move2 = move.lowercaseString
                returnArray.append(move2)
                break;
            default:
                returnArray.append(move)
                break;
            }
        }
        return returnArray
    }
    
    static func getScrambleFor7x7() -> [String] {
        
        let base = createScramble(100)
        var returnArray : [String] = []
        
        for move in base {
            let modType = arc4random_uniform(3)
            switch (modType) {
            case 0:
                var move2 = "3" + move
                returnArray.append(move2)
                break;
            case 1:
                var move2 = move.lowercaseString
                returnArray.append(move2)
                break;
            default:
                returnArray.append(move)
                break;
            }
        }
        return returnArray
    }
    
    static func getScrambleForSkewb() -> [String] {
        //same moves as pryaminx
        
        var scramble : [String] = [getNextScrambleMove("")]
        
        var lastMove = scramble[0]
        
        while (scramble.count < 10) {
            
            let nextMove = getNextScambleMoveForSkewb(lastMove)
            
            scramble.append(nextMove)
            
            lastMove = nextMove
        }
        return scramble
        
    }
    
    static func getNextScambleMoveForSkewb(lastMoveType : String) -> String {
        
        var moveType = P_MOVE_TYPES[Int(arc4random_uniform(5))]
        
        while (moveType.isEqual(lastMoveType)) {
            moveType = P_MOVE_TYPES[Int(arc4random_uniform(5))]
        }
        
        return moveType + P_MOVE_MODS[Int(arc4random_uniform(2))]
    }
    
}
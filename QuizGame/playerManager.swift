//
//  playerManager.swift
//  QuizGame
//
//  Created by William Crump on 4/22/16.
//  Copyright © 2016 Paul McDonald . All rights reserved.
//

import Foundation

class playerManager {
    
    var players = [String: PlayerValues]()
    var playersArray = [String]()
    
    init() {
        
    }
    
    func addPlayer(playerId: String) {
        players[playerId] = PlayerValues()
        playersArray.append(playerId)
    }
    
    func updatePlayerInfo(playerId: String, playerValues: PlayerValues) {
        players[playerId] = playerValues
    }
    
    func changePlayerAnswer(playerId: String, answer: String) {
        players[playerId]?.setAnswer(answer)
        print("\(playerId) answer: \(players[playerId]!.currentAnswer)")
    }
    
    func incrementPlayerScore(playerId: String) {
        players[playerId]?.incrementScore()
        print("\(playerId) score: \(players[playerId]!.score)")
    }
    
    func resetCurrentAnswers() {
        for (playerId, playerVals) in players {
            playerVals.currentAnswer = "N/A"
        }
    }
    
    func allPlayersAnswered() -> Bool {
        var allAnswered = true
        for (_, playerValues) in players {
            if playerValues.currentAnswer == "N/A" {
                allAnswered = false
            }
        }
        
        return allAnswered 
    }
    
    
    func getWinner() -> [String] {
        var winningPlayersArray = [String]()
        var highscore = -1
        //var winningPlayer: String?
        for (player, playerValues) in players {
            if playerValues.getScore() > highscore {
                highscore = playerValues.getScore()
                
            }
        }
        
        for (player, playerVal) in players {
            if (playerVal.score == highscore) {
                winningPlayersArray.append(player)
            }
        }
        
//        if (highscore == 0) {
//            winningPlayer = "everyone"
//        }
        
        return winningPlayersArray
    }
    
    func findPlayerIndex(playerId: String) -> Int {
        var found = false
        var index = 1
        
        repeat {
            if playersArray[index] == playerId {
                found = true
            } else {
                index += 1
            }
        } while (!found && index < playersArray.count)
        
        return index
    }
    
    func resetPlayerValues() {
        for (_, playerVals) in players {
            playerVals.currentAnswer = "N/A"
            playerVals.score = 0
        }
    }
    
    func printPlayers() {
        for (playerId, _ ) in players {
            print("player: \(playerId) Answer: \(players[playerId]!.currentAnswer) Score: \(players[playerId]!.score)")
        }
    }
    
    
    
    //Helper class to hold letter answers/scores
    class PlayerValues {
        var currentAnswer = "N/A"
        var score: Int = 0
        
        init(answer: String, score: Int) {
            self.currentAnswer = answer
            self.score = score
        }
        
        init() {
            
        }
        
        func setAnswer(answer: String) {
            self.currentAnswer = answer
        }
        
        func incrementScore() {
            self.score = self.score + 1
        }
        
        func getScore() -> Int {
            return self.score
        }
        
        
    }
    
    
}

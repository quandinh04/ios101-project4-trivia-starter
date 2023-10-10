//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Thế Quân Đinh on 10/9/23.
//

import Foundation

class TriviaQuestionService {
    static func fetchQuestion(amount: Int,
                              completion: @escaping ([TriviaQuestion]?) -> Void) {
        let parameters = "amount=\(amount)"
        let url = URL(string: "https://opentdb.com/api.php?\(parameters)")!
        // create a data task and pass in the URL
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            // this closure is fired when the response is received
            guard error == nil else {
                assertionFailure("Error: \(error!.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                assertionFailure("Invalid response")
                return
            }
            guard let data = data, httpResponse.statusCode == 200 else {
                assertionFailure("Invalid response status code: \(httpResponse.statusCode)")
                return
            }
            
            let trivia = parse(data: data) // this response will be used to change the UI, so it must happen on the main thread
            DispatchQueue.main.async {
              completion(trivia) // call the completion closure and pass in the forecast data model
            }
            
            let decoder = JSONDecoder()
            let response = try! decoder.decode(TriviaAPIResponse.self, from: data)
            
            let decodedQuestions = response.results.map { question in
                var decodedQuestion = question
                decodedQuestion.question = question.question.htmlDecoded
                decodedQuestion.correctAnswer = question.correctAnswer.htmlDecoded
                decodedQuestion.incorrectAnswers = question.incorrectAnswers.map { answer in
                    return answer.htmlDecoded
                }
                
                return decodedQuestion
            }
            
            DispatchQueue.main.async {
                completion?(decodedQuestions)
            }
        }
        
        task.resume() // resume the task and fire the request
    }
    
    private static func parse(data: Data) -> TriviaQuestion {
      // transform the data we received into a dictionary [String: Any]
      let jsonDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
      let questions = jsonDictionary["results"] as! [String: Any]


      let catagory = questions["catagory"] as! [String: Any]
      let type = questions["type"] as! [String: Any]
      let difficulty = questions["difficulty"] as! [String: Any]
      let question = questions["temperature"] as! [String: Any]
      let correctAnswer = questions["correct_answer"] as! [String: Any]
      let incorrectAnswer = questions["incorrect_answers"] as! [[String]: Any]
      
      return []
    }
}


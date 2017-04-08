//
//  Tweet.swift
//  WSUV-Twitter
//
//  Created by David Ciupei on 4/7/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import Foundation

class Tweet: Hashable {
    var tweet_id : Int
    var username : String
    var isDeleted : Bool
    var tweet : String
    var date : NSDate
    
    var hashValue: Int {
        return tweet_id
    }

    init(tweetid : Int, U_name : String, delete : Bool, twt : String, date_ : NSDate){
        tweet_id = tweetid
        username = U_name
        isDeleted = delete
        tweet = twt
        date = date_
    }
    
}

func ==(lhs: Tweet, rhs: Tweet) -> Bool {
    return lhs.tweet_id == rhs.tweet_id
}

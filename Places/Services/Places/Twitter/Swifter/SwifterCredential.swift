//
//  Credential.swift
//  Swifter
//
//  Copyright (c) 2014 Matt Donnelly.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

#if os(macOS) || os(iOS)
import Accounts
#endif

public class SwifterCredential: Codable {
    
    public struct OAuthAccessToken: Codable {
        
        public internal(set) var key: String
        public internal(set) var secret: String
        public internal(set) var verifier: String?
        
        public internal(set) var screenName: String?
        public internal(set) var userID: String?
        
        public init(key: String, secret: String) {
            self.key = key
            self.secret = secret
        }
        
        public init(queryString: String) {
            let attributes = queryString.queryStringParameters
            
            self.key = attributes["oauth_token"]!
            self.secret = attributes["oauth_token_secret"]!
            
            self.screenName = attributes["screen_name"]
            self.userID = attributes["user_id"]
        }

		enum CodingKeys: CodingKey {
		  case key, secret, verifier, screenName, userID
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.key = try container.decode(String.self, forKey: .key)
			self.secret = try container.decode(String.self, forKey: .secret)
			
			self.verifier = try container.decodeIfPresent(String.self, forKey: .verifier)
			self.screenName = try container.decodeIfPresent(String.self, forKey: .screenName)
			self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
		}

//		public func encode(to encoder: Encoder) throws {
//			var container = encoder.singleValueContainer()
//			try container.encode(self.key)
//			try container.encode(self.secret)
//			try container.encode(self.verifier)
//			try container.encode(self.screenName)
//			try container.encode(self.userID)
//		}
    }

    public internal(set) var accessToken: OAuthAccessToken?
    
    public init(accessToken: OAuthAccessToken) {
        self.accessToken = accessToken
    }
    
}

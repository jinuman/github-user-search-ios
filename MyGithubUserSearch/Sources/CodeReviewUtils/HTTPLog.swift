//
//  HTTPLog.swift
//  MyGithubUserSearch
//
//  Created by tskim on 14/08/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation

class HTTPLog {
    
    static var enabled = true
    class func log(request: URLRequest) {
        #if !DEBUG
        return
        #endif
        
        if !enabled { return }
        
        let urlString = request.url?.absoluteString ?? ""
        let components = NSURLComponents(string: urlString)
        
        let method = request.httpMethod != nil ? "\(String(describing: request.httpMethod))" : ""
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        let host = "\(components?.host ?? "")"
        
        var requestLog = "\n---------- Request ---------->\n"
        requestLog += "\(urlString)"
        requestLog += "\n\n"
        requestLog += "\(method) \(path)?\(query) HTTP/1.1\n"
        requestLog += "Host: \(host)\n"
        requestLog += "Headers:\n"
        for (key, value) in request.allHTTPHeaderFields ?? [:] {
            requestLog += "\(key): \(value)\n"
        }
        if let body = request.httpBody {
            requestLog += "\n\(String(describing: NSString(data: body, encoding: String.Encoding.utf8.rawValue)))\n"
        }
        
        requestLog += "\n------------------------->\n"
        print(requestLog)
    }
    
    class func log(data: Data?, response: URLResponse?, error: Error?) {
        #if !DEBUG
        return
        #endif
        if !enabled { return }
        
        let urlString = response?.url?.absoluteString
        let components = NSURLComponents(string: urlString ?? "")
        
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        
        var responseLog = "\n<---------- Response ----------\n"
        if let urlString = urlString {
            responseLog += "\(urlString)"
            responseLog += "\n\n"
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            responseLog += "HTTP \(httpResponse.statusCode) \(path)?\(query)\n"
            
            responseLog += "\nHeaders\n\n"
            for (key, value) in httpResponse.allHeaderFields {
                responseLog += "[\(key): \(value)]\n"
            }
        }
        if let host = components?.host {
            responseLog += "Host: \(host)\n"
        }
        
        if let body = data {
            responseLog += "\n\(String(describing: body))\n"
        }
        if error != nil {
            responseLog += "\nError: \(error!.localizedDescription)\n"
        }
        
        responseLog += "<------------------------\n"
        print(responseLog)
    }
}

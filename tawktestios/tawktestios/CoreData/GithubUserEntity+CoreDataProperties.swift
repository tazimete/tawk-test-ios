//
//  GithubUserEntity+CoreDataProperties.swift
//  
//
//  Created by JMC on 30/7/21.
//
//

import Foundation
import CoreData


extension GithubUserEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GithubUserEntity> {
        return NSFetchRequest<GithubUserEntity>(entityName: "GithubUserEntity")
    }
    
    @NSManaged public var id: Int64
    @NSManaged public var username: String?
    @NSManaged public var avatarUrl: String?
    @NSManaged public var url: String?
}


extension GithubUserEntity {
    func update(user: AbstractDataModel){
        id = Int64((user.id ?? -1))
        
        let githubUser  = user as? GithubUser
        
        username = githubUser?.username
        avatarUrl = githubUser?.avatarUrl
        url = githubUser?.url
    }
    
    var asGithubUser: GithubUser{
        let user = GithubUser()
        user.id = Int(id)
        user.username = username
        user.avatarUrl = avatarUrl
        user.url = url
        return user
    }
}

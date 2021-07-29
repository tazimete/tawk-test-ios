//
//  GithubViewModel.swift
//  tawktestios
//
//  Created by JMC on 24/7/21.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

class GithubViewModel: AbstractGithubViewModel {
    public var dataProvider: DataProvider = DataProvider(persistentContainer: CoreDataStack.shared.persistentContainer, repository: ApiRepository()) 
    public var githubUserList: [GithubUser] = [GithubUser]()
    
//    struct Input {
//        let fetchGithubUserList: Observable<Void>
//    }
//
//    struct Output {
//        let githubUserList: BehaviorRelay<[GithubUser]>
//    }
//
    var steps = PublishRelay<Step>()
    var service: Service
    
    init(service: Service) {
        self.service = service
    }
    
//    func transform(input: Input) -> Output {
//        let githubUserList = BehaviorRelay<[GithubUser]>(value: [])
//
//        input.fetchGithubUserList.flatMapLatest({() -> Observable<[GithubUser]> in
//            return self.getGithubUserList(page: 20)
//        }).subscribe(onNext: {
//            [unowned self] userList in
//            print("\(self) -- transform() -- user name = \(userList.last?.username ?? "")")
//            githubUserList.accept(userList)
//        },onError: nil, onCompleted: nil, onDisposed: nil)
//
//        return Output(githubUserList: githubUserList)
//    }
    
//    func getGithubUserList(page: Int) -> Observable<[GithubUser]> {
//        return service.remoteDataSource.getGithubUserList(page: 20)
//    }
    
    func getGithubUserList(since: Int, completeionHandler: @escaping (() -> Void)) {
        service.remoteDataSource.getGitubUserList(since: since) { [unowned self] result in
            switch result{
                case .success(let users):
                    print("getGithubUserList() -- \(users.last?.username)")
                    self.dataProvider.syncFilms(jsonDictionary: users, taskContext: (self.dataProvider.persistentContainer.newBackgroundContext()))
                    self.githubUserList.append(contentsOf: users)
                    completeionHandler()
                case .failure(let error):
                    print("\((error as? NetworkError)?.localizedDescription)")
            }
        }
    }
}

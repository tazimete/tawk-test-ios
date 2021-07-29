//
//  ViewController.swift
//  tawktestios
//
//  Created by JMC on 23/7/21.
//

import UIKit
import CoreData

class GithubUserListViewController: BaseViewController {
    private let tableView = UITableView()
    private var githubViewModel: AbstractGithubViewModel!
    
//    var dataProvider: DataProvider = DataProvider(persistentContainer: CoreDataStack.shared.persistentContainer, repository: ApiRepository())
    lazy var fetchedResultsController: NSFetchedResultsController<GithubUserEntity> = {
        let fetchRequest = NSFetchRequest<GithubUserEntity>(entityName:"GithubUserEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending:true)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: CoreDataStack.shared.persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        fetchRequest.fetchBatchSize = 20 
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()
    
    public static func loadViewController(viewModel: ViewModel) -> GithubUserListViewController?{
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "GithubUserListViewController") as! GithubUserListViewController
        vc.viewModel = viewModel
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        testNetworkOperation()
//        dataProvider.fetchFilms { (error) in
//            // Handle Error by displaying it in UI
//        }
    }
    
    override func initView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 0, enableInsets: true)
        
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(GithubUserCell.self, forCellReuseIdentifier: GithubUserCell.cellReuseIdentifier)
    }
    
    override func bindViewModel() {
        githubViewModel = viewModel as! GithubViewModel
        
        githubViewModel.getGithubUserList(since: 20, completeionHandler: { [unowned self] in
            print("\(self.TAG) -- getGithubUserList() -- 0")
        })
        
//        githubViewModel.getGithubUserList(since: 20, completeionHandler: { [weak self] in
//            self?.tableView.reloadData()
//            print("\(self?.TAG) -- getGithubUserList() -- 1")
//        })
//
//        githubViewModel.getGithubUserList(since: 20, completeionHandler: { [weak self] in
//            self?.tableView.reloadData()
//            print("\(self?.TAG) -- getGithubUserList() -- 2")
//        })
//
//        githubViewModel.getGithubUserList(since: 20, completeionHandler: { [weak self] in
//            self?.tableView.reloadData()
//            print("\(self?.TAG) -- getGithubUserList() -- 3")
//        })
//
//        githubViewModel.getGithubUserList(since: 20, completeionHandler: { [weak self] in
//            self?.tableView.reloadData()
//            print("\(self?.TAG) -- getGithubUserList() -- 4")
//        })
    
    }
}


// MARK: Tableview  
extension GithubUserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GithubUserCell.cellReuseIdentifier, for: indexPath)
                as? GithubUserCell else{
            return UITableViewCell() 
        }
        
//        cell.user = githubViewModel.githubUserList[indexPath.row]
        cell.user = (fetchedResultsController.object(at: indexPath) as? GithubUserEntity)?.asGithubUser
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = (fetchedResultsController.fetchedObjects?.last as? GithubUserEntity)?.asGithubUser
        githubViewModel.getGithubUserList(since: user?.id ?? 0, completeionHandler: { [unowned self] in
            print("\(self.TAG) -- getGithubUserList() -- 00")
        })
    }
}


extension GithubUserListViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.reloadData()
    }
}

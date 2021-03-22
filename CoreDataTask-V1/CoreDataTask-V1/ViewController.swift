//
//  ViewController.swift
//  CoreDataTask-V1
//
//  Created by Shaik abdul mazeed on 22/03/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var ad = UIApplication.shared.delegate as! AppDelegate
    var moc:NSManagedObjectContext!
    var jsonData:[PostsData] = []
    var postsEntityRef:NSEntityDescription!
    var tableView:UITableView!
    var titlesarray:[String] = []
    var idarray:[Int16] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postsData()
        // Do any additional setup after loading the view.
        fetchData()
        createTable()
    }
    func postsData(){
        moc = ad.persistentContainer.viewContext
        postsEntityRef = NSEntityDescription.entity(forEntityName: "Posts", in: moc)
        var requestURL = URLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
        requestURL.httpMethod = "GET"
        let dataTask =  URLSession.shared.dataTask(with: requestURL) { [self] (data, res, err) in
            
            if err == nil{
                do{
                    
                    let myJson = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String:Any]]
                    for i in 0..<myJson.count{
                        let id = myJson[i]["id"] as! Int
                        let userId = myJson[i]["userId"] as! Int
                        let body = myJson[i]["body"] as! String
                        let titles = myJson[i]["title"] as! String
                        let userMO = NSManagedObject(entity: postsEntityRef, insertInto: moc)
                        userMO.setValue(id, forKey: "id")
                        userMO.setValue(body, forKey: "body")
                        userMO.setValue(titles, forKey: "title")
                        userMO.setValue(userId, forKey: "userId")
                        saveData()
                    }
                }
                catch{
                    print("error occured:\(err?.localizedDescription)")
                }
            }
        }
        dataTask.resume()
    }
    func saveData(){
        do{
            try moc.save()
            //print("saved successfully")
        }catch{
            print("Saving error:\(error.localizedDescription)")
        }
        
    }
    func fetchData(){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Posts")
        
        do{
            let storedData:[NSManagedObject] = try moc.fetch(fetchRequest) as [NSManagedObject]
            for i in 0..<storedData.count{
                let titles:NSManagedObject = storedData[i] 
                //let id:NSManagedObject = storedData[i]
                print("Stored Data titles:", titles.value(forKey: "title")!, "id is",  titles.value(forKey: "id")!)
                let myTitile:String = titles.value(forKey: "title")! as! String
                let userID:Int16 = titles.value(forKey: "userId")! as! Int16
                let id:Int16 = titles.value(forKey: "id") as! Int16
                let body:String = titles.value(forKey: "body") as! String
                              
                
                titlesarray.append(myTitile)
                idarray.append(id)
                
            }
            
        }catch{
            print("fetched data:\(error.localizedDescription)")
        }
        
    }
    func createTable(){
        tableView = UITableView(frame: view.frame, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
    }
    


}
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idarray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(idarray[indexPath.row])"
        cell.detailTextLabel?.text = titlesarray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
}

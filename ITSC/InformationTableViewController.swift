//
//  InformationTableViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/9.
//

import UIKit

class InformationTableViewController: UITableViewController {

    class News{
        var Title:String = ""
        var Date:String = ""
        var URL:String = ""
    }
    
    var newsArray:Array<News> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWeb(myUrl: "https://itsc.nju.edu.cn/wlyxqk/")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    func loadWeb(myUrl:String) {
        let url = URL(string: myUrl)!
        let task = URLSession.shared.dataTask(with:url, completionHandler: {
            data, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                      print("server error")
                      return
            }
            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
               let data = data,
               let string = String(data:data, encoding: .utf8) {
                DispatchQueue.main.async {
                    let lines = string.replacingOccurrences(of: "\t", with: "").split(separator:"\r\n")
                    for line in lines {
                        let text = line.split(separator: ">")
                        if text[0] == "<span class=\"news_title\"" {
                            let news = News()
                            news.Title = text[2].replacingOccurrences(of: "</a", with: "")
                            news.URL = "https://itsc.nju.edu.cn" + text[1].split(separator: "\'")[1]
                            self.newsArray.append(news)
                        }
                        else if text[0] == "<span class=\"news_meta\"" {
                            self.newsArray.last?.Date = text[1].replacingOccurrences(of: "</span", with: "")
                        }
                        else if text.count > 2 && text[2] == "下一页&gt;&gt;</span" {
                            self.loadWeb(myUrl: "https://itsc.nju.edu.cn" + text[0].split(separator: "\"")[3])
                        }
                    }
                    self.tableView.reloadData()
                    
                    //for i in self.newsArray {
                       // print("Title: " + i.Title + "\nDate: " + i.Date + "\nURL: " + i.URL)
                    //}
                }
            }
        })
        task.resume()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.newsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "informationCell", for: indexPath) as! NewsTableViewCell
        cell.Date.text = self.newsArray[indexPath.row].Date
        cell.Title.text = self.newsArray[indexPath.row].Title
        
        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let detailViewController = segue.destination as! DetailViewController
        let cell = sender as! NewsTableViewCell
        detailViewController.myURL = newsArray[tableView.indexPath(for: cell)!.row].URL
    }


}

//
//  DetailViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/9.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    var myURL:String=""
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWeb()
        // Do any additional setup after loading the view.
    }
    
    func loadWeb() {
        let task = URLSession.shared.dataTask(with: URL(string: self.myURL)!, completionHandler: {
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
                            let string = String(data: data, encoding: .utf8) {
                                DispatchQueue.main.async {
                                    var content="<html>\r\n<meta charset=\"utf-8\">\r\n<base href=\"https://itsc.nju.edu.cn\"/>\r\n"
                                    let lines=string.split(separator: "\r\n")
                                    var flag:Bool=false
                                    for i in lines{
                                        if i == "<!--Start||content-->"{
                                            flag=true
                                        }
                                        else if i == "<!--End||content-->"{
                                            flag=false
                                        }
                                        if flag{
                                            if i.components(separatedBy: "frag").count > 1 {
                                                let item = i.replacingOccurrences(of: ">", with: " align=\"center\">")
                                                content=content+item+"\r\n"
                                                print(item)
                                                continue
                                            }
                                            content=content+i+"\r\n"
                                            print(i)
                                        }
                                    }
                                    content+="<html/>\r\n"
                                    self.webView.loadHTMLString(content, baseURL: nil)
                            }
                }
            })
        task.resume()
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}


//
//  JSONFetchTableViewController.swift
//  iOS Programming Test
//
//  Created by Bertrand on 16/04/2015.
//  Copyright (c) 2015 Bertrand Bloc'h. All rights reserved.
//

import UIKit

class JSONFetchTableViewController: UITableViewController {
   
// MARK: - Var and Property
    
    var ImageTitle:Array< String > = Array < String >()
    var User:Array< String > = Array < String >()
    var IDImageForUrl:Array< String > = Array < String >()
    
    let urlChallenge = "http://challenge.superfling.com"
    
    var tableData = []
    var imageCache = [String : UIImage]()
    

 
// MARK: - App LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetContentOfTableView()
        
        automaticSizeSettingOfARow()
        
        get_data_from_url(urlChallenge)
    }
    
// MARK: - TableView
    
    func resetContentOfTableView(){
        
        ImageTitle.removeAll(keepCapacity: true)
        
        User.removeAll(keepCapacity: true)
        
        IDImageForUrl.removeAll(keepCapacity: true)
        
    }
    
    func automaticSizeSettingOfARow(){
        
        tableView.estimatedRowHeight = tableView.rowHeight
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ImageTitle.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as JSONFetchTableViewCell!
        if cell == nil {
            cell = JSONFetchTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }

        var imageJsonUrl:String = "http://challenge.superfling.com/photos/" + String(indexPath.row + 1)
    
        var imageUrl = NSURL(string: imageJsonUrl)
        
        // Check our image cache for the existing key. This is just a dictionary of UIImages
        
        var image = self.imageCache[imageJsonUrl]
        
        if( image == nil ) {
            
            // If the image does not exist, we need to download it
            cell.imageFromJson.image = UIImage(named: "placeholder")
            if let url = imageUrl {
                
                let qos = Int(QOS_CLASS_USER_INITIATED.value)
                dispatch_async(dispatch_get_global_queue(qos, 0), { () -> Void in
                    
                    var imgURL: NSURL = NSURL(string: imageJsonUrl)!
                    
                    // Download an NSData representation of the image at the URL
                    let request: NSURLRequest = NSURLRequest(URL: imgURL)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                        if error == nil {
                            image = UIImage(data: data)
                        
                            println("Image \(self.ImageTitle[indexPath.row]) Loaded !")
                            
                            // Store the image in to our cache
                            self.imageCache[imageJsonUrl] = image
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as JSONFetchTableViewCell!{
                                    cellToUpdate.imageFromJson.image = image
                                }
                            })
                            
                        }
                        else {
                            println("Error: \(error.localizedDescription)")
                        }
                    })
                })
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as JSONFetchTableViewCell!{
                    cellToUpdate.imageFromJson.image = image
                }
            })
        }
        
        cell.lbImageTitle.text = ImageTitle[indexPath.row]
        cell.lbUser.text = User[indexPath.row]
        
        return cell
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Indexpath.row : \(indexPath.row)")
        println("Image's Id : \(IDImageForUrl[indexPath.row])")
    }
    
    // MARK: - JSON Request
    
    func get_data_from_url(url:String)
    {
        let httpMethod = "GET"
        let timeout = 15
        let url = NSURL(string: url)
        let urlRequest = NSMutableURLRequest(URL: url!,
            cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 15.0)
        let queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(urlRequest,queue: queue,completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) in
            if data.length > 0 && error == nil{
                let json = NSString(data: data, encoding: NSASCIIStringEncoding)
                self.extract_json(json!)
            }else if data.length == 0 && error == nil{
                println("Nothing was downloaded")
            } else if error != nil{
                println("Error happened = \(error)")
            }
            }
        )
    }
    
    func extract_json(data:NSString)
    {
        var parseError: NSError?
        let jsonData:NSData = data.dataUsingEncoding(NSASCIIStringEncoding)!
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &parseError)
        if (parseError == nil)
        {
            if let imagesList = json as? NSArray
            {
                for (var i = 0; i < imagesList.count ; i++ )
                {
                    if let image_obj = imagesList[i] as? NSDictionary
                    {
                        if let ID = image_obj["ID"] as? Int
                        {
                            if let ImageID = image_obj["ImageID"] as? Int
                            {
                                if let Title = image_obj["Title"] as? String
                                {
                                    if let UserID = image_obj["UserID"] as? Int
                                    {
                                        if let UserName = image_obj["UserName"] as? String
                                        {
                                            ImageTitle.append(Title)
                                            User.append(UserName)
                                            IDImageForUrl.append(String(ID))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        do_table_refresh();
    }
    
    func do_table_refresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            return
        })
    }

    
}

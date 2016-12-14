//
//  CV_TableViewLocal.swift
//  CrawlVideo
//
//  Created by Tuuu on 6/22/16.
//  Copyright © 2016 TuNguyen. All rights reserved.
//

import UIKit
import AVFoundation
class CV_TableViewLocal: UIViewController {
    var listSongs = [Song]()
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    func getData()
    {
        listSongs.removeAll()
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            do
            {
                let folders = try FileManager.default.contentsOfDirectory(atPath: dir)
                for folder in folders
                {
                    if (folder != ".DS_Store")
                    {
                        
                        let info = NSDictionary(contentsOfFile: dir+"/"+folder+"/"+"info.plist")
                        let title = info!["title"] as! String
                        let artistName = info!["artistName"] as! String
                        let thumbnailPath = info!["localThumbnail"] as! String
                        let sourceLocal = dir+"/\(title)/\(title).mp3"
                        let lyric = info!["lyrics_file"] as! String
                        let currentSong = Song(title: title, artistName: artistName, localThumbnail: dir+thumbnailPath, localSource: sourceLocal, lyric: lyric)
                        listSongs.append(currentSong)
                    }
                }
                myTableView.reloadData()
                
            }
            catch let error as NSError
            {
                print(error)
            }
            
        }
        
    }
    func removeSongAtIndex(_ index: Int)
    {
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            do
            {
                let path = dir+"/\(listSongs[index].title)"
                try FileManager.default.removeItem(atPath: path)
                listSongs.remove(at: index)
                self.myTableView.reloadData()
            }
            catch let error as NSError
            {
                print(error)
            }
            
        }
        
    }
    
}
extension CV_TableViewLocal: UITableViewDataSource
{
    //UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSongs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.imageView?.image = listSongs[indexPath.row].thumbnail
        cell.textLabel?.text = "\(listSongs[indexPath.row].title)   Ca Sỹ: \(listSongs[indexPath.row].artistName)"
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
}
extension CV_TableViewLocal: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audioPlay = AudioPlayer.sharedInstance
        audioPlay.pathString = listSongs[indexPath.row].sourceLocal
        audioPlay.titleSong = listSongs[indexPath.row].title + "(\(listSongs[indexPath.row].artistName))"
        audioPlay.setupAudio()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupObserverAudio"), object: nil)
        
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.removeSongAtIndex(indexPath.row)
        }
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1.0)
        return [edit]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;
    }
}

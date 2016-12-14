//
//  ViewController.swift
//  CrawlVideo
//
//  Created by Tuuu on 6/21/16.
//  Copyright © 2016 TuNguyen. All rights reserved.
//

import UIKit
import AVFoundation
let kDOCUMENT_DIRECTORY_PATH = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first

class CV_TableViewOnline: UIViewController{
    var listSongs = [Song]()
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(kDOCUMENT_DIRECTORY_PATH)
        getData()
    }
    
    func getData()
    {
        //Lấy dữ liệu từ trang HTML
        let data = try? Data(contentsOf: URL(string: "http://mp3.zing.vn/bang-xep-hang/bai-hat-Viet-Nam/IWZ9Z08I.html?w=49&y=2016")!)
        //Dùng TFHpple để parse dữ liệu
        let doc = TFHpple(htmlData: data)
        if let elements = doc?.search(withXPathQuery: "//h3[@class='title-item']/a") as? [TFHppleElement] {
            for element in elements {
                //lấy ra link của bài hát
                DispatchQueue.global(qos: .default).async(execute: {
                    let id = self.getID(element.object(forKey: "href") as NSString)
                    print(id)
                    //Link API
                    let url = URL(string:"http://api.mp3.zing.vn/api/mobile/song/getsonginfo?keycode=fafd463e2131914934b73310aa34a23f&requestdata={\"id\":\"\(id)\"}".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
                    var stringData = ""
                    do
                    {
                        stringData = try String(contentsOf: url!)
                    }
                    catch let error as NSError
                    {
                        print(error)
                    }
                    let json = self.convertStringToDictionary(stringData)
                    if (json != nil)
                    {
                        self.addSongToList(json!)
                    }
                    
                    
                    
                })
                
            }
        }
    }
    
    func addSongToList(_ json: [String:AnyObject])
    {
        let title = json["title"] as! String
        let artistName = json["artist"] as! String
        let thumbnail = json["thumbnail"] as! String
        let source = json["source"]!["128"] as! String
        let lyric = json["lyrics_file"] as! String
        
        let currentSong = Song(title: title, artistName: artistName, thumbnail: thumbnail, source: source, lyric: lyric)
        listSongs.append(currentSong)
        DispatchQueue.main.async {
            self.myTableView.reloadData()
        }
    }
    
    func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    func getID(_ path: NSString) -> NSString
    {
        let id = (path.lastPathComponent as NSString).deletingPathExtension
        return id as NSString
    }
    
    
    func downloadSong(_ index: Int)
    {
        let dataSong = try? Data(contentsOf: URL(string:listSongs[index].sourceOnline)!)
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            //writing
            let pathToWriteSong = "\(dir)/\(listSongs[index].title)"
            do {
                try FileManager.default.createDirectory(atPath: pathToWriteSong, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
            
            writeDataToPath(dataSong! as NSObject, path: "\(pathToWriteSong)/\(listSongs[index].title).mp3")
            writeInfoSong(listSongs[index], path: pathToWriteSong)
            
        }
        
        
    }
    func writeInfoSong(_ song: Song, path: String)
    {
        let dictData = NSMutableDictionary()
        dictData.setValue(song.title, forKey: "title")
        dictData.setValue(song.artistName, forKey: "artistName")
        dictData.setValue("/\(song.title)/thumbnail.png", forKey: "localThumbnail")
        dictData.setValue(song.sourceOnline, forKey: "sourceOnline")
        dictData.setValue(song.lyric, forKey: "lyrics_file")
        //writing info
        writeDataToPath(dictData, path: "\(path)/info.plist")
        
        
        //writing thumbnail
        let dataThumbnail = NSData(data: UIImagePNGRepresentation(song.thumbnail)!) as Data
        writeDataToPath(dataThumbnail as NSObject, path: "\(path)/thumbnail.png")
        
        var lyricsStr = " "
        if song.lyric != "" {
            let url = NSURL(string: song.lyric)!
            do {
                try lyricsStr = String(contentsOf: url as URL, encoding: String.Encoding.utf8)
            } catch {
                print("error")
            }
        }
        
        // download + write to file
        do {
            try lyricsStr.write(toFile: "\(path)/lyrics_file.txt", atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("error")
        }
    }
    func writeDataToPath(_ data: NSObject, path: String)
    {
        if let dataToWrite = data as? Data
        {
            try? dataToWrite.write(to: URL(fileURLWithPath: path), options: [.atomic])
        }
        else if let dataInfo = data as? NSDictionary
        {
            dataInfo.write(toFile: path, atomically: true)
        }
    }
}
//UITableView
extension CV_TableViewOnline: UITableViewDataSource {
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSongs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.imageView?.image = listSongs[indexPath.row].thumbnail
        cell.textLabel?.text = "\(listSongs[indexPath.row].title) Ca Sỹ: \(listSongs[indexPath.row].artistName)"
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
}
extension CV_TableViewOnline: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audioPlay = AudioPlayer.sharedInstance
        audioPlay.pathString = listSongs[indexPath.row].sourceOnline
        audioPlay.titleSong = listSongs[indexPath.row].title + "(\(listSongs[indexPath.row].artistName))"
        audioPlay.setupAudio()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupObserverAudio"), object: nil)
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Download") { action, index in
            
            DispatchQueue.global(qos: .default).async(execute: {
                
                self.downloadSong(indexPath.row)
            })
            self.myTableView.reloadData()
        }
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1.0)
        return [edit]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;
    }
}


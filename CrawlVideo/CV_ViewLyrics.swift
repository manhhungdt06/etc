//
//  CV_ViewLyrics.swift
//  CrawlVideo
//
//  Created by admin on 12/14/16.
//  Copyright © 2016 TuNguyen. All rights reserved.
//

import UIKit

class CV_ViewLyrics: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pageControler: UIPageControl!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var recentTableView : UITableView!
    var lyricTableView : UITableView!
    
    var listSongs = [Song]()
    
    var first = true
    var currentPage = 0
    let audioPlayer = AudioPlayer.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    override func viewDidLayoutSubviews() {
        if (first){
            first = false
            let widthView = scrollView.frame.size.width
            let heightView = scrollView.frame.size.height
            
            scrollView.contentSize = CGSize(width: widthView * CGFloat(2), height: 10)
            
            scrollView.contentOffset = CGPoint(x: CGFloat(currentPage) * widthView, y: 0)
            
            for i in 0..<2 {
                let tableView_ = UITableView(frame: CGRect(x: widthView * CGFloat(i), y: 17, width: widthView, height: heightView-90))
                
                tableView_.tag = i + 100
                tableView_.dataSource = self
                tableView_.delegate = self
                
                scrollView.addSubview(tableView_)
                scrollView.decelerationRate = 1
            }
            
        }
        
        for view in scrollView.subviews {
            if view.tag == 101 {
                lyricTableView = view as! UITableView
                lyricTableView.delegate = self
            } else if view.tag == 100 {
                recentTableView = view as! UITableView
            }
        }
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
                recentTableView.reloadData()
            }
            catch let error as NSError
            {
                print(error)
            }
        }
    }
    
    
    var i = 0
    func autoScroll(){
        if audioPlayer.lyric.count != 0 {
            let currentTime =  Double(audioPlayer.currentTime)
            let lyricTime = stringToDouble(string: audioPlayer.lyric[i].time)
            
            if currentTime >= lyricTime {
                // lấy thời gian giữa 2 lyric
                let durationTime = stringToDouble(string: audioPlayer.lyric[i+1].time) - stringToDouble(string: audioPlayer.lyric[i].time)
                
                // number Of Section
                let nos = lyricTableView.numberOfSections
                let currentPath : IndexPath = IndexPath(row: i, section: nos - 1)
                let cell = lyricTableView.cellForRow(at: currentPath as IndexPath)
                let lengthText = audioPlayer.lyric[i].content == "" ? 3 : Double(audioPlayer.lyric[i].content.characters.count)
                var length = 0.0
                if lengthText < 5 {
                    length = lengthText * 1.1
                } else if lengthText < 10 && lengthText > 5{
                    length = lengthText * 3
                } else if lengthText < 15 && lengthText > 10{
                    length = lengthText * 4
                } else {
                    length = lengthText * 5
                }
                
                let characterInterval = durationTime / length
                cell?.textLabel?.setTextWithWordTypeAnimation(typedText: (cell?.textLabel)!, characterInterval: characterInterval)
                
                i += 1
                lyricTableView.selectRow(at: currentPath as IndexPath, animated: false, scrollPosition: .middle)
                
            }
        }
    }
    
    func stringToDouble(string : String) -> Double {
        let string1 = string.components(separatedBy: ":")
        let min = Double(string1[0])
        
        let string2 = string1[1].components(separatedBy: ".")
        let sec = Double(string2[0])
        let msec = Double(string2[1])! * 0.01
        
        return min! * 60 + sec! + msec
    }
    
    func removeSongAtIndex(_ index: Int)
    {
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            do
            {
                let path = dir+"/\(listSongs[index].title)"
                try FileManager.default.removeItem(atPath: path)
                listSongs.remove(at: index)
                self.recentTableView.reloadData()
            }
            catch let error as NSError
            {
                print(error)
            }
        }
    }
    
    //UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 101 {
            return audioPlayer.lyric.count
        } else if tableView.tag == 100 {
            return listSongs.count
        }
        return 3
    }
    
    func setSelector(cell: UITableViewCell){
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        cell.backgroundColor = UIColor.white
        cell.backgroundView?.alpha = 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if tableView.tag == 101 {
            var content = ""
            if audioPlayer.lyric[indexPath.row].content == "" {
                content = ""
            } else {
                content = audioPlayer.lyric[indexPath.row].content
            }
            cell.textLabel?.text = content
            cell.textLabel?.textAlignment = NSTextAlignment.center
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            cell.textLabel?.textColor = UIColor.gray
            setSelector(cell: cell)
            
            //            return cell
            
        } else if tableView.tag == 100 {
            let nib = UINib(nibName: "CustomCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "Cell")
            
            let cellLocal : CustomCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
            cellLocal.imageSong.isHidden = true
            
            cellLocal.imageSong.image = listSongs[(indexPath as NSIndexPath).row].thumbnail
            cellLocal.nameSong.text = listSongs[indexPath.row].title
            cellLocal.artistSong.text = listSongs[indexPath.row].artistName
    
            setSelector(cell: cellLocal)
            
            return cellLocal
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 100 {
            let audioPlay = AudioPlayer.sharedInstance
            let titleSong = listSongs[indexPath.row].title
            audioPlay.pathString = listSongs[indexPath.row].sourceLocal
            
            audioPlay.titleSong = titleSong
            audioPlay.artistName = listSongs[indexPath.row].artistName
            audioPlay.lyric = getLyric(title: titleSong)
            
            cellSelected(indexPath: indexPath as NSIndexPath)
            lyricTableView.reloadData()
            if audioPlay.lyric.count == 0  {
                print("etc")
            } else {
                Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(CV_ViewLyrics.autoScroll), userInfo: nil, repeats: true)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "setupObserverAudio"), object: nil)
            i = 0
        
        }
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.removeSongAtIndex(indexPath.row)
        }
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1.0)
        return [edit]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 101 {
            return 50
        }
        return 80
    }
    
    func getLyric(title: String) -> [Lyric]{
        var lyricList = [Lyric]()
        
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            let file = dir + "/\(title)/lyrics_file.txt"
            let data = try! String(contentsOfFile: file)
            
            var myStrings = data.components(separatedBy: NSCharacterSet.newlines)
            
            if myStrings.count != 1 {
                for i in myStrings {
                    if i == "" {
                        myStrings.remove(at: myStrings.index(of: i)!)
                    }
                }
                var timeEnd = ""
                for i in myStrings{
                    if i.hasPrefix("[length:") {
                        let myNSString = i as NSString
                        // cắt chuỗi từ vị trí 9 độ dài 5 xong r cắt chuỗi qua dấu ":"
                        timeEnd = myNSString.substring(with: NSRange(location: 9, length: 5))+".100"
                    }
                    if myStrings[5].hasPrefix("[id:") {
                        if myStrings.index(of: i)! > 5 {
                            lyricList.append(appendLyric(i: i))
                        }
                    } else {
                        if myStrings.index(of: i)! > 4 {
                            lyricList.append(appendLyric(i: i))
                        }
                    }
                }
                lyricList.append(Lyric(time: timeEnd, content: ""))
            }
        }
        return lyricList
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth)+1)
        if (currentPage != page) {
            currentPage = page
        }
        pageControler.currentPage = page
    }
    
    func appendLyric(i : String) -> Lyric {
        var word = i.components(separatedBy: "]")
        var time = word[0]
        
        time.remove(at: time.startIndex)
        let content: String = word[1]
        return Lyric(time: time, content: content)
    }
    
    func cellSelected(indexPath : NSIndexPath){
        let cell = tableView(recentTableView, cellForRowAt: indexPath as IndexPath) as! CustomCell
        cell.imageSong.isHidden = false
    }
}

extension UILabel {
    func setTextWithWordTypeAnimation(typedText: UILabel, characterInterval: Double) {
        DispatchQueue.global().async {
            let attributedString = NSMutableAttributedString(string:typedText.text!)
            for i in 0...typedText.text!.characters.count{
                
                DispatchQueue.main.async {
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red , range:  NSRange(location: 0, length: i) )
                    typedText.attributedText = attributedString
                }
                Thread.sleep(forTimeInterval: characterInterval)
                
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black , range:  NSRange(location: 0, length: typedText.text!.characters.count))
                typedText.attributedText = attributedString
            }
        }
    }
}

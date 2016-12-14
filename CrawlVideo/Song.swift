//
//  Song.swift
//  CrawlVideo
//
//  Created by Tuuu on 6/21/16.
//  Copyright © 2016 TuNguyen. All rights reserved.
//

import Foundation
import UIKit
struct Song {
    var title = ""
    var artistName = ""
    var thumbnail: UIImage
    var sourceOnline = ""
    var sourceLocal = ""
    let baseThumbnail = "http://image.mp3.zdn.vn//thumb/240_240/"
    var localThumbnail = ""
    var lyric = ""
    init(title: String, artistName: String, thumbnail: String, source: String, lyric : String)
    {
        self.title = title
        self.artistName = artistName
        let thumbnailURL = baseThumbnail+thumbnail
        let dataImage = try? Data(contentsOf: URL(string: thumbnailURL)!)
        self.thumbnail = UIImage(data: dataImage!)!
        self.sourceOnline = source
        self.lyric = lyric
    }
    init(title: String, artistName: String, localThumbnail: String, localSource: String, lyric : String){
        self.title = title
        self.artistName = artistName
        self.localThumbnail = localThumbnail
        let dataImage = try? Data(contentsOf: URL(fileURLWithPath: self.localThumbnail))
        self.thumbnail = UIImage(data: dataImage!)!
        self.sourceLocal = localSource
        self.lyric = lyric
    }
    
}

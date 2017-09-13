//
//  Batch.swift
//  Pixels0rtr
//
//  Created by norsez on 2/11/17.
//  Copyright © 2017 Bluedot. All rights reserved.
//

import UIKit
import Photos

//MARK - file io
extension SortParam {
    
    
    static func savedBatchedDIRURL() throws -> URL {
        let batchDirName = "sortparam_batch"
        var url  = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        url.appendPathComponent(batchDirName)
        
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        
        return url
    }
    
    static func clearBatch() throws {
        let url = try SortParam.savedBatchedDIRURL()
        let items = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        items.forEach({ (item_url) in
            do {
                try FileManager.default.removeItem(at: url)
            }catch {
                Logger.log("\(error)")
            }
        })
    }
    
    func save(withImageFilePath imagePath: String) throws {
        
        var url = try SortParam.savedBatchedDIRURL()
        let df = NumberFormatter()
        df.maximumSignificantDigits = 2
        let hash = df.string(from:  fRandom(min: 0, max: 10) as NSNumber)
        let filename = "\(hash!)_sortparam_\(self.sorter.name)_\(self.pattern.name)_\(df.string(from: self.sortAmount as NSNumber)!)_\(df.string(from: self.roughnessAmount as NSNumber)!)"
        url.appendPathComponent(filename)
        
        let jsonObject = self.asJSONObject(withImageFilePath: imagePath)
        let data = try PropertyListSerialization.data(fromPropertyList: jsonObject, format: .xml, options: 0)
        try data.write(to: url)
        Logger.log("\(url) saved")
    }
    
    static func loadSavedBatch() throws -> [SortParam] {
        let dirURL = try self.savedBatchedDIRURL()
        let urls = try FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: [], options: [.skipsHiddenFiles])
        var results = [SortParam]()
        urls.forEach { (url) in
            
            do {
                let data = try Data(contentsOf: url)
                let object = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
                var sp = SortParam.sortParam(withJSONObject: object as! [String : AnyObject])
                sp.batch_fileURL = url
                results.append(sp)
            }catch {
                Logger.log("\(error)")
                try! FileManager.default.removeItem(at: url)
            }
            
        }
        
        return results
    }
    
}

extension String {
    func imageFromPath () -> UIImage? {
        //FIXME return real photo from the path
        return AppConfig.shared.lastImage
    }
}

class Batch: NSObject {
    
    //MARK - batching
    func processBatch(withMaxpixel mp: AppConfig.MaxSize, progress:@escaping (Float)->Void, aborted: ()->Bool, completion:@escaping ()->Void) throws {
        let toProcess = try SortParam.loadSavedBatch()
        let totals = toProcess.count
        var doneCount = 0
        let qos = DispatchQoS(qosClass: .userInteractive, relativePriority: 0)
        let serial_q = DispatchQueue(label: "th.co.bluedot.pixels0rtr", qos: qos, attributes: [], autoreleaseFrequency: .inherit, target: nil)
        
        toProcess.forEach { (sp0) in
            serial_q.sync {
                
                var sp = sp0
                sp.maxPixels = mp
                if let image = sp.imagePath?.imageFromPath(),
                    let resizedSize = image.resize(toFitMaxPixels: mp){
                    
                    let pxs = PixelSorting(withSortParam: sp, imageToSort: resizedSize)
                    
                    pxs.start(withProgress: { (p) in
                        progress(p)
                    }, aborted: aborted, completion: { (image, stats) in
                        if let image = image {
                            PHPhotoLibrary.shared().savePhoto(image: image, albumName: ALBUM_NAME, completion: { (asset) in
                                Logger.log("saved \(asset?.location)")
                            })
                        }
                        doneCount = doneCount.advanced(by: 1)
                        //progress(Float(doneCount)/Float(totals))
                        
                        if doneCount == totals {
                            completion()
                        }
                    })
                }
                
            }
        }
    }
    
   
    
    //#MARK: - singleton
    static let shared: Batch = {
        let instance = Batch()
        // setup code
        return instance
    }()

}


class BatchListTableViewController: UITableViewController {
    
    var params: [SortParam] = []
    var progressView: UIProgressView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.progressView = UIProgressView(progressViewStyle: .default)
        self.progressView.tintColor = UIColor.green
        if let navBar = self.navigationController?.navigationBar {
            self.progressView.frame = CGRect(x: 0, y: navBar.bounds.height - 2, width: self.view.bounds.width, height: 2)
            navBar.addSubview(self.progressView)
        }
        
        let runButton = UIBarButtonItem(title: "Run", style: .plain, target: self, action: #selector(runBatch))
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearBatch))
        self.navigationItem.rightBarButtonItems = [clearButton, runButton]
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CELLID")
        self.updateList()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.progressView.removeFromSuperview()
    }
    
    func updateList() {
        do {
            try self.params = SortParam.loadSavedBatch()
            
            self.tableView.reloadData()
            
            
        } catch {
            Logger.log("\(error)")
        }
    }
    
    fileprivate func chooseMaxSize(withCompletion competion: @escaping (AppConfig.MaxSize)->Void){
        let ctrl = UIAlertController(title: "", message: "Select Size", preferredStyle: .actionSheet)
        
        AppConfig.MaxSize.ALL_SIZES.forEach { (mp) in
            ctrl.addAction(UIAlertAction(title: mp.description, style: .default, handler: { (ac) in
                competion(mp)
            }))
        }
        self.present(ctrl, animated: true, completion: nil)
    }
    
    func clearBatch() {
        do {
            try SortParam.clearBatch()
        }catch {
            Logger.log("\(error)")
        }
        
        self.updateList()
    }
    
    func runBatch () {
        
        if self.params.count == 0 {
            return
        }
        UIApplication.shared.isIdleTimerDisabled = true
        self.chooseMaxSize { (maxSize) in
            self.progressView.setProgress(0.1, animated: true)
            DispatchQueue.global(qos: .userInteractive).async {
                
                do {
                    
                    try Batch.shared.processBatch(withMaxpixel: maxSize, progress: { (progress) in
                        DispatchQueue.main.async {
                            self.progressView.setProgress(progress, animated: true)
                        }
                        
                    }, aborted: { () -> Bool in
                        return false
                    }) {
                        do {
                            try SortParam.clearBatch()
                        }catch {
                            Logger.log("\(error)")
                        }
                        
                        self.updateList()
                        UIApplication.shared.isIdleTimerDisabled = false
                    }
                }catch {
                    Logger.log("\(error)")
                }
            }
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.params.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELLID", for: indexPath)
        
        let sp = self.params[indexPath.row]
        
        cell.textLabel?.minimumScaleFactor = 0.5
        cell.textLabel?.lineBreakMode = .byTruncatingTail
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = sp.batch_fileURL?.lastPathComponent ?? "unknown"
        
        return cell
    }
    
}

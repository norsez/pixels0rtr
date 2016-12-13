//
//  VerticalSelectorViewController.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/13/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
typealias SelectableItem = (name: String, image: UIImage?)
class VerticalSelectorViewController: UITableViewController {
    
    let COLOR_TEXT = UIColor(red: 0, green: 1, blue: 0, alpha: 0.9)
    let FONT_TEXT = UIFont(name: "Silom", size: 16)!
    let CELLID = "CellId"
    var items = [SelectableItem]()
    var didSelectItem: ((Int, SelectableItem)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.tableView.separatorColor = UIColor.clear
        
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func attributedText(withText txt: String) -> NSAttributedString {
        let astr = NSAttributedString(string: txt, attributes: [NSForegroundColorAttributeName: COLOR_TEXT,NSFontAttributeName: FONT_TEXT])
        return astr
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: CELLID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: CELLID)
        }

        let item = self.items[indexPath.row]
        cell?.textLabel?.attributedText = self.attributedText(withText: item.name)
        if let image = item.image {
            cell?.imageView?.image = image
        }

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let c = self.didSelectItem {
            c(indexPath.row, self.items[indexPath.row])
        }
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

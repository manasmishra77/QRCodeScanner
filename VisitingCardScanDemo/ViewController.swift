//
//  ViewController.swift
//  VisitingCardScanDemo
//
//  Created by Manas Mishra on 28/06/17.
//  Copyright © 2017 Manas Mishra. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var addNewButton: UIBarButtonItem!
    @IBOutlet weak var scanDetailTable: UITableView!
    
    var availableContacts = [[String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scanDetailTable.delegate = self
        scanDetailTable.dataSource = self
        if let contactArray = UserDefaults.standard.object(forKey: "ContactArray"){
            if let contacts = contactArray as? [[String: String]]{
                availableContacts = contacts
                scanDetailTable.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableContacts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VisitingCardTableViewCell", for: indexPath) as! VisitingCardTableViewCell
        let contact = availableContacts[indexPath.row]
        cell.at.text = contact["at"]
        var company = ""
        var title  = ""
        if let newComp = contact["company"]{
            company = newComp
        }
        if let newTitle = contact["title"]{
            title = newTitle
        }
        cell.designation.text = title + "," + company
        cell.name.text = contact["name"]
        cell.contactNumber.text = contact["contact"]
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addNew(_ sender: UIBarButtonItem) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ScanDetailViewController") as! ScanDetailViewController
        navigationController?.pushViewController(vc, animated: true)
    }

}


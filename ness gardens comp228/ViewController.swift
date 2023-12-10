//
//  ViewController.swift
//  ness gardens comp228
//
//  Created by Lewis, Henry on 10/12/2023.
//

import UIKit
import MapKit

struct PlantResponse: Codable{
    var plants: [Plant]
}

struct Plant: Codable{
    var recnum: String?
    var acid: String?
    var accsta: String?
    var family: String?
    var genus: String?
    var species: String?
    var infraspecific_epithet: String?
    var vernacular_name: String?
    var cultivar_name: String?
    var donor: String?
    var latitude: String?
    var longitude: String?
    var country: String?
    var iso: String?
    var sgu: String?
    var loc: String?
    var alt: String?
    var cnam: String?
    var cid: String?
    var cdat: String?
    var bed: String?
    var memoriam: String?
    var redlist: String?
    var last_modified: String?
    
}

struct BedResponse: Codable{
    var beds: [Bed]
}

struct Bed: Codable{
    var bed_id: String
    var name: String
    var latitude: String
    var longitude: String
    var last_modified: String
    
    
}



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var bedsArray = [Bed]()
    var plantsArray = [Plant]()
    var thumbnailArray = [String: UIImage]()
    var bedPlants = [String: String]()
    
    var selectedPlant = Plant()
                 
    @IBOutlet weak var bedMap: MKMapView!
    @IBOutlet weak var bedTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let plantsInBed = plantsArray.filter{$0.bed == bedsArray[section].bed_id}
        
        var plants = ""
        
        for element in plantsInBed{
            plants += "\(element.recnum!) "
        }
        
        bedPlants[bedsArray[section].name] = plants
        
        return plantsInBed.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return bedsArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return bedsArray[section].name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let plant = bedPlants[bedsArray[indexPath.section].name]!.components(separatedBy: .whitespaces)
        selectedPlant = plantsArray.first(where: {$0.recnum == plant[indexPath.row]})!
     
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail"{
            let nextVC = segue.destination as! detailsViewController
            nextVC.plantDetails = selectedPlant
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! PlantTableViewCell
        var content = UIListContentConfiguration.cell()
        
        let plant = bedPlants[bedsArray[indexPath.section].name]!.components(separatedBy: .whitespaces)
        let plantInfo = plantsArray.first(where: {$0.recnum == plant[indexPath.row]})
        
        
        aCell.familyLabel?.text = "Family: \(plantInfo?.family ?? "no family name on record")"
        aCell.genusLabel?.text = "Genus: \(plantInfo?.genus ?? "no genus name on record")"
        aCell.speciesLabel?.text = "Species: \(plantInfo!.species ?? "no species name on record")"
        
        aCell.thumbnailImage?.image = thumbnailArray[(plantInfo?.recnum)!]
        
        aCell.accessoryType = .disclosureIndicator
        
        return aCell
    }
    
    @IBAction func unwindToFirstVC(_ unwindSegue: UIStoryboardSegue){
        let _ = unwindSegue.source
    }
    
    
    func updateBeds() async{
        let bedURL = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=beds")!
        let plantURL = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=plants")!
        
        do{
            let jsonDecoder = JSONDecoder()
            
            var (data,_) = try await URLSession.shared.data(from: plantURL)
            do{
                plantsArray = []
            
                let result = try jsonDecoder.decode(PlantResponse.self, from: data)
            
                plantsArray = result.plants.filter{$0.accsta == "C"}
          
            }
            catch DecodingError.keyNotFound(let key, _){print("plant key: \(key) not found ")}
            catch DecodingError.valueNotFound(let value, _){print("plant value: \(value) not found")}
        
            (data,_) = try await URLSession.shared.data(from: bedURL)
            do{
                bedsArray = []
                
                let result = try jsonDecoder.decode(BedResponse.self, from: data)
                
                bedsArray = result.beds.filter {element in plantsArray.contains{$0.bed == element.bed_id}}
                
            }
            catch DecodingError.keyNotFound(let key, _){print("bed key: \(key) not found ")}
            catch DecodingError.valueNotFound(let value, _){print("bed value: \(value) not found")}
            
      
            
        }
        catch{print("invalid data")}
        

        
        bedTable.reloadData()
    }
    
    @IBAction func button(_ sender: Any) {
        Task { @MainActor in
            await updateBeds()
            //print(plantsArray)
        }
    }
    
    override func viewDidLoad(){

        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task {
            await updateBeds()
        }
    }


}

class PlantTableViewCell: UITableViewCell{
    
    @IBOutlet weak var familyLabel: UILabel!
    @IBOutlet weak var genusLabel: UILabel!
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
}

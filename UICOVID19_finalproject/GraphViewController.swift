//
//  GraphViewController.swift
//  UICOVID19_finalproject
//
//  Created by Declan Burke on 5/14/20.
//  Copyright © 2020 group19. All rights reserved.
//

import UIKit

var casesArrayX: [String] = []
var casesArrayY: [Int] = []


class GraphViewController: UIViewController {

    @IBOutlet weak var casesLabelX: UILabel!
    @IBOutlet weak var deathsLabelX: UILabel!
    @IBOutlet weak var casesStackX: UIStackView!

    @IBOutlet weak var maxLabelCases: UILabel!
    
    @IBOutlet weak var casesMidLabel: UILabel!
    @IBOutlet weak var deathMidLabel: UILabel!
    @IBOutlet weak var maxLabelDeaths: UILabel!
    @IBOutlet weak var casesView: GraphViewCases!
    
    @IBOutlet weak var deathsView: GraphViewDeaths!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let casesMid = (graphPointsCases.last!/2)
        let deathsMid = (graphPointsDeaths.last!/2)
        
        casesView.layer.shadowColor = UIColor.black.cgColor
        casesView.layer.shadowOpacity = 1
        casesView.layer.shadowOffset = .zero
        casesView.layer.shadowRadius = 5
        
        deathsView.layer.shadowColor = UIColor.black.cgColor
        deathsView.layer.shadowOpacity = 1
        deathsView.layer.shadowOffset = .zero
        deathsView.layer.shadowRadius = 5
        
        
        if (graphPointsCases.count == 7) {
            casesLabelX.text = casesArrayX.joined(separator: "    ")
            deathsLabelX.text = casesArrayX.joined(separator: "    ")
            deathMidLabel.text = String(deathsMid)
            casesMidLabel.text = String(casesMid)
            maxLabelCases.text = graphPointsCases.last.map {
                (number: Int) -> String in
                return String(number)
            }
            maxLabelDeaths.text = graphPointsDeaths.last.map {
                (number: Int) -> String in
                return String(number)
            }
        }
        if (graphPointsCases.count == 30) {
            casesLabelX.text = casesArrayX.joined(separator: "    ")
            deathsLabelX.text = casesArrayX.joined(separator: "    ")
            deathMidLabel.text = String(deathsMid)
            casesMidLabel.text = String(casesMid)
            maxLabelCases.text = graphPointsCases.last.map {
                (number: Int) -> String in
                return String(number)
            }
            maxLabelDeaths.text = graphPointsDeaths.last.map {
                (number: Int) -> String in
                return String(number)
            }
        }
        
        

        // Do any additional setup after loading the view.
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

//
//  GraphView.swift
//  UICOVID19_finalproject
//
//  Created by Declan Burke on 4/28/20.
//  Copyright © 2020 group19. All rights reserved.
//

import UIKit

var graphPointsCases: [Int] = [0,1,2,3,4]


@IBDesignable class GraphViewCases: UIView {
    
    private struct Constants {
      static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
      static let margin: CGFloat = 20.0
      static let topBorder: CGFloat = 60
      static let bottomBorder: CGFloat = 50
      static let colorAlpha: CGFloat = 0.3
      static let circleDiameter: CGFloat = 5.0
    }
    
    
    
    @IBInspectable var startColor: UIColor = .blue
    @IBInspectable var endColor: UIColor = .green
    
    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        
    let path = UIBezierPath(roundedRect: rect,
                          byRoundingCorners: .allCorners,
                                cornerRadii: Constants.cornerRadiusSize)
        path.addClip()
      
      // 2
      let context = UIGraphicsGetCurrentContext()!
      let colors = [startColor.cgColor, endColor.cgColor]
      
      // 3
      let colorSpace = CGColorSpaceCreateDeviceRGB()
      
      // 4
      let colorLocations: [CGFloat] = [0.0, 1.0]
      
      // 5
      let gradient = CGGradient(colorsSpace: colorSpace,
                                     colors: colors as CFArray,
                                  locations: colorLocations)!
      
      // 6
      let startPoint = CGPoint.zero
      let endPoint = CGPoint(x: 0, y: bounds.height)
      context.drawLinearGradient(gradient,
                          start: startPoint,
                            end: endPoint,
                        options: [])
        //calculate the x point
            
        let margin = Constants.margin
        let graphWidth = width - margin * 2 - 4
        let columnXPoint = { (column: Int) -> CGFloat in
          //Calculate the gap between points
          let spacing = graphWidth / CGFloat(graphPointsCases.count - 1)
          return CGFloat(column) * spacing + margin + 2
        }
        // calculate the y point
            
        let topBorder = Constants.topBorder
        let bottomBorder = Constants.bottomBorder
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = graphPointsCases.max()!
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
          let y = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
          return graphHeight + topBorder - y // Flip the graph
        }
        // draw the line graph

        UIColor.white.setFill()
        UIColor.white.setStroke()
            
        // set up the points line
        let graphPath = UIBezierPath()

        // go to start of line
        graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(graphPointsCases[0])))
            
        // add points for each item in the graphPoints array
        // at the correct (x, y) for the point
        for i in 1..<graphPointsCases.count {
          let nextPoint = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPointsCases[i]))
          graphPath.addLine(to: nextPoint)
        }
        //Create the clipping path for the graph gradient

        //1 - save the state of the context (commented out for now)
        context.saveGState()
            
        //2 - make a copy of the path
        let clippingPath = graphPath.copy() as! UIBezierPath
            
        //3 - add lines to the copied path to complete the clip area
        clippingPath.addLine(to: CGPoint(x: columnXPoint(graphPointsCases.count - 1), y:height))
        clippingPath.addLine(to: CGPoint(x:columnXPoint(0), y:height))
        clippingPath.close()
            
        //4 - add the clipping path to the context
        clippingPath.addClip()
            
        let highestYPoint = columnYPoint(maxValue)
        let graphStartPoint = CGPoint(x: margin, y: highestYPoint)
        let graphEndPoint = CGPoint(x: margin, y: bounds.height)
                
        context.drawLinearGradient(gradient, start: graphStartPoint, end: graphEndPoint, options: [])
        context.restoreGState()
        //draw the line on top of the clipped gradient
        graphPath.lineWidth = 2.0
        graphPath.stroke()
        //Draw the circles on top of the graph stroke
        for i in 0..<graphPointsCases.count {
          var point = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPointsCases[i]))
          point.x -= Constants.circleDiameter / 2
          point.y -= Constants.circleDiameter / 2
              
          let circle = UIBezierPath(ovalIn: CGRect(origin: point, size: CGSize(width: Constants.circleDiameter, height: Constants.circleDiameter)))
          circle.fill()
        }
        //Draw horizontal graph lines on the top of everything
        let linePath = UIBezierPath()

        //top line
        linePath.move(to: CGPoint(x: margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: topBorder))

        //center line
        linePath.move(to: CGPoint(x: margin, y: graphHeight/2 + topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: graphHeight/2 + topBorder))

        //bottom line
        linePath.move(to: CGPoint(x: margin, y:height - bottomBorder))
        linePath.addLine(to: CGPoint(x:  width - margin, y: height - bottomBorder))
        let color = UIColor(white: 1.0, alpha: Constants.colorAlpha)
        color.setStroke()
            
        linePath.lineWidth = 1.0
        linePath.stroke()
        

    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

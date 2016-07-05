//
//  GridNode.swift
//  LiquidHazard
//
//  Created by JJ Bolin on 2016-07-05.
//  Copyright © 2016 White Widget Limited. All rights reserved.
//

import Foundation


class Node  {
    // WorldLocation
    //Radius or width and height
    //
    
    
    var gridx : Int
    var gridy : Int
    var NodeSize : Size2D
    
    
    init(gridx : Int, gridy : Int, NodeSize : Size2D) {
        
        self.gridx = gridx
        self.gridy = gridy
        self.NodeSize = NodeSize
        
        
    }
    
    func gridLocation() -> Vector2D{
        
       return Vector2D(x:  Float(gridx) * NodeSize.width, y: Float(gridy) * NodeSize.height)
        
    }
    
    


}
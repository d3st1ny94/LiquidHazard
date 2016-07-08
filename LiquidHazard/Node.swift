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
    var Empty: Bool
    
    
    init(gridx : Int, gridy : Int, NodeSize : Size2D) {
        
        self.gridx = gridx
        self.gridy = gridy
        self.NodeSize = NodeSize
        Empty = false
        
        
    }
    
    func gridLocation() -> [Float]{
        let ret:[Float] =   [Float(gridx-1)*NodeSize.width, Float(gridy) * NodeSize.height, 0,
                            Float(gridx - 1)*NodeSize.width, Float(gridy - 1)*NodeSize.height, 0,
                            Float(gridx)*NodeSize.width, Float(gridy - 1)*NodeSize.height, 0,
                            Float(gridx)*NodeSize.width, Float(gridy)*NodeSize.height, 0]
        return ret
    }
    
    


}
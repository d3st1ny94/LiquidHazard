//
//  Grid.swift
//  LiquidHazard
//
//  Created by JJ Bolin on 2016-07-05.
//  Copyright © 2016 White Widget Limited. All rights reserved.
//

import Foundation

class Grid {
    
    var NumberOfCols : Int
    var NumberOfRows : Int
    var screenSize : Size2D
    var ptmRatio : Float
    var NodeGrid = Array<Array<Node>>()
    
    init(NumberOfCols : Int, NumberOfRows : Int, screenSize : Size2D, ptmRatio : Float) {
        self.NumberOfCols = NumberOfCols
        self.NumberOfRows = NumberOfRows
        self.screenSize = screenSize
        self.ptmRatio = ptmRatio
        let tempSize = Size2D(width: screenSize.width/Float(NumberOfCols), height: screenSize.height/Float(NumberOfRows))
    
        for y in 1...NumberOfRows
        {
            var _temp = Array<Node>()
            for x in 1...NumberOfCols
            {
                _temp.append(Node(gridx: x, gridy: y, NodeSize: tempSize))
            }
            
            NodeGrid.append(_temp)
        }
        
    } // end of forloop
    
    func getVertexData()-> [[Float]] {
        var ret = Array<Array<Float>>()
        
        for i in 1...NodeGrid.count
        {
            for e in 1...NodeGrid[i-1].count {
            ret.append(NodeGrid[i-1][e-1].gridLocation())
            }
        }
        return ret
    } // end of getVertexData
    
    } // end of Grid class
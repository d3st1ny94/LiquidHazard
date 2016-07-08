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
    var NumberOfNodes: Int
    var NodesOpen: Int
    var NodeStart: Node
    var NodeEnd: Node
    
    
    init(NumberOfCols : Int, NumberOfRows : Int, screenSize : Size2D, ptmRatio : Float) {
        self.NumberOfCols = NumberOfCols
        self.NumberOfRows = NumberOfRows
        self.screenSize = screenSize
        self.ptmRatio = ptmRatio
        
        let tempSize = Size2D(width: screenSize.width/Float(NumberOfCols), height: screenSize.height/Float(NumberOfRows))
        NumberOfNodes = NumberOfRows*NumberOfCols
        NodesOpen = 0
        for y in 1...NumberOfRows
        {
            var _temp = Array<Node>()
            for x in 1...NumberOfCols
            {
                _temp.append(Node(gridx: x, gridy: y, NodeSize: tempSize))
            }
            
            NodeGrid.append(_temp)
        }
        NodeStart = NodeGrid[0][0]
        NodeEnd = NodeGrid[0][0]
        
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
    
    func getNodeInDir(dir: UInt32, node:Node) -> Node? {
        switch dir {
        case 0:
            if node.gridy != 0{
                return getNodeAtIndex(node.gridx, Y: node.gridy-1)
            }
            return nil
            
        case 1:
            if node.gridy != NumberOfRows{
                return getNodeAtIndex(node.gridx, Y: node.gridy + 1)
            }
            return nil
        case 2:
            if node.gridx != 0{
                return getNodeAtIndex(node.gridx-1 , Y: node.gridy)
            }
            return nil
            
        case 3:
            if node.gridx != NumberOfCols{
                return getNodeAtIndex(node.gridx + 1, Y: node.gridy)
            }
            return nil
            
        default:
            return nil
            
        }
    }
    func drunkenPathGen() {
        
        
        // Select a random point on the grid and mark it empty
        let NodeRanX = Int(arc4random_uniform(UInt32(NumberOfCols)))
        let NodeRanY = Int(arc4random_uniform(UInt32(NumberOfRows)))
        
        
        NodeStart = getNodeAtIndex(NodeRanX, Y: NodeRanY)
        NodeStart.Empty = true
        NodesOpen += 1
        
        var temp = NodeStart
        let Percentage = Float(NumberOfNodes)/0.75
        
        while NodesOpen <= Int(floorf(Percentage)) {
            let direction = arc4random_uniform(4)
            let temp2:Node? = (getNodeInDir(direction, node: temp))
            if (temp2 != nil) {
                if temp2!.Empty == false{
                    temp = temp2!
                    temp.Empty = true
                    
                    
                    
                }
            }
            
        }
        
        NodeEnd = temp
        
    } // end of drunkenPathGen
    
    func getNodeAtIndex(X: Int, Y: Int) -> Node {
        
        return NodeGrid[Y-1][X-1]
}


}
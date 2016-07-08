//
//  ViewController.swift
//  LiquidHazard
//
//  Created by adan de la pena on 6/20/16.
//  Copyright © 2016 adan de la pena. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
  
  let gravity: Float = 9.80665
  let ptmRatio: Float = 64.0
  let particleRadius: Float = 5
  var particleSystem: UnsafeMutablePointer<Void>!
    var uniformBuffer: MTLBuffer! = nil
    let motionManager: CMMotionManager = CMMotionManager()
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    var vertexData:[Float] = []
    var particleCount: Int = 0
    var vertexBuffer: MTLBuffer! = nil
    var secondBuffer: MTLBuffer! = nil
    
    var GridMember: Grid?
    var gridData: [[Float]] = [[]]
    var pipelineGoalState: MTLRenderPipelineState! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var pipelineWallState: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var goalBuffer: MTLBuffer! = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    LiquidFun.createWorldWithGravity(Vector2D(x: 0, y: -gravity))
    particleSystem = LiquidFun.createParticleSystemWithRadius(particleRadius / ptmRatio, dampingStrength: 0.2, gravityScale: 1, density: 1.2)
    
    LiquidFun.setParticleLimitForSystem(particleSystem, maxParticles: 1500)
    
    let screenSize: CGSize = UIScreen.mainScreen().bounds.size
    let screenWidth = Float(screenSize.width)
    let screenHeight = Float(screenSize.height)
    
    LiquidFun.createParticleBoxForSystem(particleSystem, position: Vector2D(x: screenWidth * 0.5 / ptmRatio, y: screenHeight * 0.5 / ptmRatio), size: Size2D(width: 200 / ptmRatio, height: 200 / ptmRatio))
    
    LiquidFun.createEdgeBoxWithOrigin(Vector2D(x: 0, y: 0),
        size: Size2D(width: screenWidth / ptmRatio, height: screenHeight / ptmRatio))
    
    GridMember = Grid(NumberOfCols: 18, NumberOfRows: 12, screenSize: Size2D(width : screenWidth, height: screenHeight), ptmRatio: ptmRatio)
    LiquidFun.createGoalWithSizeAndOrigin(Size2D(width: 100 / ptmRatio, height: 100 / ptmRatio), origin: Vector2D(x: 0,y: 0))
     vertexData = [
        100.0, 100.0, 0.0,
        100.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        0.0, 100.0, 0.0]
    /*
     LiquidFun.createEdgeWithOrigin(Vector2D(x: 0, y: 0),
     destination: Vector2D(x: screenWidth / ptmRatio, y: screenHeight / ptmRatio))
 
    */
    createMetalLayer()
    gridData = (GridMember?.getVertexData())!
    refreshVertexBuffer()

    refreshUniformBuffer()
    buildRenderPipeline()
    render()
    
    let displayLink = CADisplayLink(target: self, selector: Selector("update:"))
    displayLink.frameInterval = 1
    displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)

    motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue(),
        withHandler: { (accelerometerData, error) -> Void in
            
            if let data = accelerometerData  {
                let acceleration = data.acceleration
                let gravityX = self.gravity * Float(acceleration.x)
                let gravityY = self.gravity * Float(acceleration.y)
                LiquidFun.setGravity(Vector2D(x: gravityX, y: gravityY))
            }
    })
  }
    func yodatime(vData: [Float]) -> MTLBuffer {
        let vSize = vData.count * sizeofValue(vData[0])
        let ret:MTLBuffer? = device?.newBufferWithBytes(vData, length: vSize, options: [])
        return ret!
    }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

    func update(displayLink:CADisplayLink) {
        autoreleasepool {
            LiquidFun.worldStep(displayLink.duration, velocityIterations: 8, positionIterations: 3)
            self.refreshVertexBuffer()
            self.render()
        }
    }
    
    func createMetalLayer() {
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
    }

    func refreshVertexBuffer () {
        particleCount = Int(LiquidFun.particleCountForSystem(particleSystem))
        let positions = LiquidFun.particlePositionsForSystem(particleSystem)
        let bufferSize = sizeof(Float) * particleCount * 2
        vertexBuffer = device.newBufferWithBytes(positions, length: bufferSize, options: [])
    }
    
    func makeOrthographicMatrix(left left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> [Float] {
        let ral = right + left
        let rsl = right - left
        let tab = top + bottom
        let tsb = top - bottom
        let fan = far + near
        let fsn = far - near
        
        return [2.0 / rsl, 0.0, 0.0, 0.0,
            0.0, 2.0 / tsb, 0.0, 0.0,
            0.0, 0.0, -2.0 / fsn, 0.0,
            -ral / rsl, -tab / tsb, -fan / fsn, 1.0]
    }
    
  func printParticleInfo() {
    let count = Int(LiquidFun.particleCountForSystem(particleSystem))
    print("There are \(count) particles present")
    
    let positions = UnsafePointer<Vector2D>(LiquidFun.particlePositionsForSystem(particleSystem))
    
    for i in 0..<count {
      let position = positions[i]
      print("particle: \(i) position: (\(position.x), \(position.y))")
    }
  }
    
    func refreshUniformBuffer () {
        // 1
        let screenSize: CGSize = UIScreen.mainScreen().bounds.size
        let screenWidth = Float(screenSize.width)
        let screenHeight = Float(screenSize.height)
        let ndcMatrix = makeOrthographicMatrix(left: 0, right: screenWidth,
            bottom: 0, top: screenHeight,
            near: -1, far: 1)
        var radius = particleRadius
        var ratio = ptmRatio
        
        // 2
        let floatSize = sizeof(Float)
        let float4x4ByteAlignment = floatSize * 4
        let float4x4Size = floatSize * 16
        let paddingBytesSize = float4x4ByteAlignment - floatSize * 2
        let uniformsStructSize = float4x4Size + floatSize * 2 + paddingBytesSize
        
        // 3
        uniformBuffer = device.newBufferWithLength(uniformsStructSize, options: [])
        let bufferPointer = uniformBuffer.contents()
        memcpy(bufferPointer, ndcMatrix, float4x4Size)
        memcpy(bufferPointer + float4x4Size, &ratio, floatSize)
        memcpy(bufferPointer + float4x4Size + floatSize, &radius, floatSize)
    }

    func buildRenderPipeline() {
        // 1
        let defaultLibrary = device.newDefaultLibrary()
        var fragmentProgram = defaultLibrary?.newFunctionWithName("basic_fragment")
        var vertexProgram = defaultLibrary?.newFunctionWithName("particle_vertex")
        
        // 2
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexProgram
        pipelineDescriptor.fragmentFunction = fragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        do {
            pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
        } catch {
            print("Error occurred when creating render pipeline state: \(error)");
        }
        fragmentProgram = defaultLibrary!.newFunctionWithName("wall_fragment")
        vertexProgram = defaultLibrary!.newFunctionWithName("basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        do{
            pipelineWallState = try device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        } catch {
            
        }
        fragmentProgram = defaultLibrary!.newFunctionWithName("goal_fragment")
        vertexProgram = defaultLibrary!.newFunctionWithName("basic_vertex")
        
        let pipelineStateDescriptor2 = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor2.vertexFunction = vertexProgram
        pipelineStateDescriptor2.fragmentFunction = fragmentProgram
        pipelineStateDescriptor2.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        do{
            pipelineGoalState = try device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor2)
        } catch {
            
        }
        
        
        
        // 3
        commandQueue = device.newCommandQueue()
    }
    
    func render() {
        
        if let drawable = metalLayer.nextDrawable()    {

            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].texture = drawable.texture
            renderPassDescriptor.colorAttachments[0].loadAction = .Clear
            renderPassDescriptor.colorAttachments[0].storeAction = .Store
            renderPassDescriptor.colorAttachments[0].clearColor =
                MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            
            let commandBuffer = commandQueue.commandBuffer()
            
            let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
            renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, atIndex: 1)
            if particleCount > 0 {
            renderEncoder.drawPrimitives(.Point, vertexStart: 0, vertexCount: particleCount, instanceCount: 1)
            }
            renderEncoder.setRenderPipelineState(pipelineWallState)
            for i in 1...gridData.count{
                secondBuffer = yodatime(gridData[i-1])
                renderEncoder.setVertexBuffer(secondBuffer, offset: 0, atIndex: 2)
                renderEncoder.drawPrimitives(.LineStrip, vertexStart: 0, vertexCount: 4)
            }
            renderEncoder.setRenderPipelineState(pipelineGoalState)
            goalBuffer = yodatime(vertexData)
            renderEncoder.setVertexBuffer(goalBuffer, offset: 0, atIndex: 2)
            renderEncoder.drawPrimitives(.TriangleStrip, vertexStart: 0, vertexCount: 4)
            renderEncoder.endEncoding()
            
            
            commandBuffer.presentDrawable(drawable)
            commandBuffer.commit()
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInView(view)
            let position = Vector2D(x: Float(touchLocation.x) / ptmRatio,
                y: Float(view.bounds.height - touchLocation.y) / ptmRatio)
            let size = Size2D(width: 100 / ptmRatio, height: 100 / ptmRatio)
            LiquidFun.createParticleBoxForSystem(particleSystem, position: position, size: size)
        }
        super.touchesBegan(touches, withEvent:event)
    }
}


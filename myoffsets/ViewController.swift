//
//  ViewController.swift
//  myoffsets
//
//  Created by Davis Michael J (ISG-K) on 2017-07-12.
//  Copyright © 2017 John Deere. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addPointButton: UIButton!
    @IBOutlet weak var resetPointsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        camera_node = sceneView.pointOfView!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @IBOutlet weak var targetingReticle: UIImageView!
    
    var allAnchors: [ARAnchor] = []
    var allNodes: [SCNNode] = []
    var allLines: [MOFLine] = []
    
    var camera_node: SCNNode? = nil
    
    @IBAction func addReferencePoint() {
        print("push add button")
        let hits = sceneView.hitTest(targetingReticle.center,
                                     types: [ARHitTestResult.ResultType.featurePoint])
        print(hits)
        if hits.count > 0 {
            let detectedPointAnchor = ARAnchor(transform: hits[0].worldTransform)
            sceneView.session.add(anchor: detectedPointAnchor)
            allAnchors.append(detectedPointAnchor)
            
            
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            print("added node for anchor")
            let sphere = SCNSphere(radius: 0.01)
            sphere.firstMaterial?.diffuse.contents = UIColor.yellow
            let sphereNode = SCNNode(geometry: sphere)
            node.addChildNode(sphereNode)
            self.allNodes.append(node)
            if self.allNodes.count > 1 {
                self.allLines.append(MOFLine(fromNode: node, toNode: self.allNodes[self.allNodes.count - 2], cameraNode: self.camera_node!))
            }
        }
    }
    
    @IBAction func clearNodes() {
        for anchor in allAnchors {
            sceneView.session.remove(anchor: anchor)
        }
        allAnchors = []
        allLines = []
        allNodes = []
    }
    
    class   MOFLine: SCNNode
    {
        init(fromNode: SCNNode, toNode: SCNNode, cameraNode: SCNNode)
        {
            super.init()
            let length = distance(fromNode.simdWorldPosition,
                                  toNode.simdWorldPosition)
            print(length)
            let line = SCNCapsule(capRadius: 0.005, height: CGFloat(length))
            line.firstMaterial?.diffuse.contents = UIColor.green
            
            let label = SCNText(string: String(format:"%\(0.2)f m", length),extrusionDepth: 0.5)
            let labelNode = SCNNode(geometry: label)
            labelNode.scale = SCNVector3(0.003, 0.003, 0.003)
//            labelNode.position.z = -0.1
//            labelNode.eulerAngles.z = Float.pi/2
//            labelNode.eulerAngles.y = Float.pi
            let labelLooker = SCNNode()
            labelLooker.addChildNode(labelNode)
            labelLooker.constraints = [SCNBillboardConstraint()]
//            labelLooker.constraints = [SCNLookAtConstraint(target: cameraNode)]
            let lineNode = SCNNode(geometry: line)
            
            lineNode.addChildNode(labelLooker)
            lineNode.position.z = -length/2
            lineNode.eulerAngles.x = Float.pi/2
            
            
            labelNode.position.z = 0.01
            
            self.addChildNode(lineNode)
            
            constraints = [SCNLookAtConstraint(target: toNode)]
            
            fromNode.addChildNode(self)
        }
        required init?(coder aDecoder: NSCoder) {
            super.init()
        }
    }
    
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

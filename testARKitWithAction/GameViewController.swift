//
//  GameViewController.swift
//  testARKitWithAction
//
//  Created by gwh on 2019/7/8.
//  Copyright © 2019 gwh. All rights reserved.
//
/*
 DispatchQueue.main.async { // Correct
 
 }
 */


import UIKit
import QuartzCore
import SceneKit
import ARKit

class GameViewController: UIViewController {
    
    var sceneView: ARSCNView!//scene
    var planeNode: SCNReferenceNode!//a plane model

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView=ARSCNView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        self.view.addSubview(sceneView)

        guard  let url = Bundle.main.url(forResource: "art.scnassets/ship", withExtension: "scn") else {
            fatalError("ship.scn not exit.")
        }

        let v:Float=0.03
        planeNode=SCNReferenceNode(url: url)
        planeNode.load()
        planeNode.scale=SCNVector3Make(v, v, v)
        planeNode.name="abc"

        DispatchQueue.main.async {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal]
            self.sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        }

        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView

        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = sceneView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]

            // get its material
            let material = result.node.geometry!.firstMaterial!

            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5

            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5

                material.emission.contents = UIColor.black

                SCNTransaction.commit()
            }

            material.emission.contents = UIColor.red

            SCNTransaction.commit()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch=touches.first!
        let point=touch.location(in: sceneView)
        let hitResult=sceneView.hitTest(point, options: nil)
        for hit in hitResult {
            let node=hit.node
            if node.name=="shipMesh"{
                NSLog("tapped")
                let rotation=SCNAction.rotate(by: 3, around: SCNVector3Make(0, 1, 0), duration: 2)
                let moveUp=SCNAction.move(by: SCNVector3Make(0, 5, 0), duration: 2)
                let group=SCNAction.group([rotation,moveUp])
                node.runAction(group)
            }
            if node==planeNode{
                print("find plane")
                let rotation=SCNAction.rotate(by: 10, around: SCNVector3Make(0, 1, 0), duration: 3)
                node.runAction(rotation)
            }
        }
        if self.view.layer.contains(point){
            NSLog("%d", point.x)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        let nodes=self.planeNode.childNodes
        for node in nodes {
            node.removeAllActions()
        }
        self.planeNode.removeAllActions()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}

extension GameViewController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        print("-----------------------> session did add anchor!")
        
        node.addChildNode(planeNode)

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        node.addChildNode(lightNode)

        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        node.addChildNode(ambientLightNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
}

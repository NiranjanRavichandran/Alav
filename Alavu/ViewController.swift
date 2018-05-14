//
//  ViewController.swift
//  Alavu
//
//  Created by Niranjan Ravichandran on 5/13/18.
//  Copyright © 2018 Aviato. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var nodes: [SphereNode] = []
    
    lazy var sceneView: ARSCNView = {
        let view = ARSCNView(frame: CGRect.zero)
        view.delegate = self
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = .multisampling4X
        return view
    }()
    
//    lazy var infoLabel: UILabel = {
//        let label = UILabel(frame: CGRect.zero)
//        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
//        label.textAlignment = .center
//        label.backgroundColor = .white
//        return label
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(sceneView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        tapGesture.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGesture)
        
        self.title = "Distance: 0.0 meters"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        sceneView.frame = self.view.bounds
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    //MARK: - Gesture handlers
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(tapLocation, types: .featurePoint)
        
        if let result = hitResults.first {
            let position = SCNVector3.positionFrom(matrix: result.worldTransform)
            
            let sphere = SphereNode.init(position: position)
            sceneView.scene.rootNode.addChildNode(sphere)
            
            let lastNode = nodes.last
            nodes.append(sphere)
            if lastNode != nil {
                let distance = lastNode!.position.distance(to: sphere.position)
                self.title = String(format: "Distance: %.2f meters", distance)
            }
            
            
        }
    }


    //MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        var status = "Loading..."
        
        switch camera.trackingState {
        case .notAvailable:
            status = "Not available"
        case .limited(_):
            status = "Analyzing..."
        case .normal:
            status = "Ready"
        }
        
        self.navigationItem.prompt = status
        
        if status == "Ready" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.navigationItem.prompt = nil
            }
        }
    }
}


extension SCNVector3 {
    func distance(to destination: SCNVector3) -> CGFloat {
        let dx = destination.x - x
        let dy = destination.y - y
        let dz = destination.z - z
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
    
    static func positionFrom(matrix: matrix_float4x4) -> SCNVector3 {
        let column = matrix.columns.3
        return SCNVector3(column.x, column.y, column.z)
    }
}

//MARK: - SpehereNode

class SphereNode: SCNNode {
    init(position: SCNVector3) {
        super.init()
        let sphereGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.lightingModel = .physicallyBased
        sphereGeometry.materials = [material]
        self.geometry = sphereGeometry
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


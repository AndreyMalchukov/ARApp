import UIKit
import ARKit
import GLTFSceneKit

class ViewController: UIViewController {
    
    @IBOutlet weak var arSceneView: ARSCNView!
    
    // Инициализируем ARSession и ARReferenceImage, используемый для отслеживания изображения
    var arSession: ARSession!
    var image: ARReferenceImage?
    
    // Создаем узел SCNNode для загрузки 3D-модели
    private var glbNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // Настройка ARSession и ARImageTrackingConfiguration
    private func setupAR() {
        let configuration = ARImageTrackingConfiguration()
        
    // Загружаем изображение для отслеживания
        let imageUrl = URL(string: "https://user74522.clients-cdnnow.ru/static/uploads/mrk6440mark.png")!
        let urlSession = URLSession.shared
        
        let task = urlSession.dataTask(with: imageUrl) { [weak self] (data, response, error) in
            guard let self = self, let imageData = data, error == nil else {
                print("Error loading image")
                return
            }
            
            DispatchQueue.main.async {
                self.image = ARReferenceImage(UIImage(data: imageData)!.cgImage!, orientation: .up, physicalWidth: 0.1)
                configuration.trackingImages = [self.image!]
                self.arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            }
        }
        task.resume()
        
    // Инициализируем ARSession
        self.arSession = ARSession()
        arSceneView.session = arSession
        
    // Назначаем делегата ARSCNViewDelegate для отслеживания событий ARSession
        arSceneView.delegate = self
    }
    
    // Загрузка 3D-модели из файла GLB
    private func setup3DNode() {
        if self.glbNode == nil {
            guard let url = URL(string: "https://user74522.clients-cdnnow.ru/static/uploads/mrk6564obj.glb") else {
                print("Invalid URL")
                return
            }
            do {
                let sceneSource = GLTFSceneSource(url: url)
                let scene = try sceneSource.scene()
                self.glbNode = scene.rootNode
                
    // Настраиваем масштаб и поворот 3D-модели
                self.glbNode.scale = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
                self.glbNode.eulerAngles.z = -.pi / 2
                self.glbNode.eulerAngles.x = -.pi / 2
                
    // Добавляем анимацию вращения 3D-модели
                let rotationAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(1 * Double.pi), duration: 5))
                self.glbNode.runAction(rotationAction)
            } catch {
                print("\(error.localizedDescription)")
                return
            }
        }
    }
}
extension ViewController: ARSCNViewDelegate {
    
    // Метод делегата, вызываемый при обнаружении нового якоря
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    // Приводим anchor к ARImageAnchor, чтобы использовать его для отслеживания изображения
        guard let anchor = anchor as? ARImageAnchor else { return }
        
    // Если изображение отслеживается, загружаем 3D-модель и добавляем ее на сцену
        if anchor.isTracked == true {
            setup3DNode()
            
    // Устанавливаем позицию 3D-модели
            self.glbNode.position = SCNVector3(x: self.glbNode.position.x,
                                               y: self.glbNode.position.y,
                                               z: self.glbNode.position.z + 0.05)
    // Добавляем 3D-модель на сцену
            node.addChildNode(self.glbNode)
        }
    }
}



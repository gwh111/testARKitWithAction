ARKit和SceneKit实现3D模型交互

这篇文章讲的是如何把AR模型添加到增强现实中，以及添加一些和用户的点击交互。
<img src="https://img-blog.csdnimg.cn/20190708164238442.jpg" width="500">

# ARKit&SceneKit
iOS 11引入了ARKit，这是一个新框架，可以让你在iPhone和iPad上轻松体验增强现实。 ARKit将应用程序超越屏幕，将它们以全新的方式与现实世界进行交互。

ARKit并不是一个独立就能够运行的框架，而是必须要SceneKit一起用才可以

ARKit：对真实世界的理解和追踪
SceneKit：3D AR世界的渲染以及用户和3D世界的交互

![img1](https://img-blog.csdnimg.cn/20190708164427623.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2d3aDExMQ==,size_16,color_FFFFFF,t_70)
图片来自https://blog.csdn.net/aa841538513/article/details/78196601

ARKit 提供了两个主要功能；第一个是 3D 空间里的相机位置，第二个是水平面检测。前者的意思是，ARKit 假定用户的手机是在真实的 3D 空间里移动的摄像机，所以在任意位置放置 3D 虚拟对象都会锚定在真实 3D 空间中对应的点上。对于后者来说，ARKit 可以检测诸如桌子这样的水平面，然后就可以在上面放置对象。

那么 ARKit 是怎么做到的呢？这是一项叫做视觉惯性里程计（VIO）的技术。从摄像头帧画面中追踪运动是通过检测特征点实现的，也可以说是高对比度图像中的边缘点——就像蓝色花瓶和白色桌子之间的边缘。通过检测两帧画面间特征点的相对移动距离，就可以估算出设备在 3D 空间里的位置。所以如果用户面对一面缺少特征点的白墙，或者设备移动过快导致画面模糊，ARKit 都会无法正常工作。

![img2](https://img-blog.csdnimg.cn/20190708164437692.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2d3aDExMQ==,size_16,color_FFFFFF,t_70)
![img3](https://img-blog.csdnimg.cn/20190708164445608.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2d3aDExMQ==,size_16,color_FFFFFF,t_70)
图片来自https://www.jianshu.com/p/0a67582f201d

## 虚拟世界
### SCNScene
用SceneKit中的SCNScene构建虚拟3D世界，这种方式是苹果推荐使用的，因为ARKit中提供了很多便利方法可以供我们直接使用。例如，我们查看ARKit中负责呈现视图的ARSceneView定义不难发现，它是SCNView的子类。

### SCNCamera
SCNCamera 在 SCNScene 的工作模式如下图所示：
![img4](https://img-blog.csdnimg.cn/20190708164454435.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2d3aDExMQ==,size_16,color_FFFFFF,t_70)

## 捕获真实世界
### ARSession
ARSession 是一个单例，用来管理、配置整个AR体验的主要流程，它包括：

### 从设备的运动传感器读取数据
控制摄设备内置摄像头，利用AVCaptureSession捕获实时的图像
对捕获到的图像进行分析，并对外输出ARFrame实例
综合运动数据和图像分析结果，建立起真实世界和虚拟世界的对应关系

每一个基于ARKit的AR项目都需要一个ARSession对象。

### ARFrame
ARFrame实例是带有位置追踪信息（position-tracking information）的视频图像，对于ARFrame有以下三个要点：

正在运行的AR session会不断捕捉设备摄像头的视频帧。
对于每一帧，ARKit都会结合来自设备运动传感硬件的数据进行分析，以估算设备的实际位置
ARKit通过ARFrame向外传递当前帧的位置信息和图像参数

## 世界追踪
### ARWorldTrackingConfiguration
ARWorldTrackingConfiguration可以将虚拟世界和真实世界联系起来，这样当虚拟世界和真实世界同时渲染在屏幕上的时候，用户会产生虚拟内容是真实世界的一部分的错觉。

维护真实世界和虚拟世界的对应关系，我们还需要获取设备的移动信息。ARWorldTrackingConfiguration类从6个自由度（degrees of freedom）来追踪设备的运动：具体来说，三个旋转轴（滚动，俯仰和偏航）以及三个平移轴（在X，Y和Z中的移动）。
<img src="https://img-blog.csdnimg.cn/2019070816450965.png" width="300">

这种追踪可以给用户带来沉浸式的体验：虚拟世界的物体可以看起来与现实世界保持相同的位置，即使用户将设备倾斜到物体的上方或下方，或者移动设备以查看物体的侧面和背面。
![img6](https://img-blog.csdnimg.cn/20190708164543601.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2d3aDExMQ==,size_16,color_FFFFFF,t_70)
planeDetection
设置这个属性，可以指定是否检测当前摄像头捕获图像中的平面。

AROrientationTrackingConfiguration
![img7](https://img-blog.csdnimg.cn/20190708164551164.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2d3aDExMQ==,size_16,color_FFFFFF,t_70)

ARSCNViewDelegate
接收捕获的视频帧图像
处理内容更新

场景理解
平面检测（Plane detection）
碰撞测试（Hit-testing）
光照估计 （Lighting estimation）
![img8](https://img-blog.csdnimg.cn/2019070816460011.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2d3aDExMQ==,size_16,color_FFFFFF,t_70)
SceneKit负责rendering

# 制作demo
## 创建一个工程
![img10](https://img-blog.csdnimg.cn/20190708164616632.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2d3aDExMQ==,size_16,color_FFFFFF,t_70)
创建一个game工程或augmented工程（游戏或增强现实）。
![img11](https://img-blog.csdnimg.cn/20190708164628368.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2d3aDExMQ==,size_16,color_FFFFFF,t_70)
在technology任意选择spritekit或scenekit
创建完后会有模板的一些代码，可以直接运行查看效果。这个项目我们可以删除所有模板代码，后面会写我们用到的代码。
清理完毕后在 **GameViewController.swift** 中引用我们需要的库
需要使用到：
```
import UIKit
import QuartzCore
import SceneKit
import ARKit
```
## 声明成员变量
```
var sceneView: ARSCNView!//scene
var planeNode: SCNReferenceNode!//a plane model
```
一个场景，一个飞机模型（来自sceneKit的demo）。  
![img plane_model](https://img-blog.csdnimg.cn/2019070816463635.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2d3aDExMQ==,size_16,color_FFFFFF,t_70)
[更多3D模型可以查看](https://free3d.com/3d-models/)    



## 准备场景和模型
在viewDidLoad中准备场景和飞机模型，并使ARSCNView的场景run起来
```
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
```
## 设置ARSCNView代理
我们只用到了一个检测到水平面的代理，在检测到水平面后，添加飞机模型到场景。其他还有更新场景信息等可以自行使用。
```
extension GameViewController: ARSCNViewDelegate{

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        print("-----------------------> session did add anchor!")

        node.addChildNode(planeNode)
    }
}
```
![img plane1](https://img-blog.csdnimg.cn/20190708164659763.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2d3aDExMQ==,size_16,color_FFFFFF,t_70)

添加光源，模型看起来很平面是因为没有光源，我们添加一个全局光和环境光后：  
```
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
```
![img plane2](https://img-blog.csdnimg.cn/20190708164707988.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2d3aDExMQ==,size_16,color_FFFFFF,t_70)  
飞机变得更有立体感

## 添加交互
我们在touchesBegan中获取触摸对象，检测对象是我们的飞机模型，使用了一个动画组合来完成飞机起飞+旋转的动作。  
这里首先使用了 if node==planeNode 去判断是否是我们的飞机模型，但是失败了，获取的对象是一个SKNode，于是我更改了方法，使用了 node.name=="shipMesh" 的方法判断点击的是飞机模型。  
这里说一下 *SCNAction* 的组合模式，分为sequence和group，都是传入动作数组，他们的区别是：  
**sequence** 是序列，动画会依次执行，需要执行完前一个动画才执行下一个动画。
**group** 是动画组合，动画会同时执行，所有数组内的动画会一直开始执行。  
我们通过一个rotate和move动画完成飞机🛩边旋转边上升的动画。
```
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch=touches.first!
    let point=touch.location(in: sceneView)
    let hitResult=sceneView.hitTest(point, options: nil)
    for hit in hitResult {
        let node=hit.node
        if node==planeNode{
            print("find plane")
            let rotation=SCNAction.rotate(by: 10, around: SCNVector3Make(0, 1, 0), duration: 3)
            node.runAction(rotation)
        }
        if node.name=="shipMesh"{
            NSLog("tapped")
            let rotation=SCNAction.rotate(by: 3, around: SCNVector3Make(0, 1, 0), duration: 2)
            let moveUp=SCNAction.move(by: SCNVector3Make(0, 5, 0), duration: 2)
            let group=SCNAction.group([rotation,moveUp])
            node.runAction(group)
        }
    }
    if self.view.layer.contains(point){
        NSLog("%d", point.x)
    }
}
```
飞机点击后旋转升起  
<img src="https://img-blog.csdnimg.cn/20190708165139878.jpg" width="300">

## 问题
控制台警告⚠️
Main Thread Checker: UI API called on a background thread: -[UIApplication applicationState]
PID: 46338, TID: 8891400, Thread name: com.apple.CoreMotion.MotionThread, Queue name: com.apple.root.default-qos.overcommit, QoS: 0
怎么也去不掉，该警告是一个iOS上的bug
https://stackoverflow.com/questions/53379908/arkit-template-xcode-project-main-thread-checker-log-console
![img9](https://img-blog.csdnimg.cn/20190708164607811.png)

报错
[access] This app has crashed because it attempted to access privacy-sensitive data without a usage description.  The app's Info.plist must contain an NSCameraUsageDescription key with a string value explaining to the user how the app uses this data.
需要设置摄像头权限，在Info.plist添加
Privacy - Camera Usage Description 描述 This application will use the camera for Augmented Reality.


[本文章demo下载](https://github.com/gwh111/testARKitWithAction)  

[其他demo推荐，这里有一款可以在增强现实中画画的demo](https://github.com/oabdelkarim/ARPaint/issues)

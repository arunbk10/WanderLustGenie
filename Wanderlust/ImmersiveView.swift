//
//  ImmersiveView.swift
//  Wanderlust
//
//  Created by Arun Kulkarni on 22/02/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine
import MapKit

struct ImmersiveView: View {
    static var textureRequest: AnyCancellable?
    static var contentEntity = Entity()

    @Environment(ChatViewModel .self) private var viewModel
    @State var shouldShowText = true

    @State var animationEntity: Entity? = nil
    @State var levitateAnimation: AnimationResource? = nil

    // Anchor position for bot
    @State var chatbotEntity: Entity = {
        let headAnchor = AnchorEntity(.head)
        headAnchor.position = [1.5,-0.05, -3.0]
        let radians = -120 * Float.pi / 180
        ImmersiveView.rotateEntityAroundYAxis(entity: headAnchor, angle: radians)
        return headAnchor
    }()
     
    // Plane for map
    @State var planeEntity: Entity = {
        let wallAnchor = AnchorEntity(.plane(.vertical, classification: .wall, minimumBounds: SIMD2<Float>(0.008, 0.008)))
        let planeMesh = MeshResource.generatePlane(width: 1.5, depth: 1, cornerRadius: 0.1)
        let material = ImmersiveView.loadImageMaterial(imageUrl: "sketch")
        let planeEntity = ModelEntity(mesh: planeMesh, materials: [material])
        planeEntity.name = "canvas"
        wallAnchor.addChild(planeEntity)
        
        return wallAnchor
    }()

    var body: some View {
        @Bindable var viewModel = viewModel
        RealityView { content, attachments in
            do
            {
                // Add bot to the view
                let bot = try await Entity(named: "Chatbot", in: realityKitContentBundle)
                chatbotEntity.addChild(bot)
                content.add(planeEntity)
                content.add(chatbotEntity)
                bot.setScale([0.08, 0.08, 0.08], relativeTo: bot)

                // chat view on top of the bot
                guard let attachmentEntity = attachments.entity(for: "attachment") else { return }
                attachmentEntity.position = SIMD3<Float>(0.5, 0.5, 0)
                let radians = 120 * Float.pi / 180
                ImmersiveView.rotateEntityAroundYAxis(entity: attachmentEntity, angle: radians)
                chatbotEntity.addChild(attachmentEntity)

                // Add 3d room in immersive view
                let room = try await Entity(named: "Room1", in: realityKitContentBundle)
                content.add(room)
                room.setScale([0.01,0.01,0.01], relativeTo: nil)
                // Add panaromic lobby view as immersive view
                room.addChild(ImmersiveView.setUpImmersiveEntity())
            }
            catch
            {
                print("error in reality view:\(error)")
            }
        } update: { _, _ in
        } attachments: {
            Attachment(id: "attachment") {
                VStack {
                    Text(viewModel.introText)
                        .frame(maxWidth: 500, alignment: .leading)
                        .font(.extraLargeTitle2)
                        .fontWeight(.regular)
                        .padding(30)
                        .glassBackgroundEffect()
                }.opacity(shouldShowText ? 1 : 0)
            }
        }
        .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded {
            _ in
            viewModel.flowState = .intro
        })
        .onChange(of: viewModel.flowState) { _, newValue in
            switch newValue
            {
            case .idle:
                showIntro()
            case .intro, .listening, .output:
                break
            }
        }
    }
    
    // Add room
    static func setUpImmersiveEntity() -> Entity {
        let mod = ModelEntity()
        ImmersiveView.textureRequest = TextureResource.loadAsync(named: "park_scene").sink { (error) in
            print(error)
        } receiveValue: { (texture) in
            var material = UnlitMaterial()
            material.color = .init(texture: .init(texture))
            mod.components.set(ModelComponent(
                mesh: .generateSphere(radius: 1E3),
                materials: [material]
            ))
            mod.scale *= .init(x: -1, y: 1, z: 1)
            mod.transform.translation += SIMD3<Float>(0.0, 1.0, 0.0)
        }
        ImmersiveView.contentEntity.addChild(mod)
        return ImmersiveView.contentEntity
    }
    
    // Show text
    private func showIntro()
    {
        Task
        {
            if !shouldShowText
            {
                withAnimation(.smooth(duration: 0.3)) {
                    shouldShowText.toggle()
                }
            }
        }
    }
    
    // Add panaromic view
    static func loadImageMaterial(imageUrl: String) -> SimpleMaterial {
        do {
            
            let texture = try TextureResource.load(named: imageUrl)
            var material = SimpleMaterial()
            material.baseColor = MaterialColorParameter.texture(texture)
            return material
        } catch {
            fatalError(String(describing: error))
        }
    }
    
    static func rotateEntityAroundYAxis(entity: Entity, angle: Float) {
        // Get the current transform of the entity
        var currentTransform = entity.transform

        // Create a quaternion representing a rotation around the Y-axis
        let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])

        // Combine the rotation with the current transform
        currentTransform.rotation = rotation * currentTransform.rotation

        // Apply the new transform to the entity
        entity.transform = currentTransform
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}

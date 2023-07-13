//
//  InputPane.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/29.
//  Reference: https://www.devtechie.com/community/public/posts/151939-drawing-app-in-swiftui-3-using-canvas

import SwiftUI

struct Line {
    var points: [CGPoint]
    var color: Color
}

struct LineAction: Equatable {
    let isStart: Bool
    let point: CGPoint
}

struct InputPane: View {
    typealias DrawingAction = InteractLogModel.ActionModel.Action
    
    @Binding private var lines: [Line]
    @Binding private var selectedColour: Color
    
    init(lines: Binding<[Line]>, selectedColour: Binding<Color>) {
        _lines = .init(projectedValue: lines)
        _selectedColour = .init(projectedValue: selectedColour)
    }
    
    var body: some View {
        VStack {
            /*
             //Colour pens
            HStack {
                ForEach([Color.green, .orange, .blue, .red, .pink, .black, .purple], id: \.self) { color in
                    colorButton(color: color)
                }
                clearButton()
            }
             */
            
            Canvas {ctx, size in
                for line in lines {
                    var path = Path()
                    path.addLines(line.points)
                    
                    ctx.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged({ value in
                        let position = value.location
                        
                        if value.translation == .zero {
                            lines.append(Line(points: [position], color: selectedColour))
                        } else {
                            guard let lastIdx = lines.indices.last else {
                                return
                            }

                            lines[lastIdx].points.append(position)
                        }
                    })
            )
        }
    }
    
    @ViewBuilder
    func colorButton(color: Color) -> some View {
        Button {
            selectedColour = color
        } label: {
            Image(systemName: "circle.fill")
                .font(.largeTitle)
                .foregroundColor(color)
                .mask {
                    Image(systemName: "pencil.tip")
                        .font(.largeTitle)
                }
        }
    }
    
    @ViewBuilder
    func clearButton() -> some View {
        Button {
            lines = []
        } label: {
            Image(systemName: "pencil.tip.crop.circle.badge.minus")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
    }
}

struct InputPane_Previews: PreviewProvider {
    static var previews: some View {
        InputPane(lines: .constant([]), selectedColour: .constant(.blue))
    }
}


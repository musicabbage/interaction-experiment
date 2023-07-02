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

struct InputPane: View {
    
    @Binding private var lines: [Line]
    @State private var selectedColor = Color.black
    
    init(lines: Binding<[Line]>, selectedColor: SwiftUI.Color = Color.black) {
        _lines = .init(projectedValue: lines)
        self.selectedColor = selectedColor
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
                            lines.append(Line(points: [position], color: selectedColor))
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
            selectedColor = color
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
        InputPane(lines: .constant([]))
    }
}


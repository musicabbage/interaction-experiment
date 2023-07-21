//
//  PDFKitView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/18.
//

import SwiftUI
import PDFKit
import PencilKit

struct PDFKitView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private let pdfView = PDFView()
    private let url: URL // new variable to get the URL of the document
    
    init(url: URL) {
        self.url = url
    }
    
    func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> PDFView {
        // Creating a new PDFVIew and adding a document to it
        let document = PDFDocument(url: url)
        
        pdfView.displaysPageBreaks = false
        pdfView.pageOverlayViewProvider = context.coordinator
        pdfView.document = document
        pdfView.scaleFactor = 1.2
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitView>) {
        // we will leave this empty as we don't need to update the PDF
        uiView.isInMarkupMode = true
    }
}

extension PDFKitView {
    func cleanCanvas() {
        guard let coordinator = pdfView.pageOverlayViewProvider as? PDFKitView.Coordinator else {
            return
        }
        
        for page in coordinator.pageToViewMapping {
            let canvas = page.value
            canvas.drawing = .init()
        }
    }
    
    func makeNewPDFWithOverlay() -> URL? {
        guard let pdfDocument = pdfView.document else { return nil}

        let url = URL.cachesDirectory.appending(component: "consent_form.pdf")
        // Create a document, get the first page, and set the size of the page
        let mediaBox = pdfDocument.page(at: 0)?.bounds(for: .mediaBox)
        
        // This is where the magic happens.  Create the drawing context on the PDF
        guard var mediaBox, let context = CGContext(url as CFURL, mediaBox: &mediaBox, nil) else { return nil }
        UIGraphicsPushContext(context)
        
        for index in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: index) else { continue }
            context.beginPDFPage(nil)
            
            // Draws the PDF into the context
            page.draw(with: .mediaBox, to: context)
            
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: mediaBox.size.height)
            context.concatenate(flipVertical)
            
            if let coordinator = pdfView.pageOverlayViewProvider as? PDFKitView.Coordinator,
               let overlay = coordinator.pageToViewMapping[page] {
                let signedImage = overlay.drawing.image(from: overlay.frame, scale: 1)
                signedImage.draw(at: .zero)
            }
            
            context.endPDFPage()
        }
        
        context.closePDF()        
        UIGraphicsPopContext()
        
        return url
    }
}

extension PDFKitView {
    
    class Coordinator: NSObject, PDFPageOverlayViewProvider, PDFViewDelegate, PDFDocumentDelegate {
        
        var pageToViewMapping = [PDFPage: PKCanvasView]()
        
        func pdfView(_ view: PDFView, overlayViewFor page: PDFPage) -> UIView? {
            var resultView: PKCanvasView? = nil
            
            if let overlayView = pageToViewMapping[page] {
                resultView = overlayView
            } else {
                let canvasView = PKCanvasView(frame: .zero)
#if targetEnvironment(simulator)
                canvasView.drawingPolicy = .anyInput
#else
                canvasView.drawingPolicy = .pencilOnly
#endif
                canvasView.tool = PKInkingTool(.pen, color: .blue, width: 5)
                canvasView.backgroundColor = .clear
                canvasView.drawing = .init()
                pageToViewMapping[page] = canvasView
                resultView = canvasView
            }
            
            return resultView
        }
    }
}

struct PDFKitView_Previews: PreviewProvider {
    static var previews: some View {
        PDFKitView(url: Bundle.main.url(forResource: "consent_form", withExtension: "pdf")!)
    }
}

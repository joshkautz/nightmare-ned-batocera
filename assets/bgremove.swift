import Foundation
import Vision
import CoreImage
import AppKit

let args = CommandLine.arguments
guard args.count >= 3 else {
    FileHandle.standardError.write("usage: bgremove <in> <out.png>\n".data(using: .utf8)!)
    exit(2)
}
let inURL = URL(fileURLWithPath: args[1])
let outURL = URL(fileURLWithPath: args[2])

let handler = VNImageRequestHandler(url: inURL, options: [:])
let request = VNGenerateForegroundInstanceMaskRequest()

do {
    try handler.perform([request])
} catch {
    FileHandle.standardError.write("perform error: \(error)\n".data(using: .utf8)!)
    exit(1)
}

guard let result = request.results?.first else {
    FileHandle.standardError.write("no foreground instances found\n".data(using: .utf8)!)
    exit(1)
}

FileHandle.standardError.write("instances: \(result.allInstances.count)\n".data(using: .utf8)!)

do {
    let pb = try result.generateMaskedImage(ofInstances: result.allInstances,
                                             from: handler,
                                             croppedToInstancesExtent: false)
    let ci = CIImage(cvPixelBuffer: pb)
    let ctx = CIContext(options: nil)
    guard let cg = ctx.createCGImage(ci, from: ci.extent) else {
        FileHandle.standardError.write("cgimage failed\n".data(using: .utf8)!); exit(1)
    }
    let rep = NSBitmapImageRep(cgImage: cg)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        FileHandle.standardError.write("png encode failed\n".data(using: .utf8)!); exit(1)
    }
    try data.write(to: outURL)
    print("wrote \(outURL.path) \(cg.width)x\(cg.height)")
} catch {
    FileHandle.standardError.write("mask error: \(error)\n".data(using: .utf8)!)
    exit(1)
}

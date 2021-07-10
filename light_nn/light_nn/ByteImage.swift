//
//  ByteImage.swift
//  light_nn
//
//  Created by aaron on 2021/7/5.
//

import Foundation
import UIKit

func convertImage(data : [UInt8]) -> UIImage{
    var pixelValues = data
    let width = 28
    let height = 28
    let bitsPerComponent = 8
    let bytesPerPixel = 1
    let bitsPerPixel = bytesPerPixel * bitsPerComponent
    let bytesPerRow = bytesPerPixel * width
    let totalBytes = height * bytesPerRow
    let providerRef = CGDataProvider(dataInfo: nil, data: &pixelValues, size: totalBytes) { (info, data, size) in
        return
    }
    
    let colorSpaceRef = CGColorSpaceCreateDeviceGray()
    let bitmapInfo = CGBitmapInfo()
    let imageRef = CGImage(width: width,
                           height: height,
                           bitsPerComponent: bitsPerComponent,
                           bitsPerPixel: bitsPerPixel,
                           bytesPerRow: bytesPerRow,
                           space: colorSpaceRef,
                           bitmapInfo: bitmapInfo,
                           provider: providerRef!,
                           decode: nil,
                           shouldInterpolate: false,
                           intent: CGColorRenderingIntent.defaultIntent)
    return UIImage(cgImage: imageRef!)
}


func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(origin: .zero, size: newSize)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}


func pixelData(image : UIImage) -> [UInt8]? {
    let size = image.size
    let dataSize = size.width * size.height
    var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
    let colorSpace = CGColorSpaceCreateDeviceGray()
    let context = CGContext(data: &pixelData,
                            width: Int(size.width),
                            height: Int(size.height),
                            bitsPerComponent: 8,
                            bytesPerRow:  Int(size.width),
                            space: colorSpace,
                            bitmapInfo: CGImageAlphaInfo.none.rawValue)
    guard let cgImage = image.cgImage else { return nil }
    context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

    return pixelData
}

// Copyright (c) 2022 Jason Morley
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI

struct ExportToolbar: CustomizableToolbarContent {

    @Environment(\.showSavePanel) var showSavePanel

    var document: Icon

    @MainActor func saveSnapshot(for document: Icon, size: CGFloat, shadow: Bool = true, directoryURL: URL) throws {
        let icon = IconView(icon: document, size: size, renderShadow: shadow, isShadowFlipped: true)
        guard let data = icon.snapshot() else {
            throw IconicError.exportFailure
        }
        let type = shadow ? "macOS" : "iOS"
        let sizeString = String(format: "%d", size)
        let url = directoryURL.appendingPathComponent("\(type)_\(sizeString)x\(sizeString)", conformingTo: .png)
        try data.write(to: url)
    }

    var body: some CustomizableToolbarContent {

        ToolbarItem(id: "export") {
            Button {
                // We're dispatching to main here because for some reason the compiler doens't think the button action
                // is being performed on MainActor and is giving warnings (which is surprising).
                DispatchQueue.main.async {
                    guard let url = showSavePanel("Export Icon") else {
                        return
                    }
                    do {
                        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                        try saveSnapshot(for: document, size: 1024, directoryURL: url)
                        try saveSnapshot(for: document, size: 1024, shadow: false, directoryURL: url)
                    } catch {
                        print("Failed to write to file with error \(error)")
                    }
                }
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
        }

    }

}

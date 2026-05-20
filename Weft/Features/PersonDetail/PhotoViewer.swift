import SwiftUI

/// Full-screen zoomable viewer for an attached photo. Tap-to-dismiss; pinch
/// zooms via the system magnification gesture stack.
struct PhotoViewer: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in scale = max(1, min(lastScale * value.magnification, 4)) }
                        .onEnded { _ in lastScale = scale }
                )
                .onTapGesture { dismiss() }
        }
    }
}

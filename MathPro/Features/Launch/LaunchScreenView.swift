import SwiftUI

struct LaunchScreenView: View {
    @State private var logoScale: CGFloat = 0.4
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 30
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // App icon with glow
                ZStack {
                    // Glow behind icon
                    Circle()
                        .fill(Color(red: 0.13, green: 0.77, blue: 0.37))
                        .frame(width: 140, height: 140)
                        .blur(radius: 30)
                        .opacity(glowOpacity * 0.4)

                    Image("LaunchIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 27, style: .continuous))
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // App name
                VStack(spacing: 8) {
                    Text("MathPro")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Math Problem Solver")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(white: 0.50))
                }
                .opacity(textOpacity)
                .offset(y: textOffset)
            }
        }
        .onAppear {
            // 1) Logo: scale up with bounce
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            // 2) Glow pulse
            withAnimation(.easeIn(duration: 0.8).delay(0.5)) {
                glowOpacity = 1.0
            }

            // 3) Text slides up
            withAnimation(.easeOut(duration: 0.6).delay(0.7)) {
                textOpacity = 1.0
                textOffset = 0
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}

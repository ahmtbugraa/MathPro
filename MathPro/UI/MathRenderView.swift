import SwiftUI
import WebKit

/// KaTeX kullanarak LaTeX matematik ifadelerini render eder.
/// İnternet yoksa düz metin olarak fallback yapar.
struct MathRenderView: UIViewRepresentable {
    let latex: String
    var fontSize: CGFloat = 18
    var color: String = "#22C55E"     // AppTheme.Colors.primary hex
    var textColor: String = "#FFFFFF"
    var displayMode: Bool = false
    @Binding var contentHeight: CGFloat

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = false

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(buildHTML(), baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(contentHeight: $contentHeight)
    }

    // MARK: - HTML Builder
    private func buildHTML() -> String {
        let escaped = latex
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")

        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
        <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
        <style>
          * { box-sizing: border-box; margin: 0; padding: 0; }
          body {
            background: transparent;
            padding: 6px 4px;
            font-family: -apple-system, sans-serif;
          }
          #math { color: \(color); }
          .katex { font-size: \(fontSize)px !important; }
          .katex-display { margin: 0 !important; }
          #fallback {
            color: \(textColor);
            font-family: 'Courier New', monospace;
            font-size: \(fontSize)px;
            display: none;
          }
        </style>
        </head>
        <body>
        <div id="math"></div>
        <div id="fallback">\(latex)</div>
        <script>
        try {
          katex.render(`\(escaped)`, document.getElementById('math'), {
            throwOnError: false,
            displayMode: \(displayMode),
            strict: false
          });
        } catch(e) {
          document.getElementById('math').style.display = 'none';
          document.getElementById('fallback').style.display = 'block';
        }
        // Report height
        setTimeout(function() {
          var h = document.body.scrollHeight;
          window.webkit.messageHandlers.heightChange.postMessage(h);
        }, 50);
        </script>
        </body>
        </html>
        """
    }

    // MARK: - Coordinator
    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        @Binding var contentHeight: CGFloat

        init(contentHeight: Binding<CGFloat>) {
            self._contentHeight = contentHeight
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "heightChange", let h = message.body as? CGFloat {
                DispatchQueue.main.async { self.contentHeight = max(h, 30) }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.body.scrollHeight") { result, _ in
                if let h = result as? CGFloat {
                    DispatchQueue.main.async { self.contentHeight = max(h, 30) }
                }
            }
        }
    }
}

// MARK: - Convenience wrapper (fixed height fallback)
struct InlineMathView: View {
    let latex: String
    var fontSize: CGFloat = 16
    var color: String = "#22C55E"

    @State private var height: CGFloat = 36

    var body: some View {
        MathRenderView(
            latex: latex,
            fontSize: fontSize,
            color: color,
            displayMode: false,
            contentHeight: $height
        )
        .frame(height: height)
    }
}

struct DisplayMathView: View {
    let latex: String
    var fontSize: CGFloat = 20

    @State private var height: CGFloat = 56

    var body: some View {
        MathRenderView(
            latex: latex,
            fontSize: fontSize,
            color: "#22C55E",
            displayMode: true,
            contentHeight: $height
        )
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 20) {
        DisplayMathView(latex: "x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}")
        InlineMathView(latex: "2x^2 + 5x - 3 = 0")
    }
    .padding()
    .background(Color(red: 0.05, green: 0.05, blue: 0.05))
}

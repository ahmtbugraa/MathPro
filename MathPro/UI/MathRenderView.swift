import SwiftUI
import WebKit

/// KaTeX kullanarak LaTeX matematik ifadelerini render eder.
/// Internet yoksa duz metin olarak fallback yapar.
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
        config.userContentController.add(context.coordinator, name: "heightChange")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = buildHTML()
        webView.loadHTMLString(html, baseURL: nil)
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
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css"
              onerror="document.getElementById('math').style.display='none';document.getElementById('fallback').style.display='block';reportHeight();">
        <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"
                onerror="document.getElementById('math').style.display='none';document.getElementById('fallback').style.display='block';reportHeight();"></script>
        <style>
          * { box-sizing: border-box; margin: 0; padding: 0; }
          body {
            background: transparent;
            padding: 8px 4px;
            font-family: -apple-system, sans-serif;
            overflow-x: auto;
            overflow-y: hidden;
            -webkit-overflow-scrolling: touch;
          }
          #math {
            color: \(color);
            word-wrap: break-word;
            overflow-wrap: break-word;
          }
          .katex {
            font-size: \(fontSize)px !important;
            white-space: normal !important;
          }
          .katex-display {
            margin: 0 !important;
            overflow-x: auto;
            overflow-y: hidden;
            padding-bottom: 4px;
          }
          .katex-display > .katex {
            white-space: normal !important;
            text-align: left !important;
          }
          .katex-html {
            white-space: normal !important;
          }
          #fallback {
            color: \(color);
            font-family: 'Courier New', monospace;
            font-size: \(max(fontSize - 2, 14))px;
            line-height: 1.5;
            display: none;
            word-wrap: break-word;
            overflow-wrap: break-word;
          }
        </style>
        </head>
        <body>
        <div id="math"></div>
        <div id="fallback">\(latex)</div>
        <script>
        function reportHeight() {
          var h = Math.max(document.body.scrollHeight, document.body.offsetHeight);
          try { window.webkit.messageHandlers.heightChange.postMessage(h); } catch(e) {}
        }

        try {
          if (typeof katex !== 'undefined') {
            katex.render(`\(escaped)`, document.getElementById('math'), {
              throwOnError: false,
              displayMode: \(displayMode),
              strict: false,
              trust: true
            });
          } else {
            document.getElementById('math').style.display = 'none';
            document.getElementById('fallback').style.display = 'block';
          }
        } catch(e) {
          document.getElementById('math').style.display = 'none';
          document.getElementById('fallback').style.display = 'block';
        }

        // Report height with multiple retries to ensure accuracy
        setTimeout(reportHeight, 100);
        setTimeout(reportHeight, 300);
        setTimeout(reportHeight, 600);
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
                DispatchQueue.main.async {
                    // Only grow, never shrink (prevents flicker)
                    let newH = max(h, 30)
                    if newH > self.contentHeight {
                        self.contentHeight = newH
                    }
                }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Double-check height after page fully loads
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                webView.evaluateJavaScript("Math.max(document.body.scrollHeight, document.body.offsetHeight)") { result, _ in
                    if let h = result as? CGFloat {
                        DispatchQueue.main.async {
                            let newH = max(h, 30)
                            if newH > self.contentHeight {
                                self.contentHeight = newH
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Convenience wrapper (inline math)
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

// MARK: - Display math (block-level)
struct DisplayMathView: View {
    let latex: String
    var fontSize: CGFloat = 20

    @State private var height: CGFloat = 44

    var body: some View {
        MathRenderView(
            latex: latex,
            fontSize: fontSize,
            color: "#22C55E",
            displayMode: true,
            contentHeight: $height
        )
        .frame(minHeight: height)
        .fixedSize(horizontal: false, vertical: true)
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

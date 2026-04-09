import SwiftUI
import WebKit

/// KaTeX kullanarak LaTeX matematik ifadelerini render eder.
/// Internet yoksa okunabilir plain text fallback gösterir.
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

        // Build a readable plain-text fallback (no raw LaTeX)
        let fallbackText = Self.latexToReadable(latex)
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")

        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css"
              crossorigin="anonymous"
              onerror="showFallback()">
        <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js"
                crossorigin="anonymous"
                onerror="showFallback()"></script>
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
            font-family: -apple-system, 'SF Pro Display', sans-serif;
            font-size: \(fontSize)px;
            line-height: 1.6;
            display: none;
            word-wrap: break-word;
            overflow-wrap: break-word;
          }
        </style>
        </head>
        <body>
        <div id="math"></div>
        <div id="fallback">\(fallbackText)</div>
        <script>
        var fallbackShown = false;
        function showFallback() {
          if (fallbackShown) return;
          fallbackShown = true;
          document.getElementById('math').style.display = 'none';
          document.getElementById('fallback').style.display = 'block';
          reportHeight();
        }
        function reportHeight() {
          var h = Math.max(document.body.scrollHeight, document.body.offsetHeight);
          try { window.webkit.messageHandlers.heightChange.postMessage(h); } catch(e) {}
        }

        // Wait for script to load, then render
        function tryRender() {
          try {
            if (typeof katex !== 'undefined') {
              katex.render(`\(escaped)`, document.getElementById('math'), {
                throwOnError: false,
                displayMode: \(displayMode),
                strict: false,
                trust: true
              });
            } else {
              showFallback();
            }
          } catch(e) {
            showFallback();
          }
          setTimeout(reportHeight, 50);
          setTimeout(reportHeight, 200);
          setTimeout(reportHeight, 500);
        }

        // Try rendering after DOM + scripts are ready
        if (document.readyState === 'complete') {
          tryRender();
        } else {
          window.addEventListener('load', tryRender);
          // Safety timeout: if load event never fires, try anyway
          setTimeout(function() { if (!fallbackShown) tryRender(); }, 2000);
        }
        </script>
        </body>
        </html>
        """
    }

    /// Convert LaTeX to human-readable plain text (used as fallback when KaTeX fails to load).
    static func latexToReadable(_ text: String) -> String {
        var s = text

        // \frac{a}{b} → a/b
        if let regex = try? NSRegularExpression(pattern: "\\\\frac\\{([^}]*)\\}\\{([^}]*)\\}") {
            s = regex.stringByReplacingMatches(in: s, range: NSRange(s.startIndex..., in: s), withTemplate: "($1/$2)")
        }
        // \sqrt{a} → √(a)
        if let regex = try? NSRegularExpression(pattern: "\\\\sqrt\\{([^}]*)\\}") {
            s = regex.stringByReplacingMatches(in: s, range: NSRange(s.startIndex..., in: s), withTemplate: "√($1)")
        }
        // Common symbols
        s = s.replacingOccurrences(of: "\\Rightarrow", with: "⇒")
        s = s.replacingOccurrences(of: "\\rightarrow", with: "→")
        s = s.replacingOccurrences(of: "\\Leftarrow", with: "⇐")
        s = s.replacingOccurrences(of: "\\leftarrow", with: "←")
        s = s.replacingOccurrences(of: "\\leq", with: "≤")
        s = s.replacingOccurrences(of: "\\geq", with: "≥")
        s = s.replacingOccurrences(of: "\\neq", with: "≠")
        s = s.replacingOccurrences(of: "\\approx", with: "≈")
        s = s.replacingOccurrences(of: "\\infty", with: "∞")
        s = s.replacingOccurrences(of: "\\pm", with: "±")
        s = s.replacingOccurrences(of: "\\mp", with: "∓")
        s = s.replacingOccurrences(of: "\\times", with: "×")
        s = s.replacingOccurrences(of: "\\cdot", with: "·")
        s = s.replacingOccurrences(of: "\\div", with: "÷")
        s = s.replacingOccurrences(of: "\\pi", with: "π")
        s = s.replacingOccurrences(of: "\\alpha", with: "α")
        s = s.replacingOccurrences(of: "\\beta", with: "β")
        s = s.replacingOccurrences(of: "\\theta", with: "θ")
        s = s.replacingOccurrences(of: "\\Delta", with: "Δ")
        s = s.replacingOccurrences(of: "\\delta", with: "δ")
        s = s.replacingOccurrences(of: "\\sum", with: "Σ")
        s = s.replacingOccurrences(of: "\\int", with: "∫")
        // Superscripts / subscripts
        s = s.replacingOccurrences(of: "^{2}", with: "²")
        s = s.replacingOccurrences(of: "^{3}", with: "³")
        s = s.replacingOccurrences(of: "^2", with: "²")
        s = s.replacingOccurrences(of: "^3", with: "³")
        s = s.replacingOccurrences(of: "_{1}", with: "₁")
        s = s.replacingOccurrences(of: "_{2}", with: "₂")
        s = s.replacingOccurrences(of: "_1", with: "₁")
        s = s.replacingOccurrences(of: "_2", with: "₂")
        // Remove formatting commands
        s = s.replacingOccurrences(of: "\\left", with: "")
        s = s.replacingOccurrences(of: "\\right", with: "")
        s = s.replacingOccurrences(of: "\\text", with: "")
        s = s.replacingOccurrences(of: "\\mathrm", with: "")
        s = s.replacingOccurrences(of: "\\mathbf", with: "")
        s = s.replacingOccurrences(of: "\\quad", with: "  ")
        s = s.replacingOccurrences(of: "\\,", with: " ")
        s = s.replacingOccurrences(of: "\\ ", with: " ")
        // Remove any remaining backslash commands
        if let regex = try? NSRegularExpression(pattern: "\\\\[a-zA-Z]+") {
            s = regex.stringByReplacingMatches(in: s, range: NSRange(s.startIndex..., in: s), withTemplate: "")
        }
        // Clean braces
        s = s.replacingOccurrences(of: "{", with: "")
        s = s.replacingOccurrences(of: "}", with: "")
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
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

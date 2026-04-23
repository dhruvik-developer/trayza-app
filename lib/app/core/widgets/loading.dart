import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoaderWebView extends StatefulWidget {
  const LoaderWebView({super.key});

  @override
  State<LoaderWebView> createState() => _LoaderWebViewState();
}

class _LoaderWebViewState extends State<LoaderWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
        <!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Food Loader</title>

<style>
body {
  margin: 0;
  height: 100vh;
  background: #f1f3f5;
  display: flex;
  justify-content: center;
  align-items: center;
  font-family: 'Segoe UI', sans-serif;
}

.loader {
  text-align: center;
}

/* SVG size */
svg {
  width: 220px;
}

/* Moving lines animation */
.line {
  stroke-dasharray: 100;
  stroke-dashoffset: 100;
  animation: moveLine 2s linear infinite;
}

.line:nth-child(1) { animation-delay: 0s; }
.line:nth-child(2) { animation-delay: 0.3s; }
.line:nth-child(3) { animation-delay: 0.6s; }
.line:nth-child(4) { animation-delay: 0.9s; }

@keyframes moveLine {
  0% {
    stroke-dashoffset: 100;
    opacity: 0;
  }
  50% {
    opacity: 1;
  }
  100% {
    stroke-dashoffset: 0;
    opacity: 0;
  }
}

/* Text */
.text {
  margin-top: 10px;
  font-size: 22px;
  font-weight: 600;
}

.text span:first-child {
  color: #0078BE;
}

.text span:last-child {
  color: #333;
}

/* Loading text */
.loading {
  margin-top: 10px;
  color: #666;
  font-size: 14px;
}

.dots::after {
  content: "";
  animation: dots 1.5s steps(3, end) infinite;
}

@keyframes dots {
  0% { content: ""; }
  33% { content: "."; }
  66% { content: ".."; }
  100% { content: "..."; }
}
</style>

</head>

<body>

<div class="loader">

  <!-- SVG ICON -->
  <svg viewBox="0 0 200 120" fill="none" stroke="#0078BE" stroke-width="4" stroke-linecap="round">

    <!-- Moving lines -->
    <line class="line" x1="10" y1="40" x2="80" y2="40"/>
    <line class="line" x1="5" y1="60" x2="70" y2="60"/>
    <line class="line" x1="15" y1="80" x2="85" y2="80"/>

    <!-- Cloche (food cover) -->
    <path d="M100 80 A40 40 0 0 1 180 80" fill="#0078BE"/>
    <circle cx="140" cy="40" r="5" fill="#0078BE"/>
    <rect x="95" y="80" width="90" height="5" fill="#0078BE"/>
  </svg>
</div>

</body>
</html>
      ''');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite;

        return SizedBox(
          height: hasBoundedHeight ? constraints.maxHeight : 320,
          width: double.infinity,
          child: WebViewWidget(controller: controller),
        );
      },
    );
  }
}

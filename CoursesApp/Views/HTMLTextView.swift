import SwiftUI
import UIKit

struct HTMLTextView: View {
    let htmlString: String
    @State private var attributedString: AttributedString?

    var body: some View {
        if let attributedString = attributedString {
            Text(attributedString)
        } else {
            Text(htmlString)
                .onAppear {
                    convertHTMLToAttributedString()
                }
        }
    }

    private func convertHTMLToAttributedString() {
        guard let data = htmlString.data(using: .utf8) else { return }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        if let nsAttributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            attributedString = AttributedString(nsAttributedString)
        }
    }
}

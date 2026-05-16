import Foundation
import SwiftData
import UIKit

/// Renders the user's library to a styled PDF — same data shape as
/// `MarkdownExporter`, presented on cream paper with New York serif headings,
/// SF body, sage section rules, and footer page numbers. Output matches the
/// brand: calm, journal-like, single-column, no decorative chrome.
@MainActor
enum PDFExporter {
    static func export(from context: ModelContext) -> URL {
        let people = (try? context.fetch(FetchDescriptor<Person>())) ?? []
        let sorted = people.sorted { $0.name < $1.name }
        let data = render(people: sorted, generatedAt: .now)
        let url = URL.temporaryDirectory.appending(path: "Weft-export-\(timestamp(.now)).pdf")
        try? data.write(to: url, options: .atomic)
        return url
    }

    /// Pure renderer: takes already-sorted people + a generation timestamp and
    /// returns PDF bytes. Separated from `export()` so tests can supply
    /// deterministic input without going through the filesystem.
    static func render(people: [Person], generatedAt: Date) -> Data {
        // US Letter, 612 × 792 pt. Comfortable for both EN and JA text widths.
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let margin: CGFloat = 56
        let contentWidth = pageRect.width - margin * 2

        let renderer = UIGraphicsPDFRenderer(
            bounds: pageRect,
            format: makeFormat(generatedAt: generatedAt, peopleCount: people.count)
        )

        return renderer.pdfData { ctx in
            var state = LayoutState(
                pageRect: pageRect,
                margin: margin,
                contentWidth: contentWidth,
                ctx: ctx,
                pageNumber: 0,
                generatedAt: generatedAt
            )
            state.beginPage()
            drawCover(state: &state, peopleCount: people.count)
            for person in people {
                drawPerson(person, state: &state)
            }
            state.drawFooter()
        }
    }

    // MARK: - Drawing

    private static func drawCover(state: inout LayoutState, peopleCount: Int) {
        state.draw(text: "Weft", style: .coverTitle)
        state.advance(by: 4)
        let countLabel = String(
            localized: "\(peopleCount) people",
            comment: "PDF export cover subtitle — person count. iOS plural variant key 'people'."
        )
        state.draw(
            text: "\(humanDate(state.generatedAt)) · \(countLabel)",
            style: .coverMeta
        )
        state.advance(by: 28)
        state.drawRule()
        state.advance(by: 28)
    }

    private static func drawPerson(_ person: Person, state: inout LayoutState) {
        state.ensureSpace(forHeight: 92)
        state.draw(text: person.name, style: .personName)
        state.advance(by: 2)
        state.draw(
            text: "\(person.relationship.label) · \(person.rhythm.label)",
            style: .personMeta
        )
        state.advance(by: 16)

        let notes = person.notesOrEmpty.sorted { $0.createdAt > $1.createdAt }
        if !notes.isEmpty {
            state.draw(text: loc("Notes"), style: .sectionHeading)
            state.advance(by: 8)
            for note in notes {
                let line = "• \(humanDate(note.createdAt)) — \(note.body)"
                state.draw(text: line, style: .bodyItem)
                if let data = note.photoData, let image = UIImage(data: data) {
                    state.drawImage(image, maxWidth: 280, maxHeight: 200)
                }
                state.advance(by: 4)
            }
            state.advance(by: 12)
        }

        let openThreads = person.threadsOrEmpty
            .filter(\.isOpen)
            .sorted { $0.dueDate < $1.dueDate }
        if !openThreads.isEmpty {
            state.draw(text: loc("Open threads"), style: .sectionHeading)
            state.advance(by: 8)
            for thread in openThreads {
                let line = "• \(humanDate(thread.dueDate)) — \(thread.body)"
                state.draw(text: line, style: .bodyItem)
                state.advance(by: 4)
            }
            state.advance(by: 12)
        }

        state.advance(by: 18)
        state.drawSoftRule()
        state.advance(by: 18)
    }

    // MARK: - Format

    private static func makeFormat(generatedAt: Date, peopleCount: Int) -> UIGraphicsPDFRendererFormat {
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [
            kCGPDFContextTitle as String: "Weft export — \(humanDate(generatedAt))",
            kCGPDFContextAuthor as String: "Weft",
            kCGPDFContextCreator as String: "Weft for iOS",
            kCGPDFContextSubject as String: "Personal CRM export · \(peopleCount) people"
        ]
        return format
    }

    // MARK: - Helpers

    private static func humanDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    private static func timestamp(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.string(from: date)
    }
}

// MARK: - Layout

/// Mutable cursor state threaded through every draw call. Owns the current
/// page, current y, and knows how to break to a new page when content overflows.
private struct LayoutState {
    let pageRect: CGRect
    let margin: CGFloat
    let contentWidth: CGFloat
    let ctx: UIGraphicsPDFRendererContext
    var pageNumber: Int
    var y: CGFloat = 0
    let generatedAt: Date

    private var contentBottom: CGFloat {
        pageRect.height - margin - 28
    }

    mutating func beginPage() {
        if pageNumber > 0 {
            drawFooter()
        }
        ctx.beginPage()
        pageNumber += 1
        drawPageBackground()
        y = margin
    }

    mutating func advance(by delta: CGFloat) {
        y += delta
    }

    mutating func ensureSpace(forHeight needed: CGFloat) {
        if y + needed > contentBottom {
            beginPage()
        }
    }

    /// Renders an image scaled to fit within `maxWidth × maxHeight`, preserving
    /// aspect ratio. Indents to align with the bullet body. Breaks to a new
    /// page if there isn't enough vertical room left.
    mutating func drawImage(_ image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return }
        let scale = min(maxWidth / size.width, maxHeight / size.height, 1.0)
        let renderedSize = CGSize(width: size.width * scale, height: size.height * scale)

        // Image needs its own page if we can't fit it where the cursor is.
        if y + renderedSize.height + 8 > contentBottom {
            beginPage()
        }
        advance(by: 6)
        let indent: CGFloat = 12
        let imageRect = CGRect(
            x: margin + indent,
            y: y,
            width: renderedSize.width,
            height: renderedSize.height
        )
        image.draw(in: imageRect)
        // Subtle stroke to mirror the in-app card treatment.
        let path = UIBezierPath(roundedRect: imageRect, cornerRadius: 4)
        UIColor(white: 0, alpha: 0.08).setStroke()
        path.lineWidth = 0.5
        path.stroke()
        y += renderedSize.height + 4
    }

    mutating func draw(text: String, style: TextStyle) {
        let attrs = style.attributes
        let attributed = NSAttributedString(string: text, attributes: attrs)
        let rect = attributed.boundingRect(
            with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        if y + rect.height <= contentBottom {
            attributed.draw(
                with: CGRect(x: margin, y: y, width: contentWidth, height: rect.height),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
            y += rect.height
            return
        }
        paginateAcrossPages(attributed: attributed, attrs: attrs)
    }

    /// Walks the text fragment-by-fragment, drawing as much as fits in the
    /// current page before breaking. Without this, long bodies past a page
    /// boundary would silently disappear.
    private mutating func paginateAcrossPages(
        attributed: NSAttributedString,
        attrs: [NSAttributedString.Key: Any]
    ) {
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(attributedString: attributed)
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: CGSize(
            width: contentWidth,
            height: .greatestFiniteMagnitude
        ))
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)
        layoutManager.ensureLayout(for: textContainer)

        var glyphIndex = 0
        let totalGlyphs = layoutManager.numberOfGlyphs
        let minLineHeight = (attrs[.font] as? UIFont)?.lineHeight ?? 12
        while glyphIndex < totalGlyphs {
            let available = max(contentBottom - y, 0)
            if available < minLineHeight {
                beginPage()
                continue
            }
            let (consumed, height) = fitGlyphs(
                from: glyphIndex,
                total: totalGlyphs,
                available: available,
                using: layoutManager
            )
            if consumed == 0 {
                beginPage()
                continue
            }
            drawSlice(
                attributed: attributed,
                layoutManager: layoutManager,
                from: glyphIndex,
                length: consumed,
                height: height
            )
            glyphIndex += consumed
            if glyphIndex < totalGlyphs {
                beginPage()
            }
        }
    }

    private func fitGlyphs(
        from glyphIndex: Int,
        total: Int,
        available: CGFloat,
        using layoutManager: NSLayoutManager
    ) -> (consumed: Int, height: CGFloat) {
        var consumed = 0
        var height: CGFloat = 0
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(
            location: glyphIndex,
            length: total - glyphIndex
        )) { _, usedRect, _, range, stop in
            if height + usedRect.height > available {
                stop.pointee = true
                return
            }
            height += usedRect.height
            consumed = NSMaxRange(range) - glyphIndex
        }
        return (consumed, height)
    }

    private mutating func drawSlice(
        attributed: NSAttributedString,
        layoutManager: NSLayoutManager,
        from glyphIndex: Int,
        length: Int,
        height: CGFloat
    ) {
        let glyphRange = NSRange(location: glyphIndex, length: length)
        let charRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        let slice = attributed.attributedSubstring(from: charRange)
        slice.draw(
            with: CGRect(x: margin, y: y, width: contentWidth, height: height),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        y += height
    }

    func drawFooter() {
        let pageLabel = String(
            localized: "page \(pageNumber)",
            comment: "PDF export footer — current page number."
        )
        let footerText = "Weft  ·  \(pageLabel)"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .medium),
            .foregroundColor: UIColor(white: 0.55, alpha: 1),
            .kern: 0.4
        ]
        let attributed = NSAttributedString(string: footerText, attributes: attrs)
        let size = attributed.size()
        let footerY = pageRect.height - margin / 2 - size.height
        let footerX = (pageRect.width - size.width) / 2
        attributed.draw(at: CGPoint(x: footerX, y: footerY))
    }

    mutating func drawRule() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: y))
        path.addLine(to: CGPoint(x: margin + contentWidth, y: y))
        UIColor(red: 92 / 255, green: 122 / 255, blue: 102 / 255, alpha: 1).setStroke()
        path.lineWidth = 1.0
        path.stroke()
    }

    mutating func drawSoftRule() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: y))
        path.addLine(to: CGPoint(x: margin + contentWidth, y: y))
        UIColor(white: 0.85, alpha: 1).setStroke()
        path.lineWidth = 0.5
        path.stroke()
    }

    /// Paint the cream background and a faint top accent rule.
    func drawPageBackground() {
        let cream = UIColor(red: 248 / 255, green: 245 / 255, blue: 239 / 255, alpha: 1)
        cream.setFill()
        UIBezierPath(rect: pageRect).fill()
    }
}

/// Typography tokens. Pulled out so layout code reads as intent, not as
/// dictionary literal soup.
private enum TextStyle {
    case coverTitle
    case coverMeta
    case personName
    case personMeta
    case sectionHeading
    case bodyItem

    var attributes: [NSAttributedString.Key: Any] {
        switch self {
        case .coverTitle:
            let descriptor = UIFontDescriptor(
                fontAttributes: [.family: "New York", .size: 38]
            ).withSymbolicTraits(.traitItalic) ?? UIFontDescriptor(name: "New York", size: 38)
            return [
                .font: UIFont(descriptor: descriptor, size: 38),
                .foregroundColor: UIColor(red: 22 / 255, green: 20 / 255, blue: 16 / 255, alpha: 1),
                .kern: -0.6
            ]
        case .coverMeta:
            return [
                .font: UIFont.systemFont(ofSize: 11, weight: .medium),
                .foregroundColor: UIColor(white: 0.45, alpha: 1),
                .kern: 0.8
            ]
        case .personName:
            return [
                .font: UIFont(name: "NewYork-Medium", size: 24)
                    ?? UIFont.systemFont(ofSize: 24, weight: .medium),
                .foregroundColor: UIColor(red: 22 / 255, green: 20 / 255, blue: 16 / 255, alpha: 1),
                .kern: -0.3
            ]
        case .personMeta:
            return [
                .font: UIFont.italicSystemFont(ofSize: 12),
                .foregroundColor: UIColor(red: 92 / 255, green: 122 / 255, blue: 102 / 255, alpha: 1),
                .kern: 0.2
            ]
        case .sectionHeading:
            return [
                .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
                .foregroundColor: UIColor(white: 0.35, alpha: 1),
                .kern: 1.4
            ]
        case .bodyItem:
            let para = NSMutableParagraphStyle()
            para.lineSpacing = 3
            para.paragraphSpacing = 0
            para.firstLineHeadIndent = 0
            para.headIndent = 12
            return [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor(red: 22 / 255, green: 20 / 255, blue: 16 / 255, alpha: 1),
                .paragraphStyle: para
            ]
        }
    }
}

//
//  TagListView.swift
//  TagListViewDemo
//
//  Created by Dongyuan Liu on 2015-05-09.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit

@objc public protocol TagListViewDelegate {
    @objc optional func tagPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void
    @objc optional func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void
}

@IBDesignable
open class TagListView: UIView {

    @IBInspectable open dynamic var textColor: UIColor = .white {
        didSet {
            tagViews.forEach {
                $0.textColor = textColor
            }
        }
    }

    @IBInspectable open dynamic var selectedTextColor: UIColor = .white {
        didSet {
            tagViews.forEach {
                $0.selectedTextColor = selectedTextColor
            }
        }
    }

    @IBInspectable open dynamic var tagLineBreakMode: NSLineBreakMode = .byTruncatingMiddle {
        didSet {
            tagViews.forEach {
                $0.titleLineBreakMode = tagLineBreakMode
            }
        }
    }

    @IBInspectable open dynamic var tagBackgroundColor: UIColor = UIColor.gray {
        didSet {
            tagViews.forEach {
                $0.tagBackgroundColor = tagBackgroundColor
            }
        }
    }

    @IBInspectable open dynamic var tagHighlightedBackgroundColor: UIColor? {
        didSet {
            tagViews.forEach {
                $0.highlightedBackgroundColor = tagHighlightedBackgroundColor
            }
        }
    }

    @IBInspectable open dynamic var tagSelectedBackgroundColor: UIColor? {
        didSet {
            tagViews.forEach {
                $0.selectedBackgroundColor = tagSelectedBackgroundColor
            }
        }
    }

    @IBInspectable open dynamic var cornerRadius: CGFloat = 0 {
        didSet {
            tagViews.forEach {
                $0.cornerRadius = cornerRadius
            }
        }
    }
    @IBInspectable open dynamic var borderWidth: CGFloat = 0 {
        didSet {
            tagViews.forEach {
                $0.borderWidth = borderWidth
            }
        }
    }

    @IBInspectable open dynamic var borderColor: UIColor? {
        didSet {
            tagViews.forEach {
                $0.borderColor = borderColor
            }
        }
    }

    @IBInspectable open dynamic var selectedBorderColor: UIColor? {
        didSet {
            tagViews.forEach {
                $0.selectedBorderColor = selectedBorderColor
            }
        }
    }

    @IBInspectable open dynamic var paddingY: CGFloat = 2 {
        didSet {
            tagViews.forEach {
                $0.paddingY = paddingY
            }
            setNeedsLayout()
        }
    }
    @IBInspectable open dynamic var paddingX: CGFloat = 5 {
        didSet {
            tagViews.forEach {
                $0.paddingX = paddingX
            }
            setNeedsLayout()
        }
    }
    @IBInspectable open dynamic var marginY: CGFloat = 2 {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable open dynamic var marginX: CGFloat = 5 {
        didSet {
            setNeedsLayout()
        }
    }

    @objc public enum Alignment: Int {
        case left
        case center
        case right
    }
    @IBInspectable open var alignment: Alignment = .left {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable open dynamic var shadowColor: UIColor = .white {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable open dynamic var shadowRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable open dynamic var shadowOffset: CGSize = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable open dynamic var shadowOpacity: Float = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open dynamic var enableRemoveButton: Bool = false {
        didSet {
            tagViews.forEach {
                $0.enableRemoveButton = enableRemoveButton
            }
            setNeedsLayout()
        }
    }

    @IBInspectable open dynamic var removeButtonIconSize: CGFloat = 12 {
        didSet {
            tagViews.forEach {
                $0.removeButtonIconSize = removeButtonIconSize
            }
            setNeedsLayout()
        }
    }
    @IBInspectable open dynamic var removeIconLineWidth: CGFloat = 1 {
        didSet {
            tagViews.forEach {
                $0.removeIconLineWidth = removeIconLineWidth
            }
            setNeedsLayout()
        }
    }

    @IBInspectable open dynamic var removeIconLineColor: UIColor = UIColor.white.withAlphaComponent(0.54) {
        didSet {
            tagViews.forEach {
                $0.removeIconLineColor = removeIconLineColor
            }
            setNeedsLayout()
        }
    }

    @objc open dynamic var textFont: UIFont = .systemFont(ofSize: 12) {
        didSet {
            tagViews.forEach {
                $0.textFont = textFont
            }
            setNeedsLayout()
        }
    }

    @IBInspectable open dynamic var maximalNumberOfLines: UInt = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBOutlet open weak var delegate: TagListViewDelegate?

    open private(set) var tagViews: [TagView] = []
    private(set) var tagBackgroundViews: [UIView] = []
    private(set) var rowViews: [UIView] = []
    private(set) var tagViewHeight: CGFloat = 0
    private(set) var rows = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    // MARK: - Interface Builder

    open override func prepareForInterfaceBuilder() {
        addTag("Welcome")
        addTag("to")
        addTag("TagListView").isSelected = true
    }

    // MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()

        rearrangeViews()
    }

    private func rearrangeViews() {
        let views = tagViews as [UIView] + tagBackgroundViews + rowViews
        views.forEach {
            $0.removeFromSuperview()
        }
        rowViews.removeAll(keepingCapacity: true)

        var currentRow = 0
        var currentRowView: UIView!
        var currentRowTagCount = 0
        var currentRowWidth: CGFloat = 0
        for (index, tagView) in tagViews.enumerated() {
            tagView.frame.size = tagView.intrinsicContentSize
            tagViewHeight = tagView.frame.height
            let currentRowWidthExceedsAvailableRowWidth = currentRowWidth + tagView.frame.width > frame.width
            
            if currentRowWidthExceedsAvailableRowWidth && maximalNumberOfLines > 0 && currentRow >= maximalNumberOfLines {
                break
            }

            if currentRowTagCount == 0 || currentRowWidthExceedsAvailableRowWidth {
                currentRow += 1
                currentRowWidth = 0
                currentRowTagCount = 0
                currentRowView = UIView()
                currentRowView.frame.origin.y = CGFloat(currentRow - 1) * (tagViewHeight + marginY)

                rowViews.append(currentRowView)
                addSubview(currentRowView)

                tagView.frame.size.width = min(tagView.frame.size.width, frame.width)
            }

            let tagBackgroundView = tagBackgroundViews[index]
            tagBackgroundView.frame.origin = CGPoint(x: currentRowWidth, y: 0)
            tagBackgroundView.frame.size = tagView.bounds.size
            tagBackgroundView.layer.shadowColor = shadowColor.cgColor
            tagBackgroundView.layer.shadowPath = UIBezierPath(roundedRect: tagBackgroundView.bounds, cornerRadius: cornerRadius).cgPath
            tagBackgroundView.layer.shadowOffset = shadowOffset
            tagBackgroundView.layer.shadowOpacity = shadowOpacity
            tagBackgroundView.layer.shadowRadius = shadowRadius
            tagBackgroundView.addSubview(tagView)
            currentRowView.addSubview(tagBackgroundView)

            currentRowTagCount += 1
            currentRowWidth += tagView.frame.width + marginX

            switch alignment {
            case .left:
                currentRowView.frame.origin.x = 0
            case .center:
                currentRowView.frame.origin.x = (frame.width - (currentRowWidth - marginX)) / 2
            case .right:
                currentRowView.frame.origin.x = frame.width - (currentRowWidth - marginX)
            }
            currentRowView.frame.size.width = currentRowWidth
            currentRowView.frame.size.height = max(tagViewHeight, currentRowView.frame.height)
        }
        rows = currentRow

        invalidateIntrinsicContentSize()
    }

    // MARK: - Manage tags

    override open var intrinsicContentSize: CGSize {
        var height = CGFloat(rows) * (tagViewHeight + marginY)
        if rows > 0 {
            height -= marginY
        }
        return CGSize(width: frame.width, height: height)
    }

    private func createNewTagView(_ title: String) -> TagView {
        let tagView = TagView(title: title)

        tagView.textColor = textColor
        tagView.selectedTextColor = selectedTextColor
        tagView.tagBackgroundColor = tagBackgroundColor
        tagView.highlightedBackgroundColor = tagHighlightedBackgroundColor
        tagView.selectedBackgroundColor = tagSelectedBackgroundColor
        tagView.titleLineBreakMode = tagLineBreakMode
        tagView.cornerRadius = cornerRadius
        tagView.borderWidth = borderWidth
        tagView.borderColor = borderColor
        tagView.selectedBorderColor = selectedBorderColor
        tagView.paddingX = paddingX
        tagView.paddingY = paddingY
        tagView.textFont = textFont
        tagView.removeIconLineWidth = removeIconLineWidth
        tagView.removeButtonIconSize = removeButtonIconSize
        tagView.enableRemoveButton = enableRemoveButton
        tagView.removeIconLineColor = removeIconLineColor

        return tagView
    }

    @discardableResult
    open func addTag(_ title: String) -> TagView {
        return addTagView(createNewTagView(title))
    }

    @discardableResult
    open func addTags(_ titles: [String]) -> [TagView] {
        return addTagViews(titles.map(createNewTagView))
    }
    
    @discardableResult
    open func addTagView(_ tagView: TagView) -> TagView {
        tagViews.append(tagView)
        tagBackgroundViews.append(UIView(frame: tagView.bounds))

        tagView.addTarget(self, action: #selector(tagPressed(_:)), for: .touchUpInside)
        tagView.removeButton.addTarget(self, action: #selector(removeButtonPressed(_:)), for: .touchUpInside)

        // On long press, deselect all tags except this one
        tagView.onLongPress = { [unowned self] this in
            self.tagViews.forEach {
                $0.isSelected = $0 == this
            }
        }
        
        return tagView
    }

    @discardableResult
    open func addTagViews(_ tagViews: [TagView]) -> [TagView] {
        tagViews.forEach {
            addTagView($0)
        }
        setNeedsLayout()
        return tagViews
    }

    @discardableResult
    open func insertTag(_ title: String, at index: Int) -> TagView {
        return insertTagView(createNewTagView(title), at: index)
    }

    @discardableResult
    open func insertTagView(_ tagView: TagView, at index: Int) -> TagView {
        tagViews.insert(tagView, at: index)
        tagBackgroundViews.insert(UIView(frame: tagView.bounds), at: index)
        setNeedsLayout()

        return tagView
    }

    open func setTitle(_ title: String, at index: Int) {
        tagViews[index].titleLabel?.text = title
    }

    open func removeTag(_ title: String) {
        tagViews.reversed().filter({ $0.currentTitle == title }).forEach(removeTagView)
    }

    open func removeTagView(_ tagView: TagView) {
        tagView.removeFromSuperview()
        if let index = tagViews.firstIndex(of: tagView) {
            tagViews.remove(at: index)
            tagBackgroundViews.remove(at: index)
        }

        setNeedsLayout()
    }

    open func removeAllTags() {
        defer {
            tagViews = []
            tagBackgroundViews = []
        }
        tagViews = []
        tagBackgroundViews = []
        setNeedsLayout()
    }

    open func selectedTags() -> [TagView] {
        return tagViews.filter { $0.isSelected }
    }

    // MARK: - Events

    @objc func tagPressed(_ sender: TagView!) {
        sender.onTap?(sender)
        delegate?.tagPressed?(sender.currentTitle ?? "", tagView: sender, sender: self)
    }

    @objc func removeButtonPressed(_ closeButton: CloseButton!) {
        if let tagView = closeButton.tagView {
            delegate?.tagRemoveButtonPressed?(tagView.currentTitle ?? "", tagView: tagView, sender: self)
        }
    }
}

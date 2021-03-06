//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation

@objc
public class CVComponentBottomButtons: CVComponentBase, CVComponent {

    private let bottomButtonsState: CVComponentState.BottomButtons

    typealias Action = CVMessageAction
    fileprivate var actions: [Action] { bottomButtonsState.actions }

    required init(itemModel: CVItemModel, bottomButtonsState: CVComponentState.BottomButtons) {
        self.bottomButtonsState = bottomButtonsState

        super.init(itemModel: itemModel)
    }

    public func buildComponentView(componentDelegate: CVComponentDelegate) -> CVComponentView {
        CVComponentViewBottomButtons()
    }

    public func configureForRendering(componentView componentViewParam: CVComponentView,
                                      cellMeasurement: CVCellMeasurement,
                                      componentDelegate: CVComponentDelegate) {
        guard let componentView = componentViewParam as? CVComponentViewBottomButtons else {
            owsFailDebug("Unexpected componentView.")
            componentViewParam.reset()
            return
        }

        componentView.reset()

        let stackView = componentView.stackView
        stackView.apply(config: stackConfig)

        for action in actions {
            let buttonView = CVMessageActionButton(action: action)
            buttonView.backgroundColor = Theme.conversationButtonBackgroundColor
            stackView.addArrangedSubview(buttonView)
            componentView.buttonViews.append(buttonView)
        }
    }

    private var stackConfig: CVStackViewConfig {
        CVStackViewConfig(axis: .vertical, alignment: .fill, spacing: Self.buttonSpacing, layoutMargins: .zero)
    }

    fileprivate static var buttonHeight: CGFloat { CVMessageActionButton.buttonHeight }
    fileprivate static let buttonSpacing: CGFloat = 1

    private var totalHeight: CGFloat {
        var height = Self.buttonHeight * CGFloat(actions.count)
        if actions.count > 1 {
            height += CGFloat(actions.count - 1) * Self.buttonSpacing
        }
        return height
    }

    public func measure(maxWidth: CGFloat, measurementBuilder: CVCellMeasurement.Builder) -> CGSize {
        owsAssertDebug(maxWidth > 0)

        return CGSize(width: maxWidth, height: totalHeight).ceil
    }

    // MARK: - Events

    public override func handleTap(sender: UITapGestureRecognizer,
                                   componentDelegate: CVComponentDelegate,
                                   componentView: CVComponentView,
                                   renderItem: CVRenderItem) -> Bool {

        guard let componentView = componentView as? CVComponentViewBottomButtons else {
            owsFailDebug("Unexpected componentView.")
            return false
        }

        for buttonView in componentView.buttonViews {
            let location = sender.location(in: buttonView)
            guard buttonView.bounds.contains(location) else {
                continue
            }
            buttonView.action.perform(delegate: componentDelegate)
            return true
        }
        return false
    }

    // MARK: -

    // Used for rendering some portion of an Conversation View item.
    // It could be the entire item or some part thereof.
    @objc
    public class CVComponentViewBottomButtons: NSObject, CVComponentView {

        fileprivate let stackView = OWSStackView(name: "bottomButtons")
        fileprivate var buttonViews = [CVMessageActionButton]()

        public var isDedicatedCellView = false

        public var rootView: UIView {
            stackView
        }

        public func setIsCellVisible(_ isCellVisible: Bool) {}

        public func reset() {
            stackView.reset()

            buttonViews.removeAll()
        }
    }
}

//
//  ViewExtensions.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/26/23.
//

import SwiftUI

// MARK: - RoundedCorner

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - DismissKeyboardOnTap

public struct DismissKeyboardOnTap: ViewModifier {

    private var tapGesture: some Gesture {
        TapGesture().onEnded(endEditing)
    }

    public func body(content: Content) -> some View {
        #if os(macOS)
        return content
        #else
        return content.gesture(tapGesture)
        #endif
    }

    private func endEditing() {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter(\.isKeyWindow)
            .first?.endEditing(true)
    }
}

// MARK: - AnimationCompletionObserverModifier

/// An animatable modifier that is used for observing animations for a given animatable
/// value.
public struct AnimationCompletionObserverModifier<Value>: AnimatableModifier
    where Value: VectorArithmetic
{

    /// While animating, SwiftUI changes the old input value to the new target value using
    /// this property. This value is set to the old value until the animation completes.
    public var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }

    /// The target value for which we're observing. This value is directly set once the
    /// animation starts. During animation, `animatableData` will hold the oldValue and is
    /// only updated to the target value once the animation completes.
    private var targetValue: Value

    /// The completion callback which is called once the animation completes.
    private var completion: () -> Void

    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        animatableData = observedValue
        targetValue = observedValue
    }

    public func body(content: Content) -> some View {
        // We're not really modifying the view so we can directly return the original
        // input value.
        return content
    }

    /// Verifies whether the current animation is finished and calls the completion
    /// callback if true.
    private func notifyCompletionIfFinished() {
        guard animatableData == targetValue else { return }

        // Dispatching is needed to take the next runloop for the completion callback.
        // This prevents errors like "Modifying state during view update, this will cause
        // undefined behavior."
        DispatchQueue.main.async {
            completion()
        }
    }
}

public extension View {
    func addBorder(
        _ content: some ShapeStyle,
        width: CGFloat = 1,
        cornerRadius: CGFloat,
        corners: UIRectCorner
    ) -> some View {
        let roundedRect = Rectangle()
            .cornerRadius(cornerRadius, corners: corners)

        return clipShape(roundedRect)
            .overlay(roundedRect.stroke(content, lineWidth: width))
    }

    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some Shape {
        RoundedCorner(radius: radius, corners: corners)
    }

    func tapDismissesKeyboard() -> some View {
        modifier(DismissKeyboardOnTap())
    }

    func grayShadow() -> some View {
        shadow(
            color: Color.gray.opacity(0.3),
            radius: 8,
            x: 2,
            y: 3
        )
    }

    /// Calls the completion handler whenever an animation on the given value completes.
    /// - Parameters:
    ///   - value: The value to observe for animations.
    ///   - completion: The completion callback to call once the animation completes.
    /// - Returns: A modified `View` instance with the observer attached.
    func onAnimationCompleted<Value: VectorArithmetic>(
        for value: Value,
        completion: @escaping () -> Void
    )
        -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>>
    {
        return modifier(AnimationCompletionObserverModifier(
            observedValue: value,
            completion: completion
        ))
    }

}

//
// CaseIterable.swift
//
// Copyright © 2015 Zeeshan Mian
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#if swift(>=4.2)
#else
// Credit: http://stackoverflow.com/a/33598988

/// A type that makes conforming `Enum` cases iteratable.
///
/// ```swift
/// enum CompassPoint: Int, CaseIterable {
///     case north
///     case south
///     case east
///     case west
/// }
///
/// for point in CompassPoint.allCases {
///     // point [north, south, east, west]
/// }
///
/// for point in CompassPoint.rawValues {
///     // point [0, 1, 2, 3]
/// }
/// ```
///
/// `CaseIterable` requires conforming enums types to be `RawRepresentable`.
public protocol CaseIterable {
    associatedtype EnumType: Hashable, RawRepresentable = Self
    static var allCases: [EnumType] { get }
    static var rawValues: [EnumType.RawValue] { get }
}

extension CaseIterable {
    /// Return `AnyGenerator` to iterate over all cases of `self`:
    ///
    /// ```swift
    /// enum CompassPoint: Int, CaseIterable {
    ///     case north, south, east, west
    /// }
    ///
    /// for point in CompassPoint.enumerated() {
    ///     print("\(point): '\(point.rawValue)'")
    /// }
    ///
    /// north: '0'
    /// south: '1'
    /// wast: '2'
    /// west: '3'
    /// ```
    private static func enumerated() -> AnyIterator<EnumType> {
        var i = 0
        return AnyIterator {
            let next = withUnsafePointer(to: &i) {
                $0.withMemoryRebound(to: EnumType.self, capacity: 0) {
                    $0.pointee
                }
            }

            let nextValue: EnumType? = next.hashValue == i ? next : nil
            i += 1
            return nextValue
        }
    }

    /// Return an array containing all cases of `self`.
    public static var allCases: [EnumType] {
        // Swift based enums always have a fixed size of `1` whereas `@objc` enums size is `8`.
        guard MemoryLayout<Self>.size == 1 else {
            #if DEBUG
                fatalError("Unsupported type of enum detected. `CaseIterable` does not support enums marked with `@objc` as it can hang and eventually crash the app in the Release mode.")
            #else
                return []
            #endif
        }

        return enumerated().map { $0 }
    }
}

extension CaseIterable {
    /// Return an array containing all corresponding `rawValue`s of `self`.
    public static var rawValues: [EnumType.RawValue] {
        return allCases.map { $0.rawValue }
    }

    /// Count of all enum cases.
    public static var count: Int {
        return allCases.count
    }
}
#endif

// The MIT License (MIT)
// Copyright © 2022 Sparrow Code LTD (https://sparrowcode.io, hello@sparrowcode.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if PERMISSIONSKIT_SPM
import PermissionsKit
#endif

#if os(iOS) && PERMISSIONSKIT_CALENDAR
import Foundation
import EventKit

public extension IKPermission {
    
    static func calendar(access: CalendarAccess) -> CalendarPermission {
        CalendarPermission(kind: .calendar(access: access))
    }
}

public class CalendarPermission: IKPermission {
    
    private var _kind: IKPermission.Kind
    
    // MARK: - Init
    
    init(kind: IKPermission.Kind) {
        self._kind = kind
    }
    
    open override var kind: IKPermission.Kind { self._kind }
    open var usageDescriptionKey: String? {
        if #available(iOS 17, *) {
            switch kind {
            case .calendar(let access):
                switch access {
                case .full:
                    return "NSCalendarsFullAccessUsageDescription"
                case .write:
                    return "NSCalendarsWriteOnlyAccessUsageDescription"
                }
            default:
                fatalError()
            }
        } else {
            return "NSCalendarsUsageDescription"
        }
    }
    
    public override var status: IKPermission.Status {
        // Fix when status first time response with other state.
        let _ = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
        case .authorized: return .authorized
        case .denied: return .denied
        case .fullAccess: return .authorized
        case .notDetermined: return .notDetermined
        case .restricted: return .denied
        case .writeOnly:
            if #available(iOS 17, *) {
                switch kind {
                case .calendar(let access):
                    switch access {
                    case .full:
                        return .denied
                    case .write:
                        return .authorized
                    }
                default:
                    fatalError()
                }
            } else {
                return .authorized
            }
        @unknown default: return .denied
        }
    }
    
    public override func request() async -> IKPermission.Status {
        let eventStore = EKEventStore()
        
        if #available(iOS 17.0, *) {
            switch self.kind {
            case .calendar(let access) where access == .write:
                _ = try? await eventStore.requestWriteOnlyAccessToEvents()
            default:
                _ = try? await eventStore.requestFullAccessToEvents()
            }
        } else {
            _ = try? await eventStore.requestAccess(to: .event)
        }
        
        return status
    }
}
#endif

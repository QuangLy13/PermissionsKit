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

#if os(iOS) && PERMISSIONSKIT_REMINDERS
import Foundation
import EventKit

public extension IKPermission {

    static var reminders: RemindersPermission {
        return RemindersPermission()
    }
}

public class RemindersPermission: IKPermission {
    
    open override var kind: IKPermission.Kind { .reminders }
    open var usageDescriptionKey: String? { "NSRemindersUsageDescription" }
    open var usageFullAccessDescriptionKey: String? { "NSRemindersFullAccessUsageDescription" }
    
    public override var status: IKPermission.Status {
        switch EKEventStore.authorizationStatus(for: EKEntityType.reminder) {
        case .authorized: return .authorized
        case .denied: return .denied
        case .fullAccess: return .authorized
        case .notDetermined: return .notDetermined
        case .restricted: return .denied
        case .writeOnly: return .authorized
        @unknown default: return .denied
        }
    }
    
    public override func request() async -> IKPermission.Status {
        let eventStore = EKEventStore()

        if #available(iOS 17.0, *) {
            _ = try? await eventStore.requestFullAccessToReminders()
        } else {
            _ = try? await eventStore.requestAccess(to: .reminder)
        }

        return status
    }
}
#endif

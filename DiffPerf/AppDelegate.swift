//
//  AppDelegate.swift
//  DiffPerf
//
//  Created by Ryan Nystrom on 2/7/18.
//  Copyright © 2018 Ryan Nystrom. All rights reserved.
//

import UIKit
import Dwifft
import Differ
import IGListKit
import DeepDiff

func measure(_ f: () -> Void) -> CFTimeInterval {
    let time = CFAbsoluteTimeGetCurrent()
    f()
    return CFAbsoluteTimeGetCurrent() - time
}

func benchmark(_ f: () -> Void) -> [CFTimeInterval] {
    var times = [CFTimeInterval]()
    let n = 1000
    for _ in 0..<n {
        times.append(measure(f))
    }
    return times
}

struct Result {
    let created: [CFTimeInterval]
    let deleted: [CFTimeInterval]
    let same: [CFTimeInterval]
    let changed: [CFTimeInterval]
}

extension Array where Element == CFTimeInterval {
    var mean: CFTimeInterval {
        let sum = reduce(0, { $0 + $1 })
        return sum / CFTimeInterval(count)
    }
    var minimum: CFTimeInterval {
        return reduce(Double.greatestFiniteMagnitude, { Swift.min($0, $1) })
    }
    var maximum: CFTimeInterval {
        return reduce(0, { Swift.max($0, $1) })
    }
    func percentile(_ p: Double) -> CFTimeInterval {
        guard count > 0 else { return 0 }

        let fraction = Double(count) * p
        let ceiled = ceil(fraction)
        let sort = sorted()
        let ceiledIdx = Int(ceiled)
        if fraction == ceiled && ceiledIdx < count - 2 {
            return (sort[ceiledIdx] + sort[ceiledIdx+1])/2
        } else if ceiledIdx < count {
            return sort[ceiledIdx]
        } else {
            return sort[ceiledIdx-1]
        }
    }
    var breakdown: String {
        return "avg: \(String(format: "%.6f", mean)), min: \(String(format: "%.6f", minimum)), max: \(String(format: "%.6f", maximum)), p50: \(String(format: "%.6f", percentile(0.5))), p75: \(String(format: "%.6f", percentile(0.75))), p90: \(String(format: "%.6f", percentile(0.9))), p95: \(String(format: "%.6f", percentile(0.95))), p99: \(String(format: "%.6f", percentile(0.99)))"
    }
}

func performDiff(_ f: ([NSString], [NSString]) -> Void) -> Result {
    return Result(
        created: benchmark { f([], to) },
        deleted: benchmark { f(from, []) },
        same: benchmark { f(from, from) },
        changed: benchmark { f(from, to) }
//        same: [], changed: []
    )
}

func printResult(_ name: String, result: Result) {
    print("=== \(name) results:")
    print("created:\n\(result.created.breakdown)")
    print("deleted:\n\(result.deleted.breakdown)")
    print("same:\n\(result.same.breakdown)")
    print("changed:\n\(result.changed.breakdown)")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        printResult("IGListKit", result: performDiff { (o, n) in
            _ = ListDiff(oldArray: o, newArray: n, option: .equality)
        })
//        printResult("Dwifft", result: performDiff { (o, n) in
//            _ = Dwifft.diff(o, n)
//        })
//        printResult("DeepDiff", result: performDiff { (o, n) in
//            _ = DeepDiff.diff(old: o, new: n)
//        })
//        printResult("Differ", result: performDiff { (o, n) in
//            _ = o.diff(n)
//        })

        return true
    }


}


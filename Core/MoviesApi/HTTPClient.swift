// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import Foundation

typealias HTTPClient = @Sendable (URL) async throws -> (Data, HTTPURLResponse)

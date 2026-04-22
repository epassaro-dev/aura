import XCTest
import SwiftData
@testable import Aura

func makeContainer() throws -> ModelContainer {
    try .makeAuraContainer(inMemory: true)
}

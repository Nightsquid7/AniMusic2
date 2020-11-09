import RealmSwift

extension List where Element == String {
    func getSourceTypes() -> [SourceType] {
        print("getting source types")
            return self.compactMap { SourceType(rawValue: $0) }
    }
}

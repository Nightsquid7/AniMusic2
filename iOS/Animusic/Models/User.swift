import RealmSwift

class User: Object {
     var preferredSources = List<String>()

    required init() {
        preferredSources = List(array: SourceType.allCasesToString())
    }
}

extension User {
    func toggleSourceType(_ sourceType: SourceType) {
        if contains(sourceType) {
            let index = preferredSources.index(of: sourceType.rawValue)!
            preferredSources.remove(at: index)
        } else {
            preferredSources.append(sourceType.rawValue)
        }
    }

    func accessoryTypeFor(_ sourceType: SourceType) -> UITableViewCell.AccessoryType {
        if contains(sourceType) {
            print("user contains source", sourceType)
            return .checkmark
        } else {
            return .none
        }
    }

    func contains(_ sourceType: SourceType) -> Bool {
        return preferredSources.asSourceTypes().contains(sourceType)
    }
}

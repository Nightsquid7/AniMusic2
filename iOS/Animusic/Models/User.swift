import RealmSwift

class User: Object {
     var preferredSourceTypes = List<String>()

    required init() {
        preferredSourceTypes = List(array: SourceType.allCasesToString())
    }
}



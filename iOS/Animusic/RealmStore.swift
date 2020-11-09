import RealmSwift

class RealmStore {
    let realm: Realm!
    static let sharedInstance = RealmStore()

    init() {
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        realm = try? Realm(configuration: config)
    }

    func initUser() {
        let users = realm.objects(User.self)
        if users.count  < 1 {
            let user = User()
            do {
                try realm.write {
                    realm.add(user)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func user() -> User? {
        return realm.objects(User.self).first
    }
}

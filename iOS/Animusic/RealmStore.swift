import RealmSwift

class RealmStore {
    let realm: Realm!

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
}

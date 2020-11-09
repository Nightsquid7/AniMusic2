import RxSwift
import RxDataSources
import RealmSwift

class UserPreferencesViewModel {
    let user: User!
    private let realm = try! Realm()

    let dataSource: RxTableViewSectionedReloadDataSource<SourceTypeSection>!
    let sections = BehaviorSubject<[SourceTypeSection]>(value: [])

    init() {
        let users = realm.objects(User.self)
        print("users.count", users.count)
        if let user = users.first {
            self.user = user
        } else {
            self.user = User()
        }

        sections.onNext( [SourceTypeSection(header: "SourceTypes", items: SourceType.allCases)] )

        dataSource = RxTableViewSectionedReloadDataSource<SourceTypeSection>(configureCell: { _, tableView, indexPath, item in
            let cell: SourceTypeTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configureFor(item)
            cell.accessoryType = users.first?.accessoryTypeFor(item) ?? .none
            return cell
        })

        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }
    }

    func toggleSource(_ sourceType: SourceType) {
        try? realm.write {
            user.toggleSourceType(sourceType)
        }
    }

    func accessoryTypeFor(_ sourceType: SourceType) -> UITableViewCell.AccessoryType {
        return user.accessoryTypeFor(sourceType)
    }

}

struct SourceTypeSection {
    var header: String
    var items: [Item]
}
extension SourceTypeSection: SectionModelType {
    typealias Item = SourceType

    init(original: SourceTypeSection, items: [SourceType]) {
        self = original
        self.items = items
    }
}

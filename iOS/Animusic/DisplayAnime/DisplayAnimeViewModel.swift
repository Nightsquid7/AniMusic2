import RealmSwift
import RxSwift
import RxDataSources

class DisplayAnimeViewModel {

    // MARK: - Properties
    var dataSource: RxTableViewSectionedReloadDataSource<BookmarkedAnimeViewSection>!
    var sections = BehaviorSubject<[BookmarkedAnimeViewSection]>(value: [])

    let realm = try! Realm()
    let disposeBag = DisposeBag()

    var animes: Results<RealmAnimeSeries>

    func showBookmarkedAnimes() {
        animes = realm
            .objects(RealmAnimeSeries.self)
            .filter(NSPredicate(format: "bookmarked = true"))

        sections.onNext( animes.map { BookmarkedAnimeViewSection(items: [$0]) })
    }

    init() {
        animes = realm
            .objects(RealmAnimeSeries.self)
            .filter(NSPredicate(format: "bookmarked = true"))

        sections.onNext( animes.map { BookmarkedAnimeViewSection(items: [$0]) })

        dataSource = RxTableViewSectionedReloadDataSource<BookmarkedAnimeViewSection>(configureCell: { _, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as! ResultTableViewCell
            cell.configureCell(from: item)
            return cell
        })
    }

    func search(for queryString: String) {
        let name = "name CONTAINS[c] %@"
        let englishName = "nameEnglish CONTAINS[c] %@"
        let artistNames = "ANY artists.name In %@"
        let namesOrArtistNames = name + "||" + englishName + "||" + artistNames

        let byName = NSPredicate(format: name, queryString)
        let byNamesOrArtistNames = NSPredicate(format: namesOrArtistNames, queryString, queryString, [queryString])

        let matchingAnimes: [SearchResult] = realm.objects(RealmAnimeSeries.self)
            .filter(byName)
            .map { $0 }
        let matchingSongs: [SearchResult] = realm.objects(RealmAnimeSong.self)
            .filter(byNamesOrArtistNames)
            .map { $0 }
        let results = matchingAnimes + matchingSongs

        sections.onNext( results.map {  BookmarkedAnimeViewSection(items: [$0]) })
    }
}

struct BookmarkedAnimeViewSection {
    var items: [SearchResult]
}

extension BookmarkedAnimeViewSection: SectionModelType {
    init(original: BookmarkedAnimeViewSection, items: [SearchResult]) {
        self = original
        self.items = items
    }

}

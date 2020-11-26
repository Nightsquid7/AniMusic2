import RealmSwift
import RxSwift
import RxDataSources

class DisplayAnimeViewModel {

    // MARK: - Properties
    var dataSource: RxTableViewSectionedReloadDataSource<BookmarkedAnimeViewSection>!
    var sections = BehaviorSubject<[BookmarkedAnimeViewSection]>(value: [])

    var isLoading  = BehaviorSubject<Bool>(value: true)
    var isReady  = BehaviorSubject<Bool>(value: false)

    var seasonCount = BehaviorSubject<String>(value: "")
    
    let firebaseStore = FirebaseStore.sharedInstance
    let realm: Realm
    let disposeBag = DisposeBag()

    func showBookmarkedAnimes() {
        let animes = realm
            .objects(AnimeSeries.self)
            .filter(NSPredicate(format: "bookmarked = true"))

        sections.onNext( animes.map { BookmarkedAnimeViewSection(items: [$0]) })
    }
    
    func showProgressString() -> Observable<String> {
        return Observable<String>.create { observable in
            let numberOfFirebaseSeasons = self.firebaseStore.firebaseSeasons
                .map { $0.count }
            _ = Observable.combineLatest(numberOfFirebaseSeasons, self.firebaseStore.numberOfSeasonsDownloaded)
                .map { firebaseSeasons, downloadedSeasons in
                    observable.onNext("Downloading \(downloadedSeasons) of \(firebaseSeasons) seasons")
                }
                .subscribe()
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    init() {
        realm = firebaseStore.realm

        _ = Observable
            .collection(from: realm
                            .objects(AnimeSeries.self))
            .asObservable()
            // MARK: todo -> why is there a discrepancy between the number of saved anime and anime in firebase?
            .filter { $0.count >= 4000 }
            .subscribe(onNext: { _ in
                self.isLoading.onNext(false)
                self.isReady.onNext(true)
            })
            .disposed(by: disposeBag)

        _ = Observable
              .collection(from: realm
                            .objects(AnimeSeries.self)
                            .filter(NSPredicate(format: "bookmarked = true")))
            .subscribe(onNext: { bookmarkedAnimes in
                self.sections.onNext( bookmarkedAnimes.map { BookmarkedAnimeViewSection(items: [$0]) })
            })
            .disposed(by: disposeBag)

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

        let matchingAnimes: [SearchResult] = realm.objects(AnimeSeries.self)
            .filter(byName)
            .map { $0 }
        let matchingSongs: [SearchResult] = realm.objects(AnimeSong.self)
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

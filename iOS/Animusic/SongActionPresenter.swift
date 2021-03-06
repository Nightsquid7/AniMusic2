import UIKit
import WebKit
import MediaPlayer

protocol SongActionPresenter where Self: UIViewController {
    var navigator: Navigator { get }
}

extension SongActionPresenter {
    func presentAlertController(vc: UIViewController, song: AnimeSong) {
        let titleString = song.name
        let ac = UIAlertController(title: titleString, message: "", preferredStyle: .actionSheet)
        if let iPadPopoverPC = ac.popoverPresentationController {
            iPadPopoverPC.sourceView = vc.view
            iPadPopoverPC.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
        }
        let realmStore = RealmStore.sharedInstance
        guard let user = realmStore.user()  else { return }

        for sourceType in user.sources() {
            addAction(for: sourceType, ac: ac, song: song)
        }

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        vc.present(ac, animated: true)
    }

    fileprivate func addAction(for sourceType: SourceType, ac: UIAlertController, song: AnimeSong) {
        var actionTitle = "Search"
        let formattedSongName = song.description().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var url: URL?

        let player = MPMusicPlayerController.applicationQueuePlayer
        switch sourceType {
//        case .spotify:
//            if let spotifySource = song.sources.first(where: { $0.type == "Spotify"}) {
//                actionTitle = "Open in"
//                url = URL(string: spotifySource.externalUrl)
//                if let url = url {
//                    ac.addAction(UIAlertAction(title: "\(actionTitle) \(sourceType)", style: .default, handler: { _ in
//                        UIApplication.shared.open(url)
//                    }))
//                }
//            }
        case .appleMusic:
            if let appleMusicSource =  song.sources.first(where: { $0.type == "AppleMusic"}) {
                actionTitle = "Open in"
                player.setQueue(with: [appleMusicSource.URI])
                ac.addAction(UIAlertAction(title: "\(actionTitle) \(sourceType)", style: .default, handler: { _ in
                    player.play()
                }))
                return
            }
//        case .youTube:
//            url = URL(string: "https://www.youtube.com/results?search_query=\(formattedSongName)")
//            if let url = url {
//                ac.addAction(UIAlertAction(title: "\(actionTitle) \(sourceType)", style: .default, handler: { _ in
//                    self.navigator.show(segue: .webViewViewController(url: url), sender: self)
//                }))
//            }
        }

    }
}

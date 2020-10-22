//
//  SongActionPresenter.swift
//  
//
//  Created by Steven Berkowitz on 2020/10/22.
//
import UIKit

protocol SongActionPresenter {}

extension SongActionPresenter {
    func presentAlertController(vc: UIViewController, song: RealmAnimeSong) {
        let titleString = song.name
        let ac = UIAlertController(title: titleString, message: "", preferredStyle: .actionSheet)
        if let popoverPresentationController = ac.popoverPresentationController {
            popoverPresentationController.sourceView = vc.view
            popoverPresentationController.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
        }

        for sourceType in ["Spotify", "Youtube", "Google Play"] {
            addAction(for: sourceType, ac: ac, song: song)
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        vc.present(ac, animated: true)
    }

    fileprivate func addAction(for sourceType: String, ac: UIAlertController, song: RealmAnimeSong) {
        var actionTitle = "Search"
        let formattedSongName = song.nameEnglish.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var url: URL?

        switch sourceType {
        case "Spotify":
            if let spotifySource = song.sources.first(where: { $0.type == "Spotify"}) {
                actionTitle = "Open in"
                url = URL(string: spotifySource.externalUrl)
            } else {
                url = URL(string: "https://open.spotify.com/search/\(formattedSongName))")
            }
        case "Youtube":
            url = URL(string: "https://www.youtube.com/results?search_query=\(formattedSongName)")
        case "Google Play":
            url = URL(string: "https://play.google.com/store/search?q=\(formattedSongName)&c=music&hl=en")
        default:
            return
        }

        if let url = url {
            ac.addAction(UIAlertAction(title: "\(actionTitle) \(sourceType)", style: .default, handler: { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
        }
    }
}

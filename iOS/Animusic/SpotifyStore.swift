import Foundation

class SpotifyStore: NSObject, SPTAppRemoteDelegate {
    static let sharedInstance = SpotifyStore()
    static private let kAccessTokenKey = "access-token-key"
    let spotifyClientID = "b37b31d992a944278709986f10ec59d4"
    let spotifyRedirectURL = URL(string: "animusic://")!

    lazy var appRemote: SPTAppRemote = {
          let configuration = SPTConfiguration(clientID: spotifyClientID,
                                               redirectURL: spotifyRedirectURL)
          let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
          appRemote.connectionParameters.accessToken = accessToken
          appRemote.delegate = self
          return appRemote
      }()

    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
            didSet {
                let defaults = UserDefaults.standard
                defaults.set(accessToken, forKey: SpotifyStore.kAccessTokenKey)
            }
    }

    // MARK: SPTAppRemoteDelegate 
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("connected to spotify")
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
            print("spotify disconnected")
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("appRemote failed ")
    }

    // MARK: SPTAppRemotePlayerStateDelegate
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("spotify player state changed")
    }

}

import UIKit

class TabBarController: UITabBarController, UISearchBarDelegate {

    static func createWith(storyboard: UIStoryboard) -> TabBarController {
        return storyboard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        selectedViewController = viewControllers!.first!
        setNavigationItemSearchController()
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        setNavigationItemSearchController()
    }
}

extension TabBarController {
    func setNavigationItemSearchController() {
        if let discoverAnimeVC = selectedViewController as? DiscoverAnimeViewController {
            navigationItem.searchController =
                discoverAnimeVC.searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
}

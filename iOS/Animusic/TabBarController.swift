import UIKit

class TabBarController: UITabBarController, UISearchBarDelegate {

    static func createWith(storyboard: UIStoryboard) -> TabBarController {
        return storyboard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.items![0].title = NSLocalizedString("Bookmarks", comment: "tab bar button title")
        tabBar.items![1].title = NSLocalizedString( "Preferences", comment: "tab button title")
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
        if let displayAnimeViewController = selectedViewController as? DisplayAnimeViewController {
            navigationItem.searchController =
                displayAnimeViewController.searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
}

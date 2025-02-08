import UIKit

final class TabBarViewController: UITabBarController {
    
    // MARK: - UI Elemets -
    private let homeBar = UIView()
    private let customTabBar = UIView()
    private let titleLabel = UILabel()
    private let addTaskButton = UIButton()
    
    // MARK: - Properties -
    private let isFirstLaunch: Bool
    
    // MARK: - Init -
    init(_ isFirstLaunch: Bool) {
        self.isFirstLaunch = isFirstLaunch
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods -
private extension TabBarViewController {
    func setupUI() {
        setupView()
        setupHomeBar()
        setupTabBar()
        setupTitleLabel()
        setupAddTaskButton()
        setupConstraints()
    }
    
    func setupView() {
        tabBar.isHidden = true
        let tasksVC = TasksViewController(isFirstLaunch) { [weak self] data in
            guard let `self` else { return }
            self.titleLabel.text = "\(data)"
        }
        setViewControllers([tasksVC], animated: true)
    }
    
    func setupHomeBar() {
        homeBar.backgroundColor = UIColor(named: "tabBarColor")
        view.addSubview(homeBar)
    }
    
    func setupTabBar() {
        customTabBar.backgroundColor = UIColor(named: "tabBarColor")
        view.addSubview(customTabBar)
    }
    
    func setupTitleLabel() {
        titleLabel.textColor = UIColor(named: "customLabelColor")
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        customTabBar.addSubview(titleLabel)
    }
    
    func setupAddTaskButton() {
        addTaskButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        addTaskButton.tintColor = UIColor(named: "addTaskButton")
        addTaskButton.addTarget(self, action: #selector(addTaskButtonTapped), for: .touchUpInside)
        customTabBar.addSubview(addTaskButton)
    }
    
    @objc func addTaskButtonTapped() {
        navigationController?.pushViewController(TaskEditViewController(), animated: true)
    }
    
    func setupConstraints() {
        homeBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        customTabBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(homeBar.snp.top)
            make.height.equalTo(49)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(customTabBar)
        }
        
        addTaskButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalTo(68)
            make.right.equalTo(customTabBar).offset(-16)
            make.centerY.equalTo(customTabBar)
        }
    }
}

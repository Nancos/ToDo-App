import UIKit

final class TasksViewController: UIViewController {
    
    // MARK: - UI Elements -
    private let viewForTitleLabel = UIView()
    private let titleLabel = UILabel()
    private let viewSearchBar = UIView()
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
        
    // MARK: - Presenter -
    private let presenter = TasksPresenter()
    
    // MARK: - Properties -
    private var tasks: [TasksViewData] = []
    var sendData: ((String) -> Void)?
    var onTextEntered: ((String) -> Void)?
    private var searchTimer: Timer?
    
    // MARK: - Init -
    init(_ isFirstLaunch: Bool, sendData: ((String) -> Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.sendData = sendData
        presenter.delegate = self
        setupUI()
        presenter.fetchTasks(isFirstLaunch)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle -
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateTableData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset.bottom = getSizeTabbars()
    }
}

// MARK: - Private methods -
private extension TasksViewController {
    func setupUI() {
        setupView()
        setupViewForTitleLabel()
        setupLabel()
        setupViewSearchBar()
        setupSearchBar()
        setupTable()
        setupConstraints()
    }
    
    func setupView() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        view.backgroundColor = UIColor(named: "backgroundColor")
    }
    
    func setupViewForTitleLabel() {
        viewForTitleLabel.backgroundColor = UIColor(named: "backgroundColor")
        view.addSubview(viewForTitleLabel)
    }
    
    func setupLabel() {
        titleLabel.text = String(localized: "Tasks")
        titleLabel.textColor = UIColor(named: "customLabelColor")
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textAlignment = .left
        viewForTitleLabel.addSubview(titleLabel)
    }
    
    func setupViewSearchBar() {
        viewSearchBar.backgroundColor = UIColor(named: "backgroundColor")
        view.addSubview(viewSearchBar)
    }
    
    func setupSearchBar() {
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = UIColor(named: "tabBarColor")
        searchBar.layer.cornerRadius = 10
        searchBar.placeholder = String(localized: "Search")
        searchBar.tintColor = UIColor(named: "colorTextSearchBar")
        searchBar.searchTextField.backgroundColor = UIColor(named: "tabBarColor")
        searchBar.delegate = self
        viewSearchBar.addSubview(searchBar)
    }
    
    func setupTable() {
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.register(TaskViewCell.self, forCellReuseIdentifier: TaskViewCell.description())
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        viewForTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(3)
            make.left.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(viewForTitleLabel).offset(3)
            make.right.left.equalTo(viewForTitleLabel).inset(20)
            make.bottom.equalTo(viewForTitleLabel).offset(-8)
        }
        
        viewSearchBar.snp.makeConstraints { make in
            make.top.equalTo(viewForTitleLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(52)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(viewSearchBar)
            make.left.right.equalTo(viewSearchBar).inset(20)
            make.height.equalTo(36)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(searchBar.snp.bottom).offset(16)
        }
    }
}

// MARK: - Private functions -
private extension TasksViewController {
    func getSizeTabbars() -> CGFloat {
        guard let tabBarHeight = tabBarController?.tabBar.frame.height else { return 0 }
        let bottomInset = tabBarHeight - view.safeAreaInsets.bottom
        return bottomInset
    }
}

// MARK: - TasksPresenterProtocol -
extension TasksViewController: TasksPresenterProtocol {
    func shareMessage(message: String) {
        if !message.isEmpty {
            let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            present(activityViewController, animated: true)
        }
    }
    
    func configureView(with data: [TasksViewData], countTasks: String) {
        sendData?(countTasks)
        tasks = data
        tableView.reloadData()
    }
    
    func updateSearchResults(with data: [TasksViewData], countTasks: String) {
        sendData?(countTasks)
        tasks = data
        tableView.reloadData()
    }
    
    func showStatus(message: String) { showAlert(title: String(localized: "Error"), message: message) }
}

// MARK: - UISearchBarDelegate -
extension TasksViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(executeSearch), userInfo: searchText, repeats: false)
    }
    
    @objc private func executeSearch() {
        guard let searchText = searchTimer?.userInfo as? String else { return }
        if searchText.isEmpty {
            presenter.regularLaunch()
        } else {
            presenter.searchTasks(with: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { searchBar.resignFirstResponder() }
    
    @objc func hideKeyboard() { view.endEditing(true) }
}


// MARK: - UITableViewDelegate, UITableViewDataSource -
extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tasks.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskViewCell.description(), for: indexPath) as? TaskViewCell
        else { return UITableViewCell() }
        
        configureCell(task: tasks[indexPath.row], cell: cell)
        
        cell.onCheckMarkTapped = { [weak self] id in
            guard let `self` else { return }
            self.tasks[indexPath.row].completed.toggle()
            self.presenter.updateCompletedStatus(id: id, completed: self.tasks[indexPath.row].completed)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.onTaskTapped = { [weak self] id in
            guard let `self` else { return }
            let editTaskVC = TaskEditViewController(id: id)
            editTaskVC.onTaskDeleted = { [weak self] in
                guard let `self` else { return }
                self.updateTableData()
            }
            navigationController?.pushViewController(editTaskVC, animated: true)
        }
        return cell
    }
    
    private func configureCell(task: TasksViewData, cell: TaskViewCell?) {
        cell?.configure(id: task.id,
                        completed: task.completed,
                        title: task.nameTask,
                        description: task.descriptionTask,
                        dateString: task.dateTask)
    }
    
    func updateTableData() {
        if let searchText = searchBar.text, !searchText.isEmpty {
            presenter.searchTasks(with: searchText)
        } else {
            presenter.regularLaunch()
        }
    }
}

// MARK: - UIContextMenu -
extension TasksViewController {
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { actions in
            let editAction = UIAction(title: String(localized: "Edit"), image: UIImage(systemName: "square.and.pencil")) { action in
                self.editTaskAction(indexPath)
            }
            let shareAction = UIAction(title: String(localized: "Share"), image: UIImage(systemName: "square.and.arrow.up")) { action in
                self.shareTaskAction(indexPath)
            }
            let deleteAction = UIAction(title: String(localized: "Delete"), image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                self.removeTaskAction(indexPath)
            }
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        })
    }
    
    private func editTaskAction(_ indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TaskViewCell {
            let editTaskVC = TaskEditViewController(id: cell.id)
            editTaskVC.onTaskDeleted = { [weak self] in
                guard let `self` else { return }
                self.updateTableData()
            }
            navigationController?.pushViewController(editTaskVC, animated: true)
        }
    }
    
    private func shareTaskAction(_ indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TaskViewCell else {
            showAlert(title: String(localized: "Error"), message: String(localized: "error_try_again"))
            return
        }
        presenter.getSharedString(with: cell.id)
    }
    
    private func removeTaskAction(_ indexPath: IndexPath) {
        tableView.beginUpdates()
        if let cell = tableView.cellForRow(at: indexPath) as? TaskViewCell {
            if let index = tasks.firstIndex(where: { $0.id == cell.id }) {
                let taskId = tasks[index].id
                tasks.remove(at: index)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                sendData?(String(localized: "\(tasks.count) tasks"))
                self.presenter.removeTask(id: taskId)
            }
        }
        tableView.reloadData()
        tableView.endUpdates()
    }
}

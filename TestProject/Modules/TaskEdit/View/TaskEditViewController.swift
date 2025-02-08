import UIKit

final class TaskEditViewController: UIViewController {
    
    // MARK: - UI Elements -
    private let groupedView = UIView()
    private let titleTextField = UITextField()
    private let dateLabel = UILabel()
    private let descriptionTextView = UITextView()
    
    // MARK: - Presenter -
    private let presenter = TaskEditPresenter()
    
    // MARK: - Properties -
    var onTaskDeleted: (() -> Void)?
    var id: Int?
    
    // MARK: - Init -
    init(id: Int? = nil) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
        presenter.delegate = self
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.loadTaskData(id: id)
    }
}

private extension TaskEditViewController {
    func setupUI() {
        setupView()
        setupGroupedView()
        setupTitleTextField()
        setupDateLabel()
        setupDescriptionTextField()
        setupConstraints()
    }
    
    func setupView() {
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(toMainScreen))
        navigationItem.leftBarButtonItem = backButton
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(toMainScreen))
        swipeRightGesture.direction = .right
        view.backgroundColor = UIColor(named: "backgroundColor")
        view.addGestureRecognizer(swipeRightGesture)
    }
     
    func setupGroupedView() {
        groupedView.backgroundColor = UIColor(named: "backgroundColor")
        view.addSubview(groupedView)
    }
    
    func setupTitleTextField() {
        titleTextField.placeholder = String(localized: "Title")
        titleTextField.backgroundColor = UIColor(named: "backgroundColor")
        titleTextField.textColor = UIColor(named: "customLabelColor")
        titleTextField.font = UIFont.systemFont(ofSize: 34, weight: .medium)
        titleTextField.delegate = self
        groupedView.addSubview(titleTextField)
    }
    
    func setupDateLabel() {
        dateLabel.textColor = UIColor(named: "colorTextSearchBar")
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        groupedView.addSubview(dateLabel)
    }
    
    func setupDescriptionTextField() {
        descriptionTextView.backgroundColor = UIColor(named: "backgroundColor")
        descriptionTextView.textColor = UIColor(named: "customLabelColor")
        descriptionTextView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionTextView.delegate = self
        descriptionTextView.isScrollEnabled = true
        descriptionTextView.isEditable = true
        descriptionTextView.isSelectable = true
        groupedView.addSubview(descriptionTextView)
    }
    
    func setupConstraints() {
        groupedView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(41)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(16)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
    }
}

// MARK: - Exit to Main screen -
private extension TaskEditViewController  {
    @objc func toMainScreen() {
        doneButtonTapped()
        presenter.checkEmptyTask(id)
        onTaskDeleted?()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextViewDelegate and UITextFieldDelegate -
extension TaskEditViewController: UITextViewDelegate, UITextFieldDelegate {
    @objc private func doneButtonTapped() { view.endEditing(true) }
    
    func textViewDidBeginEditing(_ textView: UITextView) { setupDoneButton() }
    
    func textFieldDidBeginEditing(_ textField: UITextField) { setupDoneButton() }

    func textViewDidEndEditing(_ textView: UITextView) {
        presenter.updateTask(id: id, newDescription: textView.text)
        closeDoneButton()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        presenter.updateTask(id: id, newTitle: textField.text)
        closeDoneButton()
    }
    
    private func setupDoneButton() {
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func closeDoneButton() { navigationItem.rightBarButtonItem = nil }
}

// MARK: - TaskEditProtocol -
extension TaskEditViewController: TaskEditProtocol {
    func setupNewID(with id: Int) {
        self.id = id
    }
    
    func showErrorMessage(_ message: String) {
        showAlert(title: String(localized: "Error"), message: message)
    }
    
    func configureView(with data: TasksViewData?) {
        guard let data else { return }
        titleTextField.text = data.nameTask
        dateLabel.text = data.dateTask
        descriptionTextView.text = data.descriptionTask
    }
}

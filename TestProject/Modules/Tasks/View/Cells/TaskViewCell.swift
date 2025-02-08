import UIKit
import SnapKit

final class TaskViewCell: UITableViewCell {
    
    // MARK: - UI Elements -
    private let customView = UIView()
    private let checkMarkImageView = UIImageView()
    private let innerContentView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    
    // MARK: - Properties -
    public var id = 0
    var onCheckMarkTapped: ((Int) -> Void)?
    var onTaskTapped: ((Int) -> Void)?
    
    // MARK: - Init -
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // configure
    func configure(id: Int, completed: Bool, title: String, description: String, dateString: String) {
        self.id = id
        let titleAttributes: [NSAttributedString.Key: Any]
        
        if completed {
            titleAttributes = [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                               .foregroundColor: UIColor(named: "colorTextSearchBar") ?? UIColor.gray]
        } else {
            titleAttributes = [.foregroundColor: UIColor(named: "customLabelColor") ?? UIColor.black]
        }
        
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        
        titleLabel.attributedText = attributedTitle
        descriptionLabel.text = description
        dateLabel.text = dateString
        checkMarkImageView.image = completed ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle")
        checkMarkImageView.tintColor = completed ? UIColor(named: "addTaskButton") : UIColor(named: "tabBarColor")
        descriptionLabel.textColor = completed ? UIColor(named: "colorTextSearchBar") : UIColor(named: "customLabelColor")
    }
}

private extension TaskViewCell {
    func setupUI() {
        setupView()
        setupCustomView()
        setupCheckMarkImageView()
        setupInnerContentView()
        setupTitleLable()
        setupDescriptionLabel()
        setupDateLabel()
        setupConstraints()
    }
    
    func setupView() {
        backgroundColor = UIColor(named: "backgroundColor")
        contentView.backgroundColor = UIColor(named: "backgroundColor")
    }
    
    func setupCustomView() {
        customView.backgroundColor = UIColor(named: "backgroundColor")
        contentView.addSubview(customView)
    }
    
    func setupInnerContentView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(innerContentTapped))
        innerContentView.addGestureRecognizer(tapGesture)
        innerContentView.backgroundColor = UIColor(named: "backgroundColor")
        customView.addSubview(innerContentView)
    }
    
    func setupCheckMarkImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCheckMarkTapped))
        checkMarkImageView.addGestureRecognizer(tapGesture)
        checkMarkImageView.isUserInteractionEnabled = true
        customView.addSubview(checkMarkImageView)
    }
    
    func setupTitleLable() {
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        innerContentView.addSubview(titleLabel)
    }
    
    func setupDescriptionLabel() {
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textColor = UIColor(named: "customLabelColor")
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        innerContentView.addSubview(descriptionLabel)
    }
    
    func setupDateLabel() {
        dateLabel.textColor = UIColor(named: "colorTextSearchBar")
        dateLabel.lineBreakMode = .byTruncatingTail
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel.numberOfLines = 1
        innerContentView.addSubview(dateLabel)
    }
    
    func setupConstraints() {
        customView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
        }
        
        checkMarkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(12)
        }
        
        innerContentView.snp.makeConstraints { make in
            make.left.equalTo(checkMarkImageView.snp.right).offset(8)
            make.trailing.top.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(22)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(descriptionLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
}

// MARK: - Tap Gesture Action -
private extension TaskViewCell {
    @objc private func innerContentTapped() { onTaskTapped?(id) }
    @objc private func handleCheckMarkTapped() { onCheckMarkTapped?(id) }
}

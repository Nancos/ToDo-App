import UIKit

final class CustomView: UIView {
    
    // MARK: - UI Elements -
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // MARK: - Init -
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // configure view
    func configure(with slide: OnboardingSlide) {
        imageView.image = slide.image
        titleLabel.text = slide.title
        descriptionLabel.text = slide.description
    }
}

private extension CustomView {
    func setupUI() {
        setupView()
        setupImageView()
        setupTitleLabel()
        setupDescriptionLabel()
        setupConstraints()
    }
    
    func setupView() {
        backgroundColor = .white
    }
    func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    func setupTitleLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
    }
    func setupDescriptionLabel() {
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        addSubview(descriptionLabel)
    }
    func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(imageView.snp.width).multipliedBy(1.5)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

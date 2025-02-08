import UIKit
import SnapKit

final class OnboardingViewController: UIViewController {
    // MARK: - UI Elements -
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let continueButton = UIButton()
    
    // MARK: - Presenter -
    private let presenter = OnboardingPresenter()
    
    // MARK: - Properties -
    private let slides: [OnboardingSlide]
    private let isFirstLaunch: Bool
    
    // MARK: - Init -
    init(_ isFirstLaunch: Bool) {
        self.slides = OnboardingSlide.getSlides()
        self.isFirstLaunch = isFirstLaunch
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI
private extension OnboardingViewController {
    func setupUI() {
        setupView()
        setupScrollView()
        setupSlides()
        setupPageControl()
        setupContinueButton()
        setupConstraints()
    }
    
    func setupView() {
        view.backgroundColor = .white
    }
    
    func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        view.addSubview(scrollView)
    }
    
    func setupSlides() {
        for (index, slide) in slides.enumerated() {
            let slideView = CustomView()
            slideView.configure(with: slide)
            slideView.frame = CGRect(x: view.frame.width * CGFloat(index),
                                     y: 0,
                                     width: view.frame.width,
                                     height: view.frame.height)
            scrollView.addSubview(slideView)
        }
    }
    
    func setupPageControl() {
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.numberOfPages = slides.count
        view.addSubview(pageControl)
    }
    
    func setupContinueButton() {
        continueButton.setTitle(String(localized: "Start"), for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = .systemBlue
        continueButton.layer.cornerRadius = 10
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        continueButton.isHidden = true
        view.addSubview(continueButton)
    }
    
    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(continueButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
        }
        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
}

// MARK: - Actions  -
private extension OnboardingViewController {
    @objc func continueButtonTapped() {
        presenter.onboardingCompleted()
        let tabBarVC = TabBarViewController(isFirstLaunch)
        let navigationController = CustomNavigationController(rootViewController: tabBarVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}

// MARK: - UIScrollViewDelegate -
extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        continueButton.isHidden = pageIndex < CGFloat(slides.count - 1)
    }
}

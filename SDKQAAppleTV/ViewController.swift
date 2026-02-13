//
//  ViewController.swift
//  SDKQAAppleTV
//
//  Home: choose Audio or Video category (card style).
//

import UIKit

// Button that switches to light background + dark text when focused so the label stays readable.
private final class CategoryCardButton: UIButton {
    var normalBackground: UIColor?
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        coordinator.addCoordinatedAnimations {
            if context.nextFocusedView === self {
                self.backgroundColor = UIColor(white: 0.92, alpha: 1)
                self.setTitleColor(UIColor(white: 0.2, alpha: 1), for: .normal)
            } else {
                self.backgroundColor = self.normalBackground
                self.setTitleColor(.white, for: .normal)
            }
        }
    }
}

class ViewController: UIViewController {

    private let cardColor = UIColor(red: 0.18, green: 0.42, blue: 0.55, alpha: 1)

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SDK QA"
        label.font = .systemFont(ofSize: 72, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose a category"
        label.font = .systemFont(ofSize: 36, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var audioButton: CategoryCardButton = {
        let btn = CategoryCardButton(type: .system)
        btn.setTitle("Audio", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 44, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = cardColor
        btn.normalBackground = cardColor
        btn.layer.cornerRadius = 20
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(audioTapped), for: .primaryActionTriggered)
        return btn
    }()

    private lazy var videoButton: CategoryCardButton = {
        let btn = CategoryCardButton(type: .system)
        btn.setTitle("Video", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 44, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = cardColor
        btn.normalBackground = cardColor
        btn.layer.cornerRadius = 20
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(videoTapped), for: .primaryActionTriggered)
        return btn
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [audioButton, videoButton])
        stack.axis = .vertical
        stack.spacing = 48
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.08, alpha: 1)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),

            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 120),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -120),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 320),

            audioButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            videoButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
    }

    @objc private func audioTapped() {
        let list = CaseListViewController(category: .audio)
        navigationController?.pushViewController(list, animated: true)
    }

    @objc private func videoTapped() {
        let list = CaseListViewController(category: .video)
        navigationController?.pushViewController(list, animated: true)
    }
}

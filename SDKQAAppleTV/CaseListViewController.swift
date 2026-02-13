//
//  CaseListViewController.swift
//  SDKQAAppleTV
//
//  List of test cases for a category (Audio or Video). Card-style cells.
//

import UIKit

class CaseListViewController: UIViewController {

    private let category: TestCase.Category
    private var cases: [TestCase] = []

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(CaseCell.self, forCellReuseIdentifier: CaseCell.reuseId)
        table.backgroundColor = .clear
        table.backgroundView = nil
        return table
    }()

    init(category: TestCase.Category) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.displayName
        view.backgroundColor = UIColor(white: 0.08, alpha: 1)

        cases = TestCase.cases(for: category)

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 80),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -80),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
}

extension CaseListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CaseCell.reuseId, for: indexPath) as! CaseCell
        cell.configure(with: cases[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let testCase = cases[indexPath.row]
        let detail = CaseDetailViewController(testCase: testCase)
        navigationController?.pushViewController(detail, animated: true)
    }
}

// MARK: - Card-style cell

private class CaseCell: UITableViewCell {

    static let reuseId = "CaseCell"

    private let cardBackground: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.18, alpha: 1)
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 36, weight: .medium)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(cardBackground)
        cardBackground.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            cardBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            titleLabel.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 28),
            titleLabel.centerYAnchor.constraint(equalTo: cardBackground.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardBackground.trailingAnchor, constant: -28)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with testCase: TestCase) {
        titleLabel.text = testCase.title
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        let focused = (context.nextFocusedView === self)
        coordinator.addCoordinatedAnimations {
            self.cardBackground.backgroundColor = focused ? UIColor(white: 0.28, alpha: 1) : UIColor(white: 0.18, alpha: 1)
            self.cardBackground.transform = focused ? CGAffineTransform(scaleX: 1.02, y: 1.02) : .identity
        }
    }
}

//
//  WeatherViewController.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import UIKit

final class WeatherViewController: UIViewController {

    private let viewModel: WeatherViewModel
    private var hourlyItems: [HourlyItemDisplay] = []
    private var dailyItems: [DailyItemDisplay] = []

    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.15, green: 0.35, blue: 0.75, alpha: 1).cgColor,
            UIColor(red: 0.30, green: 0.55, blue: 0.90, alpha: 1).cgColor,
            UIColor(red: 0.45, green: 0.70, blue: 1.0, alpha: 1).cgColor,
        ]
        layer.locations = [0, 0.5, 1]
        return layer
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        return ai
    }()

    private let errorContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let retryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(L10n.Common.retry, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 80, weight: .thin)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let hiLoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let hourlyCard = GlassCardView()

    private lazy var hourlyCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 100)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(HourlyForecastCell.self, forCellWithReuseIdentifier: HourlyForecastCell.reuseID)
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let hourlyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.text = L10n.Weather.hourlyForecast
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let hourlySeparator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let dailyCard = GlassCardView()

    private lazy var dailyTable: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorColor = UIColor.white.withAlphaComponent(0.2)
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.isScrollEnabled = false
        tv.register(DailyForecastCell.self, forCellReuseIdentifier: DailyForecastCell.reuseID)
        tv.dataSource = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let dailyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.text = L10n.Weather.dailyForecast
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dailySeparator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let detailsCard = GlassCardView()

    private let feelsLikeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.text = L10n.Weather.feelsLike
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let feelsLikeValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let humidityCard = GlassCardView()

    private let humidityTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.text = L10n.Weather.humidity
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let humidityValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let windCard = GlassCardView()

    private let windTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.text = L10n.Weather.wind
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let windValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupLayout()
        bindViewModel()
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            self?.applyState(state)
        }
        applyState(viewModel.state)
    }

    private func applyState(_ state: WeatherViewState) {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            scrollView.isHidden = true
            errorContainer.isHidden = true

        case .loaded(let current, let hourly, let daily):
            loadingIndicator.stopAnimating()
            scrollView.isHidden = false
            errorContainer.isHidden = true
            displayCurrentWeather(current)
            hourlyItems = hourly
            hourlyCollection.reloadData()
            dailyItems = daily
            dailyTable.reloadData()

        case .error(let message):
            loadingIndicator.stopAnimating()
            scrollView.isHidden = true
            errorContainer.isHidden = false
            errorLabel.text = L10n.Weather.loadingError(message)
        }
    }

    private func displayCurrentWeather(_ display: CurrentWeatherDisplay) {
        cityLabel.text = display.cityName
        tempLabel.text = display.temperature
        conditionLabel.text = display.conditionText
        hiLoLabel.text = display.hiLoText
        feelsLikeValueLabel.text = display.feelsLike
        humidityValueLabel.text = display.humidity
        windValueLabel.text = display.wind
    }

    @objc private func retryTapped() {
        viewModel.retry()
    }

    private func setupGradient() {
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        view.addSubview(loadingIndicator)
        view.addSubview(errorContainer)
        errorContainer.addSubview(errorLabel)
        errorContainer.addSubview(retryButton)

        contentStack.addArrangedSubview(cityLabel)
        contentStack.addArrangedSubview(tempLabel)
        contentStack.addArrangedSubview(conditionLabel)
        contentStack.addArrangedSubview(hiLoLabel)

        hourlyCard.translatesAutoresizingMaskIntoConstraints = false
        hourlyCard.addSubview(hourlyTitleLabel)
        hourlyCard.addSubview(hourlySeparator)
        hourlyCard.addSubview(hourlyCollection)
        contentStack.addArrangedSubview(hourlyCard)

        dailyCard.translatesAutoresizingMaskIntoConstraints = false
        dailyCard.addSubview(dailyTitleLabel)
        dailyCard.addSubview(dailySeparator)
        dailyCard.addSubview(dailyTable)
        contentStack.addArrangedSubview(dailyCard)

        let detailsRow = UIStackView()
        detailsRow.axis = .horizontal
        detailsRow.spacing = 12
        detailsRow.distribution = .fillEqually
        detailsRow.translatesAutoresizingMaskIntoConstraints = false

        detailsCard.translatesAutoresizingMaskIntoConstraints = false
        detailsCard.addSubview(feelsLikeTitleLabel)
        detailsCard.addSubview(feelsLikeValueLabel)

        humidityCard.translatesAutoresizingMaskIntoConstraints = false
        humidityCard.addSubview(humidityTitleLabel)
        humidityCard.addSubview(humidityValueLabel)

        detailsRow.addArrangedSubview(detailsCard)
        detailsRow.addArrangedSubview(humidityCard)
        contentStack.addArrangedSubview(detailsRow)

        windCard.translatesAutoresizingMaskIntoConstraints = false
        windCard.addSubview(windTitleLabel)
        windCard.addSubview(windValueLabel)

        let windRow = UIStackView()
        windRow.axis = .horizontal
        windRow.spacing = 12
        windRow.distribution = .fillEqually
        windRow.translatesAutoresizingMaskIntoConstraints = false
        windRow.addArrangedSubview(windCard)
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        windRow.addArrangedSubview(spacer)
        contentStack.addArrangedSubview(windRow)

        contentStack.setCustomSpacing(4, after: cityLabel)
        contentStack.setCustomSpacing(4, after: tempLabel)
        contentStack.setCustomSpacing(4, after: conditionLabel)
        contentStack.setCustomSpacing(24, after: hiLoLabel)
        contentStack.setCustomSpacing(12, after: hourlyCard)
        contentStack.setCustomSpacing(12, after: dailyCard)
        contentStack.setCustomSpacing(12, after: detailsRow)

        let dailyHeight: CGFloat = CGFloat(3 * 50)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 60),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -30),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorContainer.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            errorContainer.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),

            errorLabel.topAnchor.constraint(equalTo: errorContainer.topAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: errorContainer.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: errorContainer.trailingAnchor),

            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: errorContainer.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 160),
            retryButton.heightAnchor.constraint(equalToConstant: 44),
            retryButton.bottomAnchor.constraint(equalTo: errorContainer.bottomAnchor),

            hourlyCard.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            hourlyCard.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),

            hourlyTitleLabel.topAnchor.constraint(equalTo: hourlyCard.topAnchor, constant: 12),
            hourlyTitleLabel.leadingAnchor.constraint(equalTo: hourlyCard.leadingAnchor, constant: 16),

            hourlySeparator.topAnchor.constraint(equalTo: hourlyTitleLabel.bottomAnchor, constant: 8),
            hourlySeparator.leadingAnchor.constraint(equalTo: hourlyCard.leadingAnchor, constant: 16),
            hourlySeparator.trailingAnchor.constraint(equalTo: hourlyCard.trailingAnchor, constant: -16),
            hourlySeparator.heightAnchor.constraint(equalToConstant: 0.5),

            hourlyCollection.topAnchor.constraint(equalTo: hourlySeparator.bottomAnchor, constant: 4),
            hourlyCollection.leadingAnchor.constraint(equalTo: hourlyCard.leadingAnchor, constant: 8),
            hourlyCollection.trailingAnchor.constraint(equalTo: hourlyCard.trailingAnchor, constant: -8),
            hourlyCollection.bottomAnchor.constraint(equalTo: hourlyCard.bottomAnchor, constant: -4),
            hourlyCollection.heightAnchor.constraint(equalToConstant: 110),

            dailyCard.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            dailyCard.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),

            dailyTitleLabel.topAnchor.constraint(equalTo: dailyCard.topAnchor, constant: 12),
            dailyTitleLabel.leadingAnchor.constraint(equalTo: dailyCard.leadingAnchor, constant: 16),

            dailySeparator.topAnchor.constraint(equalTo: dailyTitleLabel.bottomAnchor, constant: 8),
            dailySeparator.leadingAnchor.constraint(equalTo: dailyCard.leadingAnchor, constant: 16),
            dailySeparator.trailingAnchor.constraint(equalTo: dailyCard.trailingAnchor, constant: -16),
            dailySeparator.heightAnchor.constraint(equalToConstant: 0.5),

            dailyTable.topAnchor.constraint(equalTo: dailySeparator.bottomAnchor, constant: 4),
            dailyTable.leadingAnchor.constraint(equalTo: dailyCard.leadingAnchor),
            dailyTable.trailingAnchor.constraint(equalTo: dailyCard.trailingAnchor),
            dailyTable.bottomAnchor.constraint(equalTo: dailyCard.bottomAnchor),
            dailyTable.heightAnchor.constraint(equalToConstant: dailyHeight),

            detailsRow.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            detailsRow.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),

            detailsCard.heightAnchor.constraint(equalToConstant: 130),

            feelsLikeTitleLabel.topAnchor.constraint(equalTo: detailsCard.topAnchor, constant: 12),
            feelsLikeTitleLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),

            feelsLikeValueLabel.topAnchor.constraint(equalTo: feelsLikeTitleLabel.bottomAnchor, constant: 8),
            feelsLikeValueLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),

            humidityCard.heightAnchor.constraint(equalToConstant: 130),

            humidityTitleLabel.topAnchor.constraint(equalTo: humidityCard.topAnchor, constant: 12),
            humidityTitleLabel.leadingAnchor.constraint(equalTo: humidityCard.leadingAnchor, constant: 16),

            humidityValueLabel.topAnchor.constraint(equalTo: humidityTitleLabel.bottomAnchor, constant: 8),
            humidityValueLabel.leadingAnchor.constraint(equalTo: humidityCard.leadingAnchor, constant: 16),

            windRow.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            windRow.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),

            windCard.heightAnchor.constraint(equalToConstant: 130),

            windTitleLabel.topAnchor.constraint(equalTo: windCard.topAnchor, constant: 12),
            windTitleLabel.leadingAnchor.constraint(equalTo: windCard.leadingAnchor, constant: 16),

            windValueLabel.topAnchor.constraint(equalTo: windTitleLabel.bottomAnchor, constant: 8),
            windValueLabel.leadingAnchor.constraint(equalTo: windCard.leadingAnchor, constant: 16),
        ])
    }
}

extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hourlyItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCell.reuseID, for: indexPath) as! HourlyForecastCell
        let item = hourlyItems[indexPath.item]
        cell.configure(time: item.time, conditionCode: item.conditionCode, temp: item.temperature)
        return cell
    }
}

extension WeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dailyItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DailyForecastCell.reuseID, for: indexPath) as! DailyForecastCell
        let item = dailyItems[indexPath.row]
        cell.configure(
            dayName: item.dayName,
            conditionCode: item.conditionCode,
            low: item.low,
            high: item.high,
            globalLow: item.globalLow,
            globalHigh: item.globalHigh
        )
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
}

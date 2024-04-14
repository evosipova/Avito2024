//
//  SearchViewController.swift
//  Avito2024
//
//  Created by Elizaveta Osipova on 4/14/24.
//

import UIKit

// MARK: - SearchViewController

class SearchViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate, UICollectionViewDataSource, UITableViewDelegate, UICollectionViewDelegate {
    private var searchTextField: UITextField!
    private var searchHistoryTableView: UITableView!
    private var searchResultsCollectionView: UICollectionView!
    private var searchHistory: [String] = []
    private var searchResults: [MediaItem] = []
    private var filteredSearchHistory: [String] = []
    private var collectionViewTopConstraint: NSLayoutConstraint!
    private let searchService = NetworkService()
    private let imageCache = NSCache<NSString, UIImage>()
    private let noContentLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let errorLabel = UILabel()
    private var filterButton: UIButton!
    private var selectedEntity: String?
    private var searchLimit: Int = 30

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: - UI Configuration

    private func configureUI() {
        setupSearchTextField()
        setupFilterButton()
        setupSearchHistoryTableView()
        setupSearchResultsCollectionView()
        setupNoContentLabel()
        setupLoadingIndicator()
        setupErrorLabel()
        updateCollectionViewTopConstraint()
    }

    private func setupSearchTextField() {
        let totalHorizontalPadding = ConstantsSearchView.sidePadding * 2
        let searchTextFieldWidth = view.frame.width - totalHorizontalPadding * 2.5
        searchTextField = UITextField(frame: CGRect(x: ConstantsSearchView.sidePadding, y: 60, width: searchTextFieldWidth, height: ConstantsSearchView.searchTextFieldHeight))
        searchTextField.delegate = self
        searchTextField.placeholder = "Search..."
        searchTextField.borderStyle = .roundedRect
        searchTextField.layer.cornerRadius = 10

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: searchTextField.frame.height))
        searchTextField.leftView = paddingView
        searchTextField.leftViewMode = .always

        let magnifyingGlassIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        magnifyingGlassIcon.contentMode = .scaleAspectFit
        magnifyingGlassIcon.tintColor = .gray
        magnifyingGlassIcon.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        paddingView.addSubview(magnifyingGlassIcon)

        view.addSubview(searchTextField)
    }

    private func setupFilterButton() {
        filterButton = UIButton(type: .system)
        if let image = UIImage(systemName: "slider.horizontal.3")?.withTintColor(.gray, renderingMode: .alwaysOriginal) {
            filterButton.setImage(image, for: .normal)
        }
        filterButton.addTarget(self, action: #selector(showFilterOptions), for: .touchUpInside)
        filterButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(filterButton)
        NSLayoutConstraint.activate([
            filterButton.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
            filterButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: ConstantsSearchView.sidePadding / 2),
            filterButton.widthAnchor.constraint(equalToConstant: ConstantsSearchView.filterButtonSize),
            filterButton.heightAnchor.constraint(equalToConstant: ConstantsSearchView.filterButtonSize),
            filterButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -ConstantsSearchView.sidePadding)
        ])
    }

    private func setupSearchHistoryTableView() {
        searchHistoryTableView = UITableView(frame: CGRect(x: 0, y: searchTextField.frame.maxY + ConstantsSearchView.defaultPadding, width: view.frame.width, height: ConstantsSearchView.searchHistoryTableHeight), style: .plain)
        searchHistoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        searchHistoryTableView.dataSource = self
        searchHistoryTableView.delegate = self
        searchHistoryTableView.isHidden = true
        searchHistoryTableView.separatorInset = UIEdgeInsets(top: 0, left: ConstantsSearchView.cellSpacing, bottom: 0, right: ConstantsSearchView.cellSpacing)
        view.addSubview(searchHistoryTableView)
    }

    private func setupSearchResultsCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.frame.width - ConstantsSearchView.cellSpacing * 4) / 2, height: ((view.frame.width - ConstantsSearchView.cellSpacing * 4) / 2) + 60)
        layout.minimumInteritemSpacing = ConstantsSearchView.cellSpacing
        layout.minimumLineSpacing = ConstantsSearchView.cellSpacing
        layout.sectionInset = UIEdgeInsets(top: ConstantsSearchView.cellSpacing, left: ConstantsSearchView.cellSpacing, bottom: ConstantsSearchView.cellSpacing, right: ConstantsSearchView.cellSpacing)

        searchResultsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        searchResultsCollectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: "ResultCell")
        searchResultsCollectionView.dataSource = self
        searchResultsCollectionView.delegate = self
        searchResultsCollectionView.backgroundColor = .white
        view.addSubview(searchResultsCollectionView)
        searchResultsCollectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionViewTopConstraint = searchResultsCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: ConstantsSearchView.defaultPadding)
        NSLayoutConstraint.activate([
            collectionViewTopConstraint,
            searchResultsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNoContentLabel() {
        noContentLabel.translatesAutoresizingMaskIntoConstraints = false
        noContentLabel.textAlignment = .center
        noContentLabel.text = "Nothing found"
        noContentLabel.isHidden = true
        view.addSubview(noContentLabel)

        NSLayoutConstraint.activate([
            noContentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noContentLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noContentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ConstantsSearchView.sidePadding),
            noContentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ConstantsSearchView.sidePadding)
        ])
    }

    private func setupLoadingIndicator() {
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
    }

    private func setupErrorLabel() {
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        view.addSubview(errorLabel)
    }

    // MARK: - Helper Methods

    private func updateCollectionViewTopConstraint() {
        let topConstraintConstant = searchHistoryTableView.isHidden ? ConstantsSearchView.defaultPadding : searchHistoryTableView.contentSize.height + ConstantsSearchView.defaultPadding
        collectionViewTopConstraint.constant = topConstraintConstant
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    private func toggleSearchHistoryVisibility() {
        searchHistoryTableView.isHidden = !searchHistoryTableView.isHidden
        updateCollectionViewTopConstraint()
    }

    private func filterSearchHistory(searchTerm: String) {
        filteredSearchHistory = searchTerm.isEmpty ? searchHistory : searchHistory.filter { $0.lowercased().contains(searchTerm.lowercased()) }
        searchHistoryTableView.reloadData()
        updateCollectionViewTopConstraint()
    }

    private func updateSearchHistory(searchTerm: String) {
        if let index = searchHistory.firstIndex(of: searchTerm) {
            searchHistory.remove(at: index)
        }
        searchHistory.insert(searchTerm, at: 0)
        if searchHistory.count > ConstantsSearchView.searchHistoryLimit {
            searchHistory = Array(searchHistory.prefix(ConstantsSearchView.searchHistoryLimit))
        }
        searchHistoryTableView.reloadData()
    }

    private func showLoading() {
        loadingIndicator.startAnimating()
        noContentLabel.isHidden = true
        errorLabel.isHidden = true
    }

    private func hideLoading() {
        loadingIndicator.stopAnimating()
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func updateNoContentLabel() {
        noContentLabel.isHidden = !searchResults.isEmpty
    }

    // MARK: - Search and Filtering Actions

    @objc private func showFilterOptions() {
        let alertController = UIAlertController(title: "Filter Options", message: "Apply filters to your search", preferredStyle: .actionSheet)

        let filterActions = [("All", nil), ("Movies", "movie"), ("Music Videos", "musicVideo"), ("Podcasts", "podcast"), ("Audiobooks", "audiobook")]
        filterActions.forEach { (title, entity) in
            alertController.addAction(UIAlertAction(title: title, style: .default) { _ in
                self.applyFilter(entity: entity)
            })
        }

        alertController.addAction(UIAlertAction(title: "Change Search Limit", style: .default) { _ in
            self.promptForSearchLimit()
        })

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }

    private func applyFilter(entity: String?) {
        selectedEntity = entity
        if let searchTerm = searchTextField.text, !searchTerm.isEmpty {
            performSearch(searchTerm: searchTerm, entity: selectedEntity)
        }
    }

    private func promptForSearchLimit() {
        let alertController = UIAlertController(title: "Set Search Limit", message: "Enter the number of results you want to display", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.text = "\(self.searchLimit)"
        }
        let confirmAction = UIAlertAction(title: "Set", style: .default) { _ in
            if let textField = alertController.textFields?.first,
               let text = textField.text,
               let limit = Int(text) {
                self.searchLimit = limit
                self.performSearch(searchTerm: self.searchTextField.text ?? "", entity: self.selectedEntity)
            }
        }
        alertController.addAction(confirmAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }

    private func performSearch(searchTerm: String, entity: String? = nil) {
        showLoading()
        searchResults.removeAll()
        searchResultsCollectionView.reloadData()

        let searchEntities = entity != nil ? [entity!] : ["musicVideo", "movie", "podcast", "audiobook"]
        let group = DispatchGroup()

        searchEntities.forEach { entity in
            group.enter()
            searchService.searchMedia(searchTerm: searchTerm, entity: entity, limit: searchLimit) { [weak self] result in
                defer { group.leave() }
                switch result {
                case .success(let searchResult):
                    let limitedResults = Array(searchResult.results.prefix(self?.searchLimit ?? 0))
                    self?.searchResults.append(contentsOf: limitedResults)
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showError(error.localizedDescription)
                    }
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.hideLoading()
            self?.searchResultsCollectionView.reloadData()
            self?.updateNoContentLabel()
        }
    }

    // MARK: - UITableViewDataSource & UITableViewDelegate Methods

    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSearchHistory.count
    }

    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        cell.textLabel?.text = filteredSearchHistory[indexPath.row]
        return cell
    }

    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchTerm = filteredSearchHistory[indexPath.row]
        searchTextField.text = searchTerm
        performSearch(searchTerm: searchTerm)
        searchHistoryTableView.isHidden = true
        updateCollectionViewTopConstraint()
    }

    // MARK: - UICollectionViewDataSource & UICollectionViewDelegate Methods

    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(searchResults.count, searchLimit)
    }

    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultCell", for: indexPath) as! SearchResultCell
        let mediaItem = searchResults[indexPath.item]
        let cachedImage = imageCache.object(forKey: mediaItem.artworkUrl100! as NSString)
        cell.configure(with: mediaItem, cachedImage: cachedImage)
        return cell
    }

    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mediaItem = searchResults[indexPath.item]
        let detailViewController = DetailViewController()
        detailViewController.mediaItem = mediaItem
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    // MARK: - UITextFieldDelegate Methods

    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        toggleSearchHistoryVisibility()
    }

    @objc(textField:shouldChangeCharactersInRange:replacementString:) func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        filterSearchHistory(searchTerm: updatedText)
        return true
    }

    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let searchTerm = textField.text, !searchTerm.isEmpty {
            updateSearchHistory(searchTerm: searchTerm)
            performSearch(searchTerm: searchTerm)
        }
        searchHistoryTableView.isHidden = true
        updateCollectionViewTopConstraint()
        return true
    }
}

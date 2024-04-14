import UIKit

class DetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var mediaItem: MediaItem?

    private let artworkImageView = UIImageView()
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private let typeLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let artistLinkButton = UIButton(type: .system)
    private let trackLinkButton = UIButton(type: .system)
    private let trackTimeLabel = UILabel()
    private let priceLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var similarWorksCollectionView: UICollectionView!
    private var similarWorks = [MediaItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        configureWithMediaItem()
    }

    // MARK: - Setup UI Configuration
    private func configureUI() {
        setupNavigationBar()
        setupScrollView()
        setupViews()
        setupSimilarWorksCollectionView()
    }

    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        let backButtonImage = UIImage(systemName: "arrowshape.turn.up.left")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIButton(type: .system)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        backButton.frame = CGRect(x: -12, y: 0, width: 34, height: 44)
        containerView.addSubview(backButton)

        let backButtonItem = UIBarButtonItem(customView: containerView)
        navigationItem.leftBarButtonItem = backButtonItem
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Setup Scroll View
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Setup Views
    private func setupViews() {
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        setupLabel(titleLabel, fontSize: 20, fontWeight: .bold)
        setupLabel(artistLabel, fontSize: 18)
        setupLabel(typeLabel, fontSize: 16)
        setupLabel(descriptionLabel, fontSize: 14)
        setupLabel(trackTimeLabel, fontSize: 14, textColor: .gray)
        setupLabel(priceLabel, fontSize: 14, textColor: .gray)

        descriptionLabel.numberOfLines = 0

        setupButton(artistLinkButton, title: "Artist Info", action: #selector(openArtistURL))
        setupButton(trackLinkButton, title: "Materials Info", action: #selector(openTrackURL))

        setupArtworkImageView()
        layoutViews()
    }

    private func setupLabel(_ label: UILabel, fontSize: CGFloat, fontWeight: UIFont.Weight? = nil, textColor: UIColor = .black) {
        label.font = fontWeight != nil ? UIFont.systemFont(ofSize: fontSize, weight: fontWeight!) : UIFont.systemFont(ofSize: fontSize)
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
    }

    private func setupButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
    }

    private func setupArtworkImageView() {
        artworkImageView.layer.cornerRadius = 16
        artworkImageView.clipsToBounds = true
        artworkImageView.contentMode = .scaleAspectFill
        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(artworkImageView)
    }

    private func layoutViews() {
        let views = [titleLabel, artistLabel, typeLabel, descriptionLabel, trackTimeLabel, priceLabel, trackLinkButton, artistLinkButton]
        var lastView: UIView = artworkImageView

        NSLayoutConstraint.activate([
            artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            artworkImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            artworkImageView.widthAnchor.constraint(equalToConstant: 150),
            artworkImageView.heightAnchor.constraint(equalTo: artworkImageView.widthAnchor)
        ])

        for view in views {
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 8),
                view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
            ])
            lastView = view
        }

        contentView.bottomAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 20).isActive = true
    }

    // MARK: - Setup Collection View for Similar Works
    private func setupSimilarWorksCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 150)

        similarWorksCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        similarWorksCollectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: "SimilarWorkCell")
        similarWorksCollectionView.dataSource = self
        similarWorksCollectionView.delegate = self
        similarWorksCollectionView.backgroundColor = .white
        similarWorksCollectionView.showsHorizontalScrollIndicator = false
        similarWorksCollectionView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(similarWorksCollectionView)

        NSLayoutConstraint.activate([
            similarWorksCollectionView.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            similarWorksCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            similarWorksCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            similarWorksCollectionView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    private func configureWithMediaItem() {
        loadSimilarWorks()
        titleLabel.text = mediaItem?.trackName
        artistLabel.text = mediaItem?.artistName
        typeLabel.text = mediaItem?.kind?.capitalized ?? mediaItem?.wrapperType?.capitalized
        descriptionLabel.text = mediaItem?.description ?? ""

        if let urlString = mediaItem?.artworkUrl100, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self?.artworkImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }

        if let trackTimeMillis = mediaItem?.trackTimeMillis {
            let minutes = trackTimeMillis / 60000
            let seconds = (trackTimeMillis / 1000) % 60
            trackTimeLabel.text = "Duration: \(minutes) min \(seconds) sec"
        }

        if let price = mediaItem?.trackPrice, let currency = mediaItem?.currency {
            priceLabel.text = "Price: \(price) \(currency)"
        }
    }

    @objc private func openTrackURL(_ sender: UIButton) {
        guard let urlString = mediaItem?.trackViewUrl, let url = URL(string: urlString) else {
            print("URL is invalid")
            return
        }
        UIApplication.shared.open(url)
    }

    @objc private func openArtistURL() {
        if let artistViewURLString = mediaItem?.artistViewUrl, let url = URL(string: artistViewURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func loadSimilarWorks() {
        guard let artistName = mediaItem?.artistName else { return }
        NetworkService().searchMedia(searchTerm: artistName, entity: "album", limit: 5) { [weak self] result in
            switch result {
            case .success(let searchResult):
                DispatchQueue.main.async {
                    self?.similarWorks = searchResult.results
                    self?.similarWorksCollectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return similarWorks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimilarWorkCell", for: indexPath) as? SearchResultCell else {
            return UICollectionViewCell()
        }
        let work = similarWorks[indexPath.item]
        cell.configure(with: work, cachedImage: nil)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMediaItem = similarWorks[indexPath.item]
        showDetailViewController(for: selectedMediaItem)
    }

    private func showDetailViewController(for mediaItem: MediaItem) {
        let detailViewController = DetailViewController()
        detailViewController.mediaItem = mediaItem
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

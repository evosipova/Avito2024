//
//  SearchResultCell.swift
//  Avito2024
//
//  Created by Elizaveta Osipova on 4/14/24.
//

import Foundation
import UIKit

// MARK: - SearchResultCell Definition
class SearchResultCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let wrapperTypeLabel = UILabel()
    
    let imageView = UIImageView()
    private let imageLoader = ImageLoader()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Setup
extension SearchResultCell {
    private func setupCell() {
        setupImageView()
        setupLabels()
        addSubviews()
        setupConstraints()
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
        contentView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = ConstantsResultCell.cornerRadius
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = ConstantsResultCell.placeholderImage
    }
    
    private func setupLabels() {
        configureLabel(titleLabel, fontSize: ConstantsResultCell.titleLabelFontSize, fontWeight: .bold)
        configureLabel(detailLabel, fontSize: ConstantsResultCell.detailLabelFontSize, textColor: .gray)
        configureLabel(wrapperTypeLabel, fontSize: ConstantsResultCell.wrapperTypeLabelFontSize, textColor: .lightGray)
    }
    
    private func configureLabel(_ label: UILabel, fontSize: CGFloat, fontWeight: UIFont.Weight? = nil, textColor: UIColor? = nil) {
        label.font = fontWeight != nil ? UIFont.systemFont(ofSize: fontSize, weight: fontWeight!) : UIFont.systemFont(ofSize: fontSize)
        label.textColor = textColor ?? .black
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addSubviews() {
        contentView.layer.cornerRadius = ConstantsResultCell.cornerRadius
        contentView.clipsToBounds = true
        [imageView, titleLabel, detailLabel, wrapperTypeLabel].forEach(contentView.addSubview)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: ConstantsResultCell.verticalSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstantsResultCell.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstantsResultCell.horizontalPadding),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: ConstantsResultCell.verticalSpacing),
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstantsResultCell.horizontalPadding),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstantsResultCell.horizontalPadding),
            
            wrapperTypeLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: ConstantsResultCell.verticalSpacing),
            wrapperTypeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstantsResultCell.horizontalPadding),
            wrapperTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstantsResultCell.horizontalPadding)
        ])
    }
}

// MARK: - Image Loading and Configuration
extension SearchResultCell {
    func configure(with mediaItem: MediaItem, cachedImage: UIImage?) {
        titleLabel.text = mediaItem.trackName
        detailLabel.text = mediaItem.artistName
        wrapperTypeLabel.text = mediaItem.wrapperType?.capitalized
        
        if let image = cachedImage {
            imageView.image = image
            activityIndicator.stopAnimating()
        } else if let urlString = mediaItem.artworkUrl100 {
            activityIndicator.startAnimating()
            imageLoader.loadImage(urlString: urlString) { [weak self] result in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    switch result {
                    case .success(let image):
                        self?.imageView.image = image
                    case .failure:
                        self?.imageView.image = ConstantsResultCell.fallbackImage
                        print("Error loading image: Displaying fallback image.")
                    }
                }
            }
        }
    }
}

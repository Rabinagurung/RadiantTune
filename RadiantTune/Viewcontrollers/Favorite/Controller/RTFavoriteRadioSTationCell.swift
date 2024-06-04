//import UIKit
//
//class RTFavoriteRadioSTationCell: UITableViewCell {
//    
//    var logoImageView: UIImageView!
//    var nameLabel: UILabel!
//    var detailLabel: UILabel!
//    var favoriteButton: UIButton!
//    var isFavorite: Bool = true {
//        didSet {
//            let imageName = isFavorite ? "star.fill" : "star"
//            favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
//        }
//    }
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupViews()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupViews() {
//        logoImageView = UIImageView()
//        logoImageView.translatesAutoresizingMaskIntoConstraints = false
//        logoImageView.contentMode = .scaleAspectFit
//        contentView.addSubview(logoImageView)
//        
//        nameLabel = UILabel()
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(nameLabel)
//        
//        detailLabel = UILabel()
//        detailLabel.translatesAutoresizingMaskIntoConstraints = false
//        detailLabel.textColor = .gray
//        contentView.addSubview(detailLabel)
//        
//        favoriteButton = UIButton(type: .system)
//        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
//        favoriteButton.tintColor = .systemBlue
//        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
//        contentView.addSubview(favoriteButton)
//        
//        NSLayoutConstraint.activate([
//            logoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            logoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            logoImageView.widthAnchor.constraint(equalToConstant: 50),
//            logoImageView.heightAnchor.constraint(equalToConstant: 50),
//            
//            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
//            nameLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 10),
//            nameLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -10),
//            
//            detailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
//            detailLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 10),
//            detailLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -10),
//            detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
//            
//            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
//            favoriteButton.heightAnchor.constraint(equalToConstant: 44)
//        ])
//    }
//    
//    @objc func toggleFavorite() {
//        isFavorite.toggle()
//        // Add logic to update the model and save the state as needed
//    }
//    
//    func configure(with station: RTFavoriteModel) {
//        nameLabel.text = station.name
//        detailLabel.text = "\(station.location) | \(station.genre)"
//        isFavorite = station.isFavorite
//        logoImageView.image = UIImage(named: station.name) // Assuming the image name is the same as the station name
//    }
//}

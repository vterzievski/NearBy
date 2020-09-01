//
//  NearByLocationTableViewCell.swift
//  NearByApp
//
//  Created by Vladimir Terzievski on 9/1/20.
//  Copyright © 2020 Vladimir Terzievski. All rights reserved.
//

import UIKit
import SDWebImage

class NearByLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var locationimageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateCellWithModel(model:NearByLocations) {
        name.text = model.name
        address.text = model.address
        if let photoPrefix = model.photoPrefix,  let photoSuffix = model.photoSuffix {
           // let urlString =  String(format: "https://api.foursquare.com/v2/photos?%@&client_id=%@&client_secret=%@", model.photoId!,NetworkManager.shared.clientId,NetworkManager.shared.clientSickret)
            // https://igx.4sqi.net/img/general/300x500/5163668_xXFcZo7sU8aa1ZMhiQ2kIP7NllD48m7qsSwr1mJnFj4.jpg
            // &oauth_token=XXXX


            
            let urlString = String(format: "%@/32x32/&client_id=%@&client_secret=%@%@", photoPrefix,NetworkManager.shared.clientId,NetworkManager.shared.clientSickret, photoSuffix)
            
            locationimageView.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "placeholder.png"))
        }
        
    }
    
}


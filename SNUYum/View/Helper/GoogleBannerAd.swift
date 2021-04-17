//
//  GoogleBannerAd.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/05.
//

import SwiftUI
import GoogleMobileAds

struct GoogleBannerAd: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        let viewController = UIViewController()
        #if DEBUG
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #else
        bannerView.adUnitID = PrivateData.bannerID
        #endif
        bannerView.rootViewController = viewController
        viewController.view.addSubview(bannerView)
        let viewWidth = viewController.view.frame.size.width
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth - 16)
        bannerView.load(GADRequest())
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}

struct GoogleBannerAd_Previews: PreviewProvider {
    static var previews: some View {
        GoogleBannerAd()
    }
}

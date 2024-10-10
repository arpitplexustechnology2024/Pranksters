//
//  CoverViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 09/10/24.
//

import UIKit
import AVFoundation
import MobileCoreServices

struct FunnyAudioItem {
    let imageName: String
}

struct UploadAudioItem {
    let imageName: String
}

class CoverViewController: UIViewController, UIDocumentPickerDelegate {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var AudioShowView: UIView!
    @IBOutlet weak var floatingButton: UIButton!
    
    @IBOutlet var floatingCollectionButton: [UIButton]!
    
    @IBOutlet weak var uploadCollectionView: UICollectionView!
    @IBOutlet weak var funnyCollectionView: UICollectionView!
    @IBOutlet weak var AudioImage: UIImageView!
    
    var audioPlayer: AVPlayer?
    var isPlaying = false
    var currentAudio: FunnyAudioItem?
    var timeObserver: Any?
    var loader: UIActivityIndicatorView?
    var overlayView: UIView?
    
    var funnyAudioItems = [
        FunnyAudioItem(imageName: "ModiSinger"),
        FunnyAudioItem(imageName: "Elvish"),
        FunnyAudioItem(imageName: "PunitStar"),
        FunnyAudioItem(imageName: "Bhaov"),
        FunnyAudioItem(imageName: "PrankStarGauswami"),
        FunnyAudioItem(imageName: "Aashish"),
        FunnyAudioItem(imageName: "CharryMinati"),
        FunnyAudioItem(imageName: "Sharma")
    ]
    
    var uploadAudioItems: [UploadAudioItem] = []
    
    let plusImage = UIImage(named: "Plus")
    let cancelImage = UIImage(named: "Cancel")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.revealViewController()?.gestureEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.revealViewController()?.gestureEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addBottomShadow(to: navigationbarView)
        bottomView.layer.cornerRadius = 28
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomScrollView.layer.cornerRadius = 28
        bottomScrollView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        floatingButton.setImage(plusImage, for: .normal)
        floatingButton.layer.cornerRadius = 19
        for button in floatingCollectionButton {
            button.layer.cornerRadius = 19
            button.clipsToBounds = true
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.25
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
            button.layer.masksToBounds = false
        }
        
        AudioImage.layer.cornerRadius = 8
        AudioShowView.layer.cornerRadius = 8
        
        funnyCollectionView.delegate = self
        funnyCollectionView.dataSource = self
        uploadCollectionView.delegate = self
        uploadCollectionView.dataSource = self
        
        floatingCollectionButton.forEach { btn in
            btn.isHidden = true
            btn.alpha = 0
        }
    }
    
    func addBottomShadow(to view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 7)
        view.layer.shadowRadius = 12
        view.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                          y: view.bounds.maxY - 4,
                                                          width: view.bounds.width,
                                                          height: 4)).cgPath
    }
    
    @IBAction func btnFloatingTapped(_ sender: UIButton) {
        floatingCollectionButton.forEach { btn in
            UIView.animate(withDuration: 0.5) {
                btn.isHidden = !btn.isHidden
                btn.alpha = btn.alpha == 0 ? 1 : 0
            }
        }
        
        if floatingButton.currentImage == plusImage {
                    floatingButton.setImage(cancelImage, for: .normal)
                } else {
                    floatingButton.setImage(plusImage, for: .normal)
                }
    }
    
    @IBAction func btnMoreAppTapped(_ sender: UIButton) {
        animate(toggel: false)
        floatingButton.setImage(plusImage, for: .normal)
    }
    
    @IBAction func btnFavouriteTapped(_ sender: UIButton) {
        animate(toggel: false)
        floatingButton.setImage(plusImage, for: .normal)
    }
    
    @IBAction func btnPremiumTapped(_ sender: UIButton) {
        animate(toggel: false)
        floatingButton.setImage(plusImage, for: .normal)
    }
    
    
    func animate(toggel: Bool) {
        if toggel {
            floatingCollectionButton.forEach { btn in
                UIView.animate(withDuration: 0.5) {
                    btn.isHidden = false
                    btn.alpha = btn.alpha == 0 ? 1 : 0
                }
            }
        } else {
            floatingCollectionButton.forEach { btn in
                UIView.animate(withDuration: 0.5) {
                    btn.isHidden = true
                    btn.alpha = btn.alpha == 0 ? 1 : 0
                }
            }
        }
    }
    
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        guard let duration = audioPlayer?.currentItem?.duration.seconds else { return }
        let newTime = CMTime(seconds: Double(sender.value) * duration, preferredTimescale: 600)
        audioPlayer?.seek(to: newTime)
    }
    
    func playAudio(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        showLoaderAndOverlay()
        
        if let timeObserver = timeObserver {
            audioPlayer?.removeTimeObserver(timeObserver)
        }
        
        audioPlayer = AVPlayer(url: url)
        audioPlayer?.play()
        isPlaying = true
        
        audioPlayer?.currentItem?.asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let duration = self.audioPlayer?.currentItem?.asset.duration.seconds, !duration.isNaN {
                    let minutes = Int(duration) / 60
                    let seconds = Int(duration) % 60
                    
                    self.removeLoaderAndOverlay()
                }
            }
        }
        
        timeObserver = audioPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self,
                  let duration = self.audioPlayer?.currentItem?.duration.seconds,
                  !duration.isNaN,
                  duration > 0 else { return }
            
            let progress = Float(time.seconds / duration)
        }
    }
    
    func openMusicPicker() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeAudio as String, kUTTypeMP3 as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        let fileName = selectedFileURL.lastPathComponent
        
        AudioImage.image = UIImage(named: "Vijudi")
        
        let newAudioItem = UploadAudioItem(imageName: "Vijudi")
        uploadAudioItems.append(newAudioItem)
        
        uploadCollectionView.reloadData()
        
        playAudio(from: selectedFileURL.absoluteString)
    }
    
    // MARK: - Loader and Overlay Functions
    func showLoaderAndOverlay() {
        
        overlayView = UIView(frame: AudioShowView.bounds)
        overlayView?.backgroundColor = UIColor(red: 247/255, green: 242/255, blue: 250/255, alpha: 1.0)
        AudioShowView.addSubview(overlayView!)
        
        loader = UIActivityIndicatorView(style: .large)
        loader?.center = overlayView!.center
        loader?.startAnimating()
        overlayView?.addSubview(loader!)
    }
    
    func removeLoaderAndOverlay() {
        loader?.stopAnimating()
        loader?.removeFromSuperview()
        overlayView?.removeFromSuperview()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension CoverViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == funnyCollectionView {
            return funnyAudioItems.count
        } else if collectionView == uploadCollectionView {
            return uploadAudioItems.count + 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == funnyCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FunnyCollectionCell", for: indexPath) as! FunnyCollectionCell
            cell.imageView.image = UIImage(named: funnyAudioItems[indexPath.item].imageName)
            return cell
        } else if collectionView == uploadCollectionView {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddAudioCollectionCell", for: indexPath) as! AddAudioCollectionCell
                cell.imageView.image = UIImage(named: "Audio")
                cell.AddAudioLabel.text = "Add Audio"
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadCollectionCell", for: indexPath) as! UploadCollectionCell
                let uploadItem = uploadAudioItems[indexPath.item - 1]
                cell.imageView.image = UIImage(named: uploadItem.imageName)
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == funnyCollectionView {
            let selectedAudioItem = funnyAudioItems[indexPath.item]
            AudioImage.image = UIImage(named: selectedAudioItem.imageName)
        } else if collectionView == uploadCollectionView {
            if indexPath.item == 0 {
                openMusicPicker()
            } else {
                let selectedAudioItem = uploadAudioItems[indexPath.item - 1]
                AudioImage.image = UIImage(named: selectedAudioItem.imageName)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CoverViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == uploadCollectionView {
            if indexPath.item == 0 {
                return CGSize(width: 115, height: 125)
            }
        }
        return CGSize(width: 115, height: 125)
    }
}


// MARK: - AddAudioCollectionCell
class AddAudioCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var AddAudioLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
}

// MARK: - UploadCollectionCell
class UploadCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
}

// MARK: - FunnyCollectionCell
class FunnyCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
}

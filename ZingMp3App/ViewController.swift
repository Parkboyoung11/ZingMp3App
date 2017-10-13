//
//  ViewController.swift
//  ZingMp3App
//
//  Created by VuHongSon on 8/8/17.
//  Copyright © 2017 VuHongSon. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lblSongName: UILabel!
    @IBOutlet weak var lblArtist: UILabel!
    @IBOutlet weak var sldVolume: UISlider!
    @IBOutlet weak var imgThumbail: UIImageView!
    @IBOutlet weak var pgrTime: UIProgressView!
    @IBOutlet weak var lblLoading: UILabel!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblCurrentTime: UILabel!
    
    var player : AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        searchBar.keyboardType = UIKeyboardType.default
        searchBar.delegate = self
        sldVolume.setThumbImage(#imageLiteral(resourceName: "thumbs"), for: .normal)
        sldVolume.setThumbImage(#imageLiteral(resourceName: "thumbss"), for: .highlighted)
    }

    func searchMusic(key : String){
        let keyDidEncode = key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let keyUrl :NSURL = NSURL(string: "http://sonvuhong.com/getid.php?keySearch=.\(keyDidEncode)")!
        let queue = DispatchQueue(label: "queue 1")
        queue.async {
            do{
                let keyOld:String = try NSString(contentsOf: keyUrl as URL, encoding: String.Encoding.utf8.rawValue) as String
                let key = keyOld.substring(to: keyOld.index(keyOld.startIndex, offsetBy: 33))
                
                let start = keyOld.index(keyOld.startIndex, offsetBy: 33)
                let end = keyOld.index(keyOld.endIndex, offsetBy: -4)
                let range = start..<end
                let coverImageLink = keyOld.substring(with: range)
                if key == "0\" title" {
                    DispatchQueue.main.async {
                        self.loadToDefault()
                        self.lblLoading.isHidden = true
                    }
                    return
                }
                let url : URL = NSURL(string: "http://mp3.zing.vn/html5xml/song-xml/\(key)")! as URL
                let task = URLSession.shared.dataTask(with: url) { (data, respone, error) in
                    if error == nil {
                        do{
                            let results = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                            let resultss = results["data"] as! [[String: Any]]
                            let result = resultss[0]
                            let name = result["name"] as! String
                            let arrResult = result["source_list"] as! [String]
                            let artist = result["artist"] as! String
                            let link = "http://\(arrResult[1])"
                            let queue2 = DispatchQueue(label: "queue2")
                            queue2.async {
                                let url:URL = URL(string: link)!
                                do{
                                    let data = try Data(contentsOf: url)
                                    do{
                                        self.player = try AVAudioPlayer(data: data)
                                        self.player.numberOfLoops = -1
                                        if self.player.play() {
                                            DispatchQueue.main.async {
                                                self.lblLoading.isHidden = true
                                                self.btnPause.isHidden = false
                                                self.pgrTime.isHidden = false
                                                self.player.volume = self.sldVolume.value
                                                self.sldVolume.isHidden = false
                                                self.updateSong()
                                                self.lblCurrentTime.isHidden = false
                                            }
                                        }
                                    }catch {}
                                }catch {}
                            }
                            
                            let queue3 = DispatchQueue(label: "queue3")
                            queue3.async {
                                let imgUrl:URL = URL(string: coverImageLink)!
//                                let imgUrl:URL = URL(string: "https://zmp3-photo-td.zadn.vn/thumb/240_240/avatars/f/b/fb90de160414db440736ee815f22c238_1499918124.jpg")!
                                do{
                                    let data = try Data(contentsOf: imgUrl)
                                    DispatchQueue.main.async {
                                        self.imgThumbail.image = UIImage(data: data)
                                        self.lblSongName.text = name
                                        self.lblArtist.text = artist
                                        self.lblSongName.isHidden = false
                                        self.lblArtist.isHidden = false
                                    }
                                }catch {
                                    DispatchQueue.main.async {
                                        self.lblSongName.text = name
                                        self.lblArtist.text = artist
                                        self.lblSongName.isHidden = false
                                        self.lblArtist.isHidden = false
                                    }
                                }
                            }
                        } catch {
                            print("JSON ERROR!")
                        }
                    }else {
                        print("TASK ERROR!")
                    }
                    
                }
                task.resume()
            }catch {
                print("Encode Error!")
            }
        }
    }
    
    func loadToDefault() {
        if player != nil {
            player.stop()
        }
        self.lblSongName.isHidden = true
        self.lblArtist.isHidden = true
        self.imgThumbail.image = #imageLiteral(resourceName: "fury")
        self.sldVolume.isHidden = true
        self.pgrTime.setProgress(0, animated: true)
        self.pgrTime.isHidden = true
        self.lblLoading.isHidden = false
        self.btnPlay.isHidden = true
        self.btnPause.isHidden = true
        self.lblCurrentTime.isHidden = true
    }
    
    func updateSong() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (time) in
            UIView.animate(withDuration: 0.5, animations: {
                self.pgrTime.setProgress(Float(self.player.currentTime / self.player.duration), animated: true)
                let duration = self.convertSecToMin(secs: Int(self.player.duration))
                let current = self.convertSecToMin(secs: Int(self.player.currentTime))
                self.lblCurrentTime.text = current + "/" + duration
                
            })
        }
    }
    
    func convertSecToMin(secs: Int) -> String {
        let min = Int(secs / 60)
        let sec = Int(secs % 60)
        let minStr : String = String(format: "%02d:%02d", min, sec)
        return minStr
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadToDefault()
        if searchBar.text != "" {
            lblLoading.isHidden = false
            searchMusic(key: searchBar.text!)
        }
        searchBar.resignFirstResponder()
    }
    
    @IBAction func sldVolumeDid(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    @IBAction func btnPauseDid(_ sender: UIButton) {
        player.pause()
        self.btnPause.isHidden = true
        self.btnPlay.isHidden = false
    }
    
    @IBAction func btnPlayDid(_ sender: UIButton) {
        player.play()
        updateSong()
        self.btnPause.isHidden = false
        self.btnPlay.isHidden = true
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}


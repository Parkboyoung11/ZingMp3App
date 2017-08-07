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

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var txtSearch: UITextField!
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
        txtSearch.delegate = self
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func searchMusic(key : String){
        let keyDidEncode = key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let keyUrl :NSURL = NSURL(string: "http://sonvuhong.com/getid.php?keySearch=.\(keyDidEncode)")!
        let queue = DispatchQueue(label: "queue 1")
        queue.async {
            do{
                let keyOld:String = try NSString(contentsOf: keyUrl as URL, encoding: String.Encoding.utf8.rawValue) as String
                let key = keyOld.substring(to: keyOld.index(keyOld.startIndex, offsetBy: 8))
                let endUrl = "{\"id\":\"\(key)\"}"
                let endUrlEncoded = endUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url:URL = NSURL(string: "http://api.mp3.zing.vn/api/mobile/song/getsonginfo?requestdata=\(endUrlEncoded)")! as URL
                let task = URLSession.shared.dataTask(with: url) { (data, respone, error) in
                    if error == nil {
                        do{
                            let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                            let arrResult = result["source"] as! [String: Any]
                            let cover = result["thumbnail"] as! String
                            let name = result["title"] as! String
                            let artist = result["artist"] as! String
                            let queue2 = DispatchQueue(label: "queue2")
                            if let link = arrResult["128"]{
                                print(link as! String)
                                queue2.async {
                                    let url:URL = URL(string: link as! String)!
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
                                                    self.player.volume = 1
                                                    self.sldVolume.isHidden = false
                                                    self.updateSong()
                                                    self.lblCurrentTime.isHidden = false
                                                }
                                            }
                                        }catch {}
                                    }catch {}
                                }
                            } else{
                                print("Link Error!")
                            }
                            
                            let queue3 = DispatchQueue(label: "queue3")
                            queue3.async {
                                let imgUrl:URL = URL(string: "http://zmp3-photo-fbcrawler-td.zadn.vn/thumb/600_600/\(cover)")!
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
    
    @IBAction func btnSearchDid(_ sender: UIButton) {
        loadToDefault()
        if txtSearch.text != "" {
            lblLoading.isHidden = false
            searchMusic(key: txtSearch.text!)
        }
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

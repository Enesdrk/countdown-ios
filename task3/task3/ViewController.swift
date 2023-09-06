//
//  ViewController.swift
//  task3
//
//  Created by Enes on 3.09.2023.
//

import UIKit
import UserNotifications
class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtMinutes: UITextField!
    @IBOutlet weak var txtSeconds: UITextField!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    
    var countdownTimer: Timer?
    var isCountdownRunning = false
    var remainingSeconds = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let cdNotification = UNUserNotificationCenter.current()
        cdNotification.delegate = self
        
        cdNotification.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
        
        txtMinutes.delegate = self
        txtSeconds.delegate = self
        
        lblTimer.layer.borderWidth = 1
        btnPlay.layer.cornerRadius = 10
        btnReset.layer.cornerRadius = 10
    }
    
    @IBAction func btnPlayAction(_ sender: Any) {
        if isCountdownRunning {
            // Eğer geri sayım çalışıyorsa, durdur
            stopCountdown()
        } else {
            // Eğer geri sayım duruyorsa, başlat
            startCountdown()
        }
        
    }
    @IBAction func btnResetAction(_ sender: Any) {
        stopCountdown()
        lblTimer.text = "00:00"
        txtMinutes.text = "0"
        txtSeconds.text = "0"
        enableTextFields()
        
    }
    
    func startCountdown() {
        // Kullanıcı tarafından girilen saniye ve dakika değerlerini alın
        guard let minutesText = txtMinutes.text, let secondsText = txtSeconds.text,
              let minutes = Int(minutesText), let seconds = Int(secondsText) else {
            // Geçersiz giriş
            return
        }
        
        // Saniye cinsinden toplam süreyi hesaplayın
        remainingSeconds = (minutes * 60) + seconds
        
        if remainingSeconds <= 0 {
            // Geçersiz süre
            return
        }
        
        // Timer'ı başlat
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
                self.updateCountdownLabel()
            } else {
                self.stopCountdown()
                showSuccessAlert()
                lblTimer.text = "00:00"
                txtMinutes.text = "0"
                txtSeconds.text = "0"
                enableTextFields()
            }
        }
        
        isCountdownRunning = true
        btnPlay.setTitle("Stop", for: .normal)
        disableTextFields()
    }
    
    
    func stopCountdown() {
        countdownTimer?.invalidate()
        isCountdownRunning = false
        btnPlay.setTitle("Başlat", for: .normal)
        enableTextFields()
    }
    
    
    func updateCountdownLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        lblTimer.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func disableTextFields() {
        txtMinutes.isEnabled = false
        txtSeconds.isEnabled = false
    }
    
    func enableTextFields() {
        txtMinutes.isEnabled = true
        txtSeconds.isEnabled = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Sadece sayıları ve sınırlı uzunluğu (örneğin, 2 karakter) kabul eden bir özel metin girişi sınırlaması ekleyebilirsiniz.
        let allowedCharacterSet = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: characterSet) && textField.text!.count + string.count <= 2
    }
    func showSuccessAlert() {
        let content = UNMutableNotificationContent()
        content.title = "Countdown"
        content.body = "Countdown Finished"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Piano.mp3"))
        
        // Bildirimi tetikleyici (trigger) oluşturun (hemen göndermek için)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        // Bildirim talebini oluşturun
        let request = UNNotificationRequest(identifier: "coundDownFinished", content: content, trigger: trigger)
        
        // Bildirimi gönderin
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Notification Error \(error.localizedDescription)")
            } else {
                print("Notification Send Successfully")
            }
        }
        
        
        
        let alertController = UIAlertController(title: "Completed", message: "Countdown Completed", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Done", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        if let topViewController = UIApplication.shared.keyWindow?.rootViewController {
            topViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
}

extension ViewController: UNUserNotificationCenterDelegate {
    // Bildirimlerin merkezi tarafından işlenmesini sağlayan metot
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Kullanıcı bildirime yanıt verdiğinde burada gerekli işlemleri gerçekleştirin
        completionHandler()
    }
}

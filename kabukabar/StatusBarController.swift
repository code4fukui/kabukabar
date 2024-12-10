//
//  StatusBarController.swift
//  MenuBarAppSample
//
//  Created by Taisuke Fukuno on 2024/12/10.
//

import Foundation
import AppKit
import Cocoa

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var timer: Timer?
    private var symbol: String
    
    init() {
        //symbol = "AAPL" // Apple
        symbol = "5244.T" // jig.jp
        //symbol = "3778.T" // Sakura Internet
        statusBar = NSStatusBar.init()
        statusItem = statusBar.statusItem(withLength: 32.0)
        statusItem.button?.title = "-"
        statusItem.button?.action = #selector(openWebPage)
        statusItem.button?.target = self
        // タイマーを設定 (1時間ごとに更新)
        timer = Timer.scheduledTimer(timeInterval: 1 * 60 * 60.0, target: self, selector: #selector(fetchDataAndUpdateStatusBar), userInfo: nil, repeats: true)
        fetchDataAndUpdateStatusBar()
    }
    @objc func openWebPage() {
        if let url = URL(string: "https://finance.yahoo.co.jp/quote/" + symbol) {
            NSWorkspace.shared.open(url)
        }
    }
    func applicationWillTerminate(_ aNotification: Notification) {
        timer?.invalidate()
    }
    @objc func fetchDataAndUpdateStatusBar() {
        // URLを確認
        let apiUrl = "https://query1.finance.yahoo.com/v8/finance/chart/" + symbol
        guard let url = URL(string: apiUrl) else {
            statusItem.button?.title = "-"
            return
        }

        // URLSessionでデータを取得
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    self.statusItem.button?.title = "-"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.statusItem.button?.title = "-"
                }
                return
            }
            
            if let sdata = String(data: data, encoding: .utf8) {
                print(sdata);
            }
            // JSONをパース
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let chart = json["chart"] as? [String: Any],
                   let result = chart["result"] as? [[String: Any]],
                   let meta = result.first?["meta"] as? [String: Any],
                   let regularMarketPrice = meta["regularMarketPrice"] as? Double {
                    // JSON内の特定のキーを取得
                    DispatchQueue.main.async {
                        self.statusItem.button?.title = String(Int(regularMarketPrice))
                    }
                } else {
                    DispatchQueue.main.async {
                        self.statusItem.button?.title = "-"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.statusItem.button?.title = "-"
                }
            }
        }
        task.resume()
    }
}

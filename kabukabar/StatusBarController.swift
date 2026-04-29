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
    private var statusMenu: NSMenu
    private let symbolDefaultsKey = "symbol"
    
    init() {
        symbol = UserDefaults.standard.string(forKey: symbolDefaultsKey) ?? "AAPL"
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusMenu = NSMenu()
        statusMenu.addItem(NSMenuItem(title: "銘柄を設定...", action: #selector(showSymbolSettings), keyEquivalent: ","))
        statusMenu.addItem(NSMenuItem.separator())
        statusMenu.addItem(NSMenuItem(title: "終了", action: #selector(quit), keyEquivalent: "q"))
        statusMenu.items.forEach { $0.target = self }
        statusItem.button?.title = "-"
        statusItem.button?.action = #selector(handleStatusItemClick)
        statusItem.button?.target = self
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        // タイマーを設定 (1時間ごとに更新)
        timer = Timer.scheduledTimer(timeInterval: 1 * 60 * 60.0, target: self, selector: #selector(fetchDataAndUpdateStatusBar), userInfo: nil, repeats: true)
        fetchDataAndUpdateStatusBar()
    }
    @objc func handleStatusItemClick() {
        guard let event = NSApp.currentEvent else {
            openWebPage()
            return
        }

        if event.type == .rightMouseUp {
            statusItem.menu = statusMenu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            openWebPage()
        }
    }
    @objc func openWebPage() {
        if let url = URL(string: "https://finance.yahoo.co.jp/quote/" + symbol) {
            NSWorkspace.shared.open(url)
        }
    }
    @objc func showSymbolSettings() {
        let alert = NSAlert()
        alert.messageText = "銘柄を設定"
        alert.informativeText = "Yahoo Finance のシンボルを入力してください。例: AAPL, 5244.T"
        alert.addButton(withTitle: "保存")
        alert.addButton(withTitle: "キャンセル")

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 240, height: 24))
        input.stringValue = symbol
        alert.accessoryView = input

        if alert.runModal() == .alertFirstButtonReturn {
            let newSymbol = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !newSymbol.isEmpty else {
                return
            }
            symbol = newSymbol
            UserDefaults.standard.set(newSymbol, forKey: symbolDefaultsKey)
            statusItem.button?.title = "-"
            fetchDataAndUpdateStatusBar()
        }
    }
    @objc func quit() {
        timer?.invalidate()
        NSApp.terminate(nil)
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
